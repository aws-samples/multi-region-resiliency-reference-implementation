import json
from datetime import datetime, timedelta
import time

from botocore.exceptions import ClientError
import boto3
import logging
import traceback
import psycopg2
from psycopg2.extras import RealDictCursor
import base64
import random


ROLLBACK_TIME_IN_SECONDS = 3600

def enable_logging():
    root = logging.getLogger()
    if root.handlers:
        for handler in root.handlers:
            root.removeHandler(handler)
    logging.basicConfig(format='%(asctime)s %(message)s', level=logging.INFO)


enable_logging()


def deep_get(d, keys, default=None):
    assert type(keys) is list
    if d is None:
        return default
    if not keys:
        return d
    return deep_get(d.get(keys[0]), keys[1:], default)


def cors_headers():
    return {
        'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'OPTIONS,POST,GET,HEAD,PUT,DELETE,PATCH'
    }


def options(event, context):
    logging.debug("HTTP OPTIONS: Returning CORS Headers")
    return {'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET,HEAD,PUT,DELETE,PATCH'
            },
            'body': json.dumps('Options')
            }


def get_secret(secret_name, region_name):

    # secret_name = 'trade-matching-core-database'
    # region_name = "us-east-1"
    secret = None
    # Create a Secrets Manager client
    session = boto3.session.Session()
    print("before secret")
    endpoint_url = "https://secretsmanager." + region_name + ".amazonaws.com"
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name,
        endpoint_url=endpoint_url
    )
    # endpoint_url='https://secretsmanager.us-west-2.amazonaws.com'
    # endpoint_url='https://vpce-0f9fa6fae5eb57069-lk7nf8hd-us-west-2a.secretsmanager.us-west-2.vpce.amazonaws.com'
    # In this sample we only handle the specific exceptions for the 'GetSecretValue' API.
    # See https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
    # We rethrow the exception by default.

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'DecryptionFailureException':
            # Secrets Manager can't decrypt the protected secret text using the provided KMS key.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InternalServiceErrorException':
            # An error occurred on the server side.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            # You provided an invalid value for a parameter.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            # You provided a parameter value that is not valid for the current state of the resource.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'ResourceNotFoundException':
            # We can't find the resource that you asked for.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
    except Exception as e:
        raise e
    else:
        # Decrypts secret using the associated KMS CMK.
        # Depending on whether the secret is a string or binary, one of these fields will be populated.
        if 'SecretString' in get_secret_value_response:
            secret = get_secret_value_response['SecretString']
        else:
            decoded_binary_secret = base64.b64decode(get_secret_value_response['SecretBinary'])
    print("after secret")
    return json.loads(secret)  # returns the secret as dictionary


def get_db_connection(secret_name, region_name):
    connection = None
    secret_result = get_secret(secret_name, region_name)
    username = secret_result['username']
    password = secret_result['password']
    engine = secret_result['engine']
    dbname = secret_result['dbname']
    host = secret_result['host']
    port = secret_result['port']
    conn = None
    try:
        print("Connecting to DB and Push statements")
        connection = psycopg2.connect(
            host=host,
            database=dbname,
            user=username,
            password=password,
            port=port)
    except (Exception, psycopg2.Error) as error:
        if conn:
            print("Failed to init DB connection", error)

    return connection


def get_app_state(event, context):

    result = ''
    status_code = 500

    try:
        app = deep_get(event, ["queryStringParameters", "app"])
        region = deep_get(event, ["queryStringParameters", "region"])
        app_state = get_app_data(app, region)
        result = app_state.to_dict()
        status_code = 200

    except Exception as error:
        print("Error running get_appp_state", error)
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def get_app_states(event, context):

    result = ''
    status_code = 200

    apps = list()
    try:
        app = deep_get(event, ["queryStringParameters", "app"])
        apps.append(get_app_data(app, "us-east-1"))
        apps.append(get_app_data(app, "us-west-2"))

        result = [app.to_dict() for app in apps]
        status_code = 200

    except Exception as error:
        print("Error running get_app_states", error)
        traceback.print_exc()
        result = [app.to_dict() for app in apps]

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def get_app_data(app, region):
    app_state = AppState()

    try:

        app_state.app_name = app
        app_state.app_region = region

        # app_state.dns_arc_control_state = get_arc_control_state(app, "dns", region)
        # app_state.queue_arc_control_state = get_arc_control_state(app, "queue", region)
        # app_state.app_arc_control_state = get_arc_control_state(app, "app", region)
        dynamodb = boto3.resource('dynamodb', region_name=region)

        if app == "trade-matching":
            app_state.inbound_gateway_trade_store_count = get_dynamodb_table_count(dynamodb, app, "in-gateway", "trade")

        app_state.inbound_gateway_settlement_store_count = get_dynamodb_table_count(dynamodb, app, "in-gateway", "settlement")

        if app == "trade-matching":
            app_state.ingestion_trade_store_count = get_dynamodb_table_count(dynamodb, app, "ingress", "trade")

        app_state.ingestion_settlement_store_count = get_dynamodb_table_count(dynamodb, app, "ingress", "settlement")

        try:
            connection = get_db_connection(app + '-core-database', region)

            if app == "trade-matching":
                if is_global_cluster_available(app, "core"):
                    app_state.matching_store_count = get_rds_table_count(connection, """select count(*) from trade_message tm""")
                    app_state.matching_settled_store_count = get_rds_table_count(connection, """select count(*) from trade_message tm where status = 'SETTLED'""")
                    app_state.matching_matched_store_count = get_rds_table_count(connection, """select count(*) from trade_message tm where status = 'MATCHED'""")
                    app_state.matching_mismatched_store_count = get_rds_table_count(connection, """select count(*) from trade_message tm where status = 'MISMATCHED'""")
                    app_state.matching_unmatched_store_count = get_rds_table_count(connection, """select count(*) from trade_message tm where status = 'UNMATCHED'""")
            else:
                if is_global_cluster_available(app, "core"):
                    app_state.matching_store_count = get_rds_table_count(connection, """select count(*) from settlement_message tm""")
                    app_state.matching_matched_store_count = get_rds_table_count(connection, """select count(*) from settlement_message tm where status = 'Settled'""")
                    app_state.matching_mismatched_store_count = get_rds_table_count(connection, """select count(*) from settlement_message tm where status = 'Mismatched'""")
                    app_state.matching_unmatched_store_count = get_rds_table_count(connection, """select count(*) from settlement_message tm where status = 'Unmatched'""")
        except Exception as error:
            print("Error running get_app_data", error)
            traceback.print_exc()

        if app == "trade-matching":
            app_state.egress_trade_store_count = get_dynamodb_table_count(dynamodb, app, "egress", "trade")

        app_state.egress_settlement_store_count = get_dynamodb_table_count(dynamodb, app, "egress", "settlement")

        if app == "trade-matching":
            app_state.outbound_gateway_trade_store_count = get_dynamodb_table_count(dynamodb, app, "out-gateway", "trade")

        app_state.outbound_gateway_settlement_store_count = get_dynamodb_table_count(dynamodb, app, "out-gateway", "settlement")

    except Exception as error:
        print("Error running get_app_data", error)
        traceback.print_exc()

    return app_state


def get_dynamodb_table_count(dynamodb, app, component, content):
    c = 0
    res = {}
    dbname = app + "-" + component + "-" + content + "-dynamodb-store"
    table = dynamodb.Table(dbname)
    try:
        """
        Don't do this in production. Maintain a separate table for counts, reduce timeframe of count needed 
        (Ex. past 12 hours), or consider reusing last partition fully scanned (last_eval_key below)
        """
        res = table.scan(
            Select='COUNT',
        )
        c += res['Count']

        while 'LastEvaluatedKey' in res:
            last_eval_key = res['LastEvaluatedKey']
            res = table.scan(
                Select='COUNT',
                ExclusiveStartKey=last_eval_key
            )
            c += res['Count']

    except Exception as error:
        print("Error running get_dynamodb_table_count", error)
        traceback.print_exc()

    return c


def get_rds_table_count(connection, query):

    try:

        cursor = connection.cursor(cursor_factory=RealDictCursor)
        cursor.execute(query, )
        records = cursor.fetchall()
        return records[0]["count"]

    except Exception as error:
        print("Error running get_app_data", error)
        traceback.print_exc()

    return 0


class AppState:
    """
    It represents the state of an App.
    """
    def __init__(self):
        """
        Initializes the App State.
        """
        self.app_name = ""
        self.app_region = ""
        self.inbound_gateway_trade_store_count = 0
        self.inbound_gateway_settlement_store_count = 0
        self.ingestion_trade_store_count = 0
        self.ingestion_settlement_store_count = 0
        self.matching_store_count = 0
        self.matching_settled_store_count = 0
        self.matching_matched_store_count = 0
        self.matching_mismatched_store_count = 0
        self.matching_unmatched_store_count = 0
        self.egress_trade_store_count = 0
        self.egress_settlement_store_count = 0
        self.outbound_gateway_trade_store_count = 0
        self.outbound_gateway_settlement_store_count = 0

    def to_dict(self):
        return {
            'app_name': self.app_name,
            'app_region': self.app_region,
            'inbound_gateway_trade_store_count': self.inbound_gateway_trade_store_count,
            'inbound_gateway_settlement_store_count': self.inbound_gateway_settlement_store_count,
            'ingestion_trade_store_count': self.ingestion_trade_store_count,
            'ingestion_settlement_store_count': self.ingestion_settlement_store_count,
            'matching_store_count': self.matching_store_count,
            'matching_settled_store_count': self.matching_settled_store_count,
            'matching_matched_store_count': self.matching_matched_store_count,
            'matching_mismatched_store_count': self.matching_mismatched_store_count,
            'matching_unmatched_store_count': self.matching_unmatched_store_count,
            'egress_trade_store_count': self.egress_trade_store_count,
            'egress_settlement_store_count': self.egress_settlement_store_count,
            'outbound_gateway_trade_store_count': self.outbound_gateway_trade_store_count,
            'outbound_gateway_settlement_store_count': self.outbound_gateway_settlement_store_count
        }


def get_app_controls(event, context):

    result = ''
    status_code = 200
    app_control = AppControls()
    try:
        app = deep_get(event, ["queryStringParameters", "app"])
        region = deep_get(event, ["queryStringParameters", "region"])

        try:
            app_control.dns_arc_control_state = get_arc_control_state(app, "dns", region)
        except Exception as error:
            print("Error running get_app_controls", error)
            traceback.print_exc()

        try:
            app_control.queue_arc_control_state = get_arc_control_state(app, "queue", region)
        except Exception as error:
            print("Error running get_app_controls", error)
            traceback.print_exc()

        try:
            app_control.app_arc_control_state = get_arc_control_state(app, "app", region)
        except Exception as error:
            print("Error running get_app_controls", error)
            traceback.print_exc()

        result = app_control.to_dict()
        status_code = 200

    except Exception as error:
        print("Error running get_app_controls", error)
        traceback.print_exc()
        result = app_control.to_dict()

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def get_arc_control_state(app, scope, region):

    client = boto3.client('secretsmanager', region_name="us-east-1")
    cluster = client.get_secret_value(SecretId='approtation-cluster')['SecretString']
    control = ""
    if region == "":
        control = client.get_secret_value(SecretId=(app + "-" + scope + "-arc-control"))['SecretString']
    else:
        control = client.get_secret_value(SecretId=(app + "-" + scope + "-" + region + "-arc-control"))['SecretString']
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " Region: " + region + " App: " + app + " Scope: " + scope)

    client = boto3.client('route53-recovery-control-config', region_name='us-west-2')
    cluster = client.describe_cluster(ClusterArn=cluster)
    endpoints = cluster['Cluster']['ClusterEndpoints']
    regions = ["us-east-1", "us-west-2", "eu-west-1", "ap-northeast-1", "ap-southeast-2"]
    for region in regions:
        for endpoint in endpoints:
            if endpoint["Region"] == region:
                try:
                    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " route 53 recovery cluster endpoint: " + endpoint["Endpoint"])
                    client = boto3.client('route53-recovery-cluster', region_name=region, endpoint_url=endpoint["Endpoint"])

                    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " getting control state for control : " + control)
                    return client.get_routing_control_state(RoutingControlArn=control)['RoutingControlState']

                except Exception as e:
                    print(e)

    return "unknown"


class AppControls:
    """
    It represents the state of an App.
    """
    def __init__(self):
        """
        Initializes the App State.
        """
        self.app_name = ""
        self.app_region = ""
        self.dns_arc_control_state = "Unknown"
        self.queue_arc_control_state = "Unknown"
        self.app_arc_control_state = "Unknown"

    def to_dict(self):
        return {
            'app_name': self.app_name,
            'app_region': self.app_region,
            'dns_arc_control_state': self.dns_arc_control_state,
            'queue_arc_control_state': self.queue_arc_control_state,
            'app_arc_control_state': self.app_arc_control_state
        }


def update_arc_control(event, context):

    result = ''
    status_code = 500

    try:
        input_body = event.get("body")
        if input_body:
            json_param = json.loads(input_body)
            app = json_param["app"]
            scope = json_param["scope"]
            region = json_param["region"]
            state = json_param["state"]

            client = boto3.client('secretsmanager', region_name="us-east-1")
            cluster = client.get_secret_value(SecretId='approtation-cluster')['SecretString']
            control = ""
            if region == "":
                control = client.get_secret_value(SecretId=(app + "-" + scope + "-arc-control"))['SecretString']
            else:
                control = client.get_secret_value(SecretId=(app + "-" + scope + "-" + region + "-arc-control"))['SecretString']
            print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " Region: " + region + " App: " + app + " Scope: " + scope + " State: " + state)

            client = boto3.client('route53-recovery-control-config', region_name='us-west-2')
            cluster = client.describe_cluster(ClusterArn=cluster)
            endpoints = cluster['Cluster']['ClusterEndpoints']
            regions = ["us-east-1", "us-west-2", "eu-west-1", "ap-northeast-1", "ap-southeast-2"]
            done = False
            for region in regions:
                for endpoint in endpoints:
                    if endpoint["Region"] == region:

                        try:
                            print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " route 53 recovery cluster endpoint: " + endpoint["Endpoint"])
                            client = boto3.client('route53-recovery-cluster', region_name=region, endpoint_url=endpoint["Endpoint"])

                            print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " updating control: " + control + " to On")
                            client.update_routing_control_state(RoutingControlArn=control, RoutingControlState=state)
                            print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " successfully updated control")

                            done = True
                            break
                        except Exception as e:
                            print(e)
                if done:
                    break
            status_code = 200
        else:
            result = "Error, incorrect post body"
            status_code = 400
    except Exception as error:
        print("Error running update_arc_control " + str(error))
        traceback.print_exc()
        result = str(error)
    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def execute_run_book(event, context):

    result = ''
    status_code = 500

    try:
        input_body = event.get("body")
        if input_body:
            json_param = json.loads(input_body)
            region = json_param["region"]
            document = json_param["document"]
            app = json_param["app"]
            type = json_param["type"]
            mode = json_param["mode"]

            client = boto3.client('ssm', region_name=region)
            client.start_automation_execution(DocumentName=document, Parameters={'APP': [app], 'TYPE': [type], 'MODE': [mode]})

            status_code = 200
        else:
            result = "Error, incorrect post body"
            status_code = 400
    except Exception as error:
        print("Error running execute_run_book " + str(error))
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response





# def get_app_recons(event, context):
#
#     result = ''
#     status_code = 500
#
#     recons = list()
#     try:
#         app = deep_get(event, ["queryStringParameters", "app"])
#         print("APP = " + app)
#         recon1 = get_app_recon(app, "us-east-1")
#         recons.append(recon1)
#         recon2 = recon_copy(recon1)
#         recon2.app_region = "us-west-2"
#         recons.append(recon2)
#
#         result = [recon.to_dict() for recon in recons]
#         status_code = 200
#
#     except Exception as error:
#         print("Error running get_app_recons", error)
#         traceback.print_exc()
#         result = str(error)
#
#     response = {
#         "statusCode": status_code,
#         'headers': cors_headers(),
#         "body": json.dumps(result, indent=2, sort_keys=True, default=str)
#     }
#
#     return response
#
#
# def get_app_recon(app, region):
#
#     app_recon = AppRecon()
#
#     try:
#
#         app_recon.app_name = app
#         app_recon.app_region = region
#
#         client = boto3.client('secretsmanager', region_name="us-east-1")
#
#         if app == "trade-matching":
#             app_recon.inbound_ingress_trade_recon = inbound_ingress_reconciliation(region)
#             if is_global_cluster_available(app, "core"):
#                 app_recon.ingress_core_trade_recon = ingress_core_reconciliation(region)
#                 app_recon.core_egress_trade_recon = core_egress_reconciliation(region)
#             app_recon.egress_outbound_trade_recon = egress_outbound_trade_reconciliation(region)
#             app_recon.egress_outbound_settlement_recon = egress_outbound_settlement_reconciliation(region)
#             app_recon.outbound_other_inbound_settlement_recon = outbound_settlement_inbound_reconciliation(region)
#         else:
#             app_recon.inbound_ingress_settlement_recon = settlement_inbound_ingress_reconciliation(region)
#             if is_global_cluster_available(app, "core"):
#                 app_recon.ingress_core_settlement_recon = settlement_ingress_core_reconciliation(region)
#                 app_recon.core_egress_settlement_recon = settlement_core_egress_reconciliation(region)
#             app_recon.egress_outbound_settlement_recon = settlement_egress_outbound_reconciliation(region)
#             app_recon.outbound_other_inbound_settlement_recon = outbound_trade_matching_inbound_reconciliation(region)
#
#     except Exception as error:
#         print("Error running get_app_recon", error)
#         traceback.print_exc()
#         result = str(error)
#
#     return app_recon


class AppRecon:
    """
    It represents the state of an App.
    """
    def __init__(self):
        """
        Initializes the App State.
        """
        self.app_name = ""
        self.app_region = ""
        self.inbound_ingress_trade_recon = 0
        self.inbound_ingress_settlement_recon = 0
        self.ingestion_core_trade_recon = 0
        self.ingestion_core_settlement_recon = 0
        self.core_egress_trade_recon = 0
        self.core_egress_settlement_recon = 0
        self.egress_outbound_trade_recon = 0
        self.egress_outbound_settlement_recon = 0
        self.outbound_other_inbound_trade_recon = 0
        self.outbound_other_inbound_settlement_recon = 0

    def to_dict(self):
        return {
            'app_name': self.app_name,
            'app_region': self.app_region,
            'inbound_ingress_trade_recon': self.inbound_ingress_trade_recon,
            'inbound_ingress_settlement_recon': self.inbound_ingress_settlement_recon,
            'ingestion_core_trade_recon': self.ingestion_core_trade_recon,
            'ingestion_core_settlement_recon': self.ingestion_core_settlement_recon,
            'core_egress_trade_recon': self.core_egress_trade_recon,
            'core_egress_settlement_recon': self.core_egress_settlement_recon,
            'egress_outbound_trade_recon': self.egress_outbound_trade_recon,
            'egress_outbound_settlement_recon': self.egress_outbound_settlement_recon,
            'outbound_other_inbound_trade_recon': self.outbound_other_inbound_trade_recon,
            'outbound_other_inbound_settlement_recon': self.outbound_other_inbound_settlement_recon
        }


def recon_copy(recon):

    recon_copy = AppRecon()

    recon_copy.app_name = recon.app_name
    recon_copy.app_region = recon.app_region
    recon_copy.inbound_ingress_trade_recon = recon.inbound_ingress_trade_recon
    recon_copy.inbound_ingress_settlement_recon = recon.inbound_ingress_settlement_recon
    recon_copy.ingestion_core_trade_recon = recon.ingestion_core_trade_recon
    recon_copy.ingestion_core_settlement_recon = recon.ingestion_core_settlement_recon
    recon_copy.core_egress_trade_recon = recon.core_egress_trade_recon
    recon_copy.core_egress_settlement_recon = recon.core_egress_settlement_recon
    recon_copy.egress_outbound_trade_recon = recon.egress_outbound_trade_recon
    recon_copy.egress_outbound_settlement_recon = recon.egress_outbound_settlement_recon
    recon_copy.outbound_other_inbound_trade_recon = recon.outbound_other_inbound_trade_recon
    recon_copy.outbound_other_inbound_settlement_recon = recon.outbound_other_inbound_settlement_recon

    return recon_copy


def get_app_ready(event, context):

    result = ""
    status_code = 500
    app_ready = AppReady()

    try:
        app = deep_get(event, ["queryStringParameters", "app"])
        app_ready.app_name = app

        client = boto3.client('route53-recovery-readiness', region_name="us-west-2")

        global_inbound_gateway = client.get_cell_readiness_summary(CellName=app + "-global-inbound-gateway")
        app_ready.inbound_dynamodb_trade = get_readiness_status(global_inbound_gateway, app + "-global-inbound-gateway-trade")
        app_ready.inbound_dynamodb_settlement = get_readiness_status(global_inbound_gateway, app + "-global-inbound-gateway-settlement")

        global_ingestion = client.get_cell_readiness_summary(CellName= app + "-global-ingress")
        app_ready.ingestion_dynamodb_trade = get_readiness_status(global_ingestion, app + "-global-ingress-trade")
        app_ready.ingestion_dynamodb_settlement = get_readiness_status(global_ingestion, app + "-global-ingress-settlement")

        global_matching = client.get_cell_readiness_summary(CellName=app + '-global-core')
        app_ready.matching_rds = get_readiness_status(global_matching, app + "-global-core")

        global_egress = client.get_cell_readiness_summary(CellName= app + "-global-egress")
        app_ready.egress_dynamodb_trade = get_readiness_status(global_egress, app + "-global-egress-trade")
        app_ready.egress_dynamodb_settlement = get_readiness_status(global_egress, app + "-global-egress-settlement")

        global_outbound_gateway = client.get_cell_readiness_summary(CellName= app + "-global-outbound-gateway")
        app_ready.outbound_dynamodb_trade = get_readiness_status(global_outbound_gateway, app + "-global-outbound-gateway-trade")
        app_ready.outbound_dynamodb_settlement = get_readiness_status(global_outbound_gateway, app + "-global-outbound-gateway-settlement")

        region = "us-east-1"

        primary_inbound_gateway = client.get_cell_readiness_summary(CellName=app + "-" + region + "-inbound-gateway")
        app_ready.inbound_ecs_primary = get_readiness_status(primary_inbound_gateway, app + "-" + region + "-inbound-gateway-asg")

        primary_ingestion = client.get_cell_readiness_summary(CellName=app + "-" + region + "-ingress")
        app_ready.ingestion_ecs_primary = get_readiness_status(primary_ingestion, app + "-" + region + "-ingress-asg")

        primary_matching = client.get_cell_readiness_summary(CellName=app + "-" + region + "-core")
        app_ready.matching_ecs_ingestion_primary = get_readiness_status(primary_matching, app + "-" + region + "-core-asg-1")
        app_ready.matching_ecs_matching_primary = get_readiness_status(primary_matching, app + "-" + region + "-core-asg-2")

        primary_egress = client.get_cell_readiness_summary(CellName=app + "-" + region + "-egress")
        app_ready.egress_ecs_primary = get_readiness_status(primary_egress, app + "-" + region + "-egress-asg")

        primary_outbound_gateway = client.get_cell_readiness_summary(CellName=app + "-" + region + "-outbound-gateway")
        app_ready.outbound_ecs_primary = get_readiness_status(primary_outbound_gateway, app + "-" + region + "-outbound-gateway-asg")

        region = "us-west-2"

        secondary_inbound_gateway = client.get_cell_readiness_summary(CellName=app + "-" + region + "-inbound-gateway")
        app_ready.inbound_ecs_secondary = get_readiness_status(secondary_inbound_gateway, app + "-" + region + "-inbound-gateway-asg")

        secondary_ingestion = client.get_cell_readiness_summary(CellName=app + "-" + region + "-ingress")
        app_ready.ingestion_ecs_secondary = get_readiness_status(secondary_ingestion, app + "-" + region + "-ingress-asg")

        secondary_matching = client.get_cell_readiness_summary(CellName=app + "-" + region + "-core")
        app_ready.matching_ecs_ingestion_secondary = get_readiness_status(secondary_matching, app + "-" + region + "-core-asg-1")
        app_ready.matching_ecs_matching_secondary = get_readiness_status(secondary_matching, app + "-" + region + "-core-asg-2")

        secondary_egress = client.get_cell_readiness_summary(CellName=app + "-" + region + "-egress")
        app_ready.egress_ecs_secondary = get_readiness_status(secondary_egress, app + "-" + region + "-egress-asg")

        secondary_outbound_gateway = client.get_cell_readiness_summary(CellName=app + "-" + region + "-outbound-gateway")
        app_ready.outbound_ecs_secondary = get_readiness_status(secondary_outbound_gateway, app + "-" + region + "-outbound-gateway-asg")

        app_ready.summary = get_readiness_summary(app_ready, app)

        result = app_ready.to_dict()
        status_code = 200

    except Exception as error:
        print("Error running get_app_ready", error)
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def get_readiness_status(readiness_response, readiness_check_name):
    for check in readiness_response["ReadinessChecks"]:
        if check["ReadinessCheckName"] == readiness_check_name:
            return check["Readiness"]
    return "UNKNOWN"


def get_readiness_summary(app_ready, app_name):
    if app_name == "trade-matching":
        if (app_ready.inbound_dynamodb_trade == "READY" and
            app_ready.inbound_dynamodb_settlement == "READY" and
            app_ready.inbound_ecs_primary == "READY" and
            app_ready.inbound_ecs_secondary == "READY" and
            app_ready.ingestion_dynamodb_trade == "READY" and
            app_ready.ingestion_dynamodb_settlement == "READY" and
            app_ready.ingestion_ecs_primary == "READY" and
            app_ready.ingestion_ecs_secondary == "READY" and
            app_ready.matching_rds == "READY" and
            # app_ready.matching_ecs_ingestion_primary == "READY" and
            # app_ready.matching_ecs_ingestion_secondary == "READY" and
            app_ready.matching_ecs_matching_primary == "READY" and
            app_ready.matching_ecs_matching_secondary == "READY" and
            app_ready.egress_dynamodb_trade == "READY" and
            app_ready.egress_dynamodb_settlement == "READY" and
            app_ready.egress_ecs_primary == "READY" and
            app_ready.egress_ecs_secondary == "READY" and
            app_ready.outbound_dynamodb_trade == "READY" and
            app_ready.outbound_dynamodb_settlement == "READY" and
            app_ready.outbound_ecs_primary == "READY" and
            app_ready.outbound_ecs_secondary == "READY"):
            return "READY"
        else:
            return "NOT_READY"
    else:
        if (app_ready.inbound_dynamodb_settlement == "READY" and
            app_ready.inbound_ecs_primary == "READY" and
            app_ready.inbound_ecs_secondary == "READY" and
            app_ready.ingestion_dynamodb_settlement == "READY" and
            app_ready.ingestion_ecs_primary == "READY" and
            app_ready.ingestion_ecs_secondary == "READY" and
            app_ready.matching_rds == "READY" and
            # app_ready.matching_ecs_ingestion_primary == "READY" and
            # app_ready.matching_ecs_ingestion_secondary == "READY" and
            app_ready.matching_ecs_matching_primary == "READY" and
            app_ready.matching_ecs_matching_secondary == "READY" and
            app_ready.egress_dynamodb_settlement == "READY" and
            app_ready.egress_ecs_primary == "READY" and
            app_ready.egress_ecs_secondary == "READY" and
            app_ready.outbound_dynamodb_settlement == "READY" and
            app_ready.outbound_ecs_primary == "READY" and
            app_ready.outbound_ecs_secondary == "READY"):
            return "READY"
        else:
            return "NOT_READY"


class AppReady:
    """
    It represents the state of an App.
    """

    def __init__(self):
        """
        Initializes the App State.
        """
        self.app_name = ""
        self.summary = "UNKNOWN"
        self.control_dns = "UNKNOWN"
        self.control_queue = "UNKNOWN"
        self.control_app = "UNKNOWN"
        self.inbound_dynamodb_trade = "UNKNOWN"
        self.inbound_dynamodb_settlement = "UNKNOWN"
        self.inbound_ecs_primary = "UNKNOWN"
        self.inbound_ecs_secondary = "UNKNOWN"
        self.ingestion_dynamodb_trade = "UNKNOWN"
        self.ingestion_dynamodb_settlement = "UNKNOWN"
        self.ingestion_ecs_primary = "UNKNOWN"
        self.ingestion_ecs_secondary = "UNKNOWN"
        self.matching_rds = "UNKNOWN"
        self.matching_ecs_ingestion_primary = "UNKNOWN"
        self.matching_ecs_ingestion_secondary = "UNKNOWN"
        self.matching_ecs_matching_primary = "UNKNOWN"
        self.matching_ecs_matching_secondary = "UNKNOWN"
        self.egress_dynamodb_trade = "UNKNOWN"
        self.egress_dynamodb_settlement = "UNKNOWN"
        self.egress_ecs_primary = "UNKNOWN"
        self.egress_ecs_secondary = "UNKNOWN"
        self.outbound_dynamodb_trade = "UNKNOWN"
        self.outbound_dynamodb_settlement = "UNKNOWN"
        self.outbound_ecs_primary = "UNKNOWN"
        self.outbound_ecs_secondary = "UNKNOWN"

    def to_dict(self):
        return {
            'app_name': self.app_name,
            'summary': self.summary,
            'control_dns': self.control_dns,
            'control_queue': self.control_queue,
            'control_app': self.control_app,
            'inbound_dynamodb_trade': self.inbound_dynamodb_trade,
            'inbound_dynamodb_settlement': self.inbound_dynamodb_settlement,
            'inbound_ecs_primary': self.inbound_ecs_primary,
            'inbound_ecs_secondary': self.inbound_ecs_secondary,
            'ingestion_dynamodb_trade': self.ingestion_dynamodb_trade,
            'ingestion_dynamodb_settlement': self.ingestion_dynamodb_settlement,
            'ingestion_ecs_primary': self.ingestion_ecs_primary,
            'ingestion_ecs_secondary': self.ingestion_ecs_secondary,
            'matching_rds': self.matching_rds,
            'matching_ecs_ingestion_primary': self.matching_ecs_ingestion_primary,
            'matching_ecs_ingestion_secondary': self.matching_ecs_ingestion_secondary,
            'matching_ecs_matching_primary': self.matching_ecs_matching_primary,
            'matching_ecs_matching_secondary': self.matching_ecs_matching_secondary,
            'egress_dynamodb_trade': self.egress_dynamodb_trade,
            'egress_dynamodb_settlement': self.egress_dynamodb_settlement,
            'egress_ecs_primary': self.egress_ecs_primary,
            'egress_ecs_secondary': self.egress_ecs_secondary,
            'outbound_dynamodb_trade': self.outbound_dynamodb_trade,
            'outbound_dynamodb_settlement': self.outbound_dynamodb_settlement,
            'outbound_ecs_primary': self.outbound_ecs_primary,
            'outbound_ecs_secondary': self.outbound_ecs_secondary
        }


def get_app_health(event, context):

    result = ""
    status_code = 500
    app_health = AppHealth()

    try:
        client = boto3.client('health', region_name="us-east-1")
        response = client.describe_events(
            filter={
                'services': ["MQ", "KINESIS", "DYNAMODB", "RDS", "ECS"],
                'regions': ["us-east-1", "us-west-2"],
                'eventStatusCodes': ['open']
            }
        )

        app_health.mq = get_service_health(response, "MQ")
        app_health.kinesis = get_service_health(response, "KINESIS")
        app_health.dynamodb = get_service_health(response, "DYNAMODB")
        app_health.rds = get_service_health(response, "RDS")
        app_health.ecs = get_service_health(response, "ECS")

        app_health.summary = get_health_summary(app_health)

        result = app_health.to_dict()
        status_code = 200

    except Exception as error:
        print("Error running get_app_health", error)
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def get_health_summary(app_health):

    if (app_health.mq == "HEALTHY" and
        app_health.kinesis == "HEALTHY" and
        app_health.dynamodb == "HEALTHY" and
        app_health.rds == "HEALTHY" and
        app_health.ecs == "HEALTHY"):
        return "HEALTHY"
    else:
        return "NOT_HEALTHY"


def get_service_health(response, service):

    events = response["events"]

    for event in events:
        if event["service"] == service:
            return "NOT_HEALTHY"

    return "HEALTHY"


class AppHealth:
    """
    It represents the state of an App.
    """

    def __init__(self):
        """
        Initializes the App State.
        """
        self.summary = "UNKNOWN"
        self.mq = "UNKNOWN"
        self.kinesis = "UNKNOWN"
        self.dynamodb = "UNKNOWN"
        self.rds = "UNKNOWN"
        self.ecs = "UNKNOWN"

    def to_dict(self):
        return {
            'summary': self.summary,
            'mq': self.mq,
            'kinesis': self.kinesis,
            'dynamodb': self.dynamodb,
            'rds': self.rds,
            'ecs': self.ecs
        }


def get_rds_global_db_rpo_lag(region, app, component):

    client = boto3.client('secretsmanager', region_name=region)
    global_cluster_name = client.get_secret_value(SecretId=(app + "-" + component + "-database-cluster"))['SecretString']

    client = boto3.client('cloudwatch', region_name=region)

    response = client.get_metric_data(
        MetricDataQueries=[
            {
                'Id': 'identifier',
                'MetricStat': {
                    'Metric': {
                        'Namespace': 'AWS/RDS',
                        'MetricName': 'AuroraGlobalDBRPOLag',
                        'Dimensions': [
                            {
                               'Name': 'DBClusterIdentifier',
                               'Value': global_cluster_name
                            }
                        ]
                    },
                    'Period': 60,
                    'Stat': 'Average',
                    'Unit': 'Milliseconds'
                }
            },
        ],
        StartTime=datetime.utcnow() - timedelta(minutes=90),
        EndTime=datetime.utcnow()
    )

    print(" Response = " + str(response))
    values = response['MetricDataResults'][0]['Values']
    print(" AuroraGlobalDBRPOLag = " + str(values))


def get_dynamodb_replication_latency(region, app, component):

    client = boto3.client('cloudwatch', region_name=region)

    response = client.get_metric_data(
        MetricDataQueries=[
            {
                'Id': 'identifier',
                'MetricStat': {
                    'Metric': {
                        'Namespace': 'AWS/DynamoDB',
                        'MetricName': 'ReplicationLatency',
                        'Dimensions': [
                            {
                                'Name': 'TableName',
                                'Value': "trade-matching-ingress-trade-dynamodb-store"
                            },
                            {
                                'Name': 'ReceivingRegion',
                                'Value': "us-west-2"
                            }
                        ]
                    },
                    'Period': 60,
                    'Stat': 'Average',
                    'Unit': 'Milliseconds'
                }
            },
        ],

        StartTime=datetime.utcnow() - timedelta(minutes=90),
        EndTime=datetime.utcnow()
    )

    print(" Response = " + str(response))
    values = response['MetricDataResults'][0]['Values']
    print(" AuroraGlobalDBRPOLag = " + str(values))


def get_rds_global_db_rpo_lag(region, app, component):

    client = boto3.client('secretsmanager', region_name=region)
    global_cluster_name = client.get_secret_value(SecretId=(app + "-" + component + "-database-cluster"))['SecretString']

    client = boto3.client('cloudwatch', region_name=region)

    response = client.get_metric_data(
        MetricDataQueries=[
            {
                'Id': 'identifier',
                'MetricStat': {
                    'Metric': {
                        'Namespace': 'AWS/RDS',
                        'MetricName': 'AuroraGlobalDBRPOLag',
                        'Dimensions': [
                            {
                               'Name': 'DBClusterIdentifier',
                               'Value': global_cluster_name
                            }
                        ]
                    },
                    'Period': 60,
                    'Stat': 'Average',
                    'Unit': 'Milliseconds'
                }
            },
        ],
        StartTime=datetime.utcnow() - timedelta(minutes=90),
        EndTime=datetime.utcnow()
    )

    print(" Response = " + str(response))
    values = response['MetricDataResults'][0]['Values']
    print(" AuroraGlobalDBRPOLag = " + str(values))


def get_replication_latency(event, context):

    status_code = 500
    replication = AppReplication()

    try:
        app = deep_get(event, ["queryStringParameters", "app"])
        replication.app_name = app

        client = boto3.client('cloudwatch', region_name="us-east-1")

        response = client.get_metric_data(
            MetricDataQueries=[
                {
                    "Id": "dynamodb_query_1",
                    "MetricStat": {
                        "Metric": {
                            "Namespace": "AWS/DynamoDB",
                            "MetricName": "ReplicationLatency",
                            "Dimensions": [
                                {
                                    "Name": "TableName",
                                    "Value": app + "-in-gateway-trade-dynamodb-store"
                                },
                                {
                                    "Name": "ReceivingRegion",
                                    "Value": "us-west-2"}
                            ]
                        },
                        "Period": 60,
                        "Stat": "Average",
                        "Unit": "Milliseconds"
                    }
                },
                {
                    "Id": "dynamodb_query_2",
                    "MetricStat": {
                        "Metric": {
                            "Namespace": "AWS/DynamoDB",
                            "MetricName": "ReplicationLatency",
                            "Dimensions": [
                                {
                                    "Name": "TableName",
                                    "Value": app + "-in-gateway-settlement-dynamodb-store"
                                },
                                {
                                    "Name": "ReceivingRegion",
                                    "Value": "us-west-2"}
                            ]
                        },
                        "Period": 60,
                        "Stat": "Average",
                        "Unit": "Milliseconds"
                    }
                },
                {
                    "Id": "dynamodb_query_3",
                    "MetricStat": {
                        "Metric": {
                            "Namespace": "AWS/DynamoDB",
                            "MetricName": "ReplicationLatency",
                            "Dimensions": [
                                {
                                    "Name": "TableName",
                                    "Value": app + "-ingress-trade-dynamodb-store"
                                },
                                {
                                    "Name": "ReceivingRegion",
                                    "Value": "us-west-2"}
                            ]
                        },
                        "Period": 60,
                        "Stat": "Average",
                        "Unit": "Milliseconds"
                    }
                },
                {
                    "Id": "dynamodb_query_4",
                    "MetricStat": {
                        "Metric": {
                            "Namespace": "AWS/DynamoDB",
                            "MetricName": "ReplicationLatency",
                            "Dimensions": [
                                {
                                    "Name": "TableName",
                                    "Value": app + "-ingress-settlement-dynamodb-store"
                                },
                                {
                                    "Name": "ReceivingRegion",
                                    "Value": "us-west-2"}
                            ]
                        },
                        "Period": 60,
                        "Stat": "Average",
                        "Unit": "Milliseconds"
                    }
                },
                {
                    "Id": "dynamodb_query_5",
                    "MetricStat": {
                        "Metric": {
                            "Namespace": "AWS/DynamoDB",
                            "MetricName": "ReplicationLatency",
                            "Dimensions": [
                                {
                                    "Name": "TableName",
                                    "Value": app + "-egress-trade-dynamodb-store"
                                },
                                {
                                    "Name": "ReceivingRegion",
                                    "Value": "us-west-2"}
                            ]
                        },
                        "Period": 60,
                        "Stat": "Average",
                        "Unit": "Milliseconds"
                    }
                },
                {
                    "Id": "dynamodb_query_6",
                    "MetricStat": {
                        "Metric": {
                            "Namespace": "AWS/DynamoDB",
                            "MetricName": "ReplicationLatency",
                            "Dimensions": [
                                {
                                    "Name": "TableName",
                                    "Value": app + "-egress-settlement-dynamodb-store"
                                },
                                {
                                    "Name": "ReceivingRegion",
                                    "Value": "us-west-2"}
                            ]
                        },
                        "Period": 60,
                        "Stat": "Average",
                        "Unit": "Milliseconds"
                    }
                },
                {
                    "Id": "dynamodb_query_7",
                    "MetricStat": {
                        "Metric": {
                            "Namespace": "AWS/DynamoDB",
                            "MetricName": "ReplicationLatency",
                            "Dimensions": [
                                {
                                    "Name": "TableName",
                                    "Value": app + "-out-gateway-trade-dynamodb-store"
                                },
                                {
                                    "Name": "ReceivingRegion",
                                    "Value": "us-west-2"}
                            ]
                        },
                        "Period": 60,
                        "Stat": "Average",
                        "Unit": "Milliseconds"
                    }
                },
                {
                    "Id": "dynamodb_query_8",
                    "MetricStat": {
                        "Metric": {
                            "Namespace": "AWS/DynamoDB",
                            "MetricName": "ReplicationLatency",
                            "Dimensions": [
                                {
                                    "Name": "TableName",
                                    "Value": app + "-out-gateway-settlement-dynamodb-store"
                                },
                                {
                                    "Name": "ReceivingRegion",
                                    "Value": "us-west-2"}
                            ]
                        },
                        "Period": 60,
                        "Stat": "Average",
                        "Unit": "Milliseconds"
                    }
                },
                {
                    "Id": "rds_query",
                    "MetricStat": {
                        "Metric": {
                            "Namespace": "AWS/RDS",
                            "MetricName": "AuroraGlobalDBRPOLag",
                            "Dimensions": [
                                {
                                    "Name": "DBClusterIdentifier",
                                    "Value": app + "-core-global-cluster"
                                }
                            ]
                        },
                        "Period": 60,
                        "Stat": "Average",
                        "Unit": "Milliseconds"
                    }
                }
            ],
            StartTime=datetime.utcnow() - timedelta(minutes=60),
            EndTime=datetime.utcnow()
        )

        print(" Response = " + str(response))

        if app == "trade-matching":
            replication.inbound_dynamodb_trade = get_replication_status(response, "dynamodb_query_1")
            replication.ingestion_dynamodb_trade = get_replication_status(response, "dynamodb_query_3")
            replication.egress_dynamodb_trade = get_replication_status(response, "dynamodb_query_5")
            replication.outbound_dynamodb_trade = get_replication_status(response, "dynamodb_query_7")

        replication.inbound_dynamodb_settlement = get_replication_status(response, "dynamodb_query_2")
        replication.ingestion_dynamodb_settlement = get_replication_status(response, "dynamodb_query_4")
        replication.egress_dynamodb_settlement = get_replication_status(response, "dynamodb_query_6")
        replication.outbound_dynamodb_settlement = get_replication_status(response, "dynamodb_query_8")

        replication.matching_rds = get_replication_status(response, "rds_query")

        replication.summary = get_replication_summary(replication, app)

        result = replication.to_dict()
        status_code = 200

    except Exception as error:
        print("Error running get_app_ready", error)
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def get_replication_summary(app_replication, app_name):

    if app_name == "trade-matching":
        if (app_replication.inbound_dynamodb_trade == "HEALTHY" and
            app_replication.inbound_dynamodb_settlement == "HEALTHY" and
            app_replication.ingestion_dynamodb_trade == "HEALTHY" and
            app_replication.ingestion_dynamodb_settlement == "HEALTHY" and
            app_replication.matching_rds == "HEALTHY" and
            app_replication.egress_dynamodb_trade == "HEALTHY" and
            app_replication.egress_dynamodb_settlement == "HEALTHY" and
            app_replication.outbound_dynamodb_trade == "HEALTHY" and
            app_replication.outbound_dynamodb_settlement == "HEALTHY"):
            return "HEALTHY"
        else:
            return "NOT_HEALTHY"
    else:
        if (app_replication.inbound_dynamodb_settlement == "HEALTHY" and
            app_replication.ingestion_dynamodb_settlement == "HEALTHY" and
            app_replication.matching_rds == "HEALTHY" and
            app_replication.egress_dynamodb_settlement == "HEALTHY" and
            app_replication.outbound_dynamodb_settlement == "HEALTHY"):
            return "HEALTHY"
        else:
            return "NOT_HEALTHY"


def get_replication_status(response, id):
    results = response["MetricDataResults"]
    for result in results:
        if result["Id"] == id:
            values = result["Values"]
            for value in values:
                if value > 5000:
                    return "NOT_HEALTHY"
            return "HEALTHY"


class AppReplication:
    """
    It represents the state of an App.
    """

    def __init__(self):
        """
        Initializes the App State.
        """
        self.app_name = ""
        self.summary = "UNKNOWN"
        self.inbound_dynamodb_trade = "UNKNOWN"
        self.inbound_dynamodb_settlement = "UNKNOWN"
        self.ingestion_dynamodb_trade = "UNKNOWN"
        self.ingestion_dynamodb_settlement = "UNKNOWN"
        self.matching_rds = "UNKNOWN"
        self.egress_dynamodb_trade = "UNKNOWN"
        self.egress_dynamodb_settlement = "UNKNOWN"
        self.outbound_dynamodb_trade = "UNKNOWN"
        self.outbound_dynamodb_settlement = "UNKNOWN"

    def to_dict(self):
        return {
            'app_name': self.app_name,
            'summary': self.summary,
            'inbound_dynamodb_trade': self.inbound_dynamodb_trade,
            'inbound_dynamodb_settlement': self.inbound_dynamodb_settlement,
            'ingestion_dynamodb_trade': self.ingestion_dynamodb_trade,
            'ingestion_dynamodb_settlement': self.ingestion_dynamodb_settlement,
            'matching_rds': self.matching_rds,
            'egress_dynamodb_trade': self.egress_dynamodb_trade,
            'egress_dynamodb_settlement': self.egress_dynamodb_settlement,
            'outbound_dynamodb_trade': self.outbound_dynamodb_trade,
            'outbound_dynamodb_settlement': self.outbound_dynamodb_settlement
        }


def start_tasks_for_app(event, context):

    result = ""
    status_code = 500

    try:
        input_body = event.get("body")
        if input_body:
            json_param = json.loads(input_body)
            app = json_param["app"]
            region = json_param["region"]

            tasks = list_task_definition(region, app)
            start_tasks(region, tasks)

            status_code = 200
        else:
            result = "Error, incorrect post body"
            status_code = 400

    except Exception as error:
        print("Error running stop_all_tasks", error)
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def start_tasks_for_app_component(event, context):

    result = ""
    status_code = 500

    try:
        input_body = event.get("body")
        if input_body:
            json_param = json.loads(input_body)
            app = json_param["app"]
            component = json_param["component"]
            region = json_param["region"]

            tasks = list_task_definition(region, app+"-"+component)
            start_tasks(region, tasks)

            status_code = 200
        else:
            result = "Error, incorrect post body"
            status_code = 400

    except Exception as error:
        print("Error running stop_all_tasks", error)
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def stop_all_tasks_in_region(event, context):

    result = ""
    status_code = 500

    try:
        input_body = event.get("body")
        if input_body:
            json_param = json.loads(input_body)
            region = json_param["region"]
            tasks = list_running_tasks(region)
            for t in tasks:
                stop_task(region, t["cluster"], t["task"])

            status_code = 200
        else:
            result = "Error, incorrect post body"
            status_code = 400

    except Exception as error:
        print("Error running stop_all_tasks", error)
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def disable_vpc_endpoint(event, context):

    result = ""
    status_code = 500

    try:
        input_body = event.get("body")
        if input_body:
            json_param = json.loads(input_body)
            region = json_param["region"]
            app = json_param["app"]
            service = json_param["service"]

            client = boto3.client('ec2', region_name=region)
            response = client.describe_vpc_endpoints()

            for endpoint in response["VpcEndpoints"]:
                if endpoint["ServiceName"].endswith(service):
                    if endpoint["Groups"][0]["GroupName"].startswith(app):
                        client.modify_vpc_endpoint(VpcEndpointId=endpoint["VpcEndpointId"], PolicyDocument=str(endpoint["PolicyDocument"].replace("Allow", "Deny")))

            status_code = 200
        else:
            result = "Error, incorrect post body"
            status_code = 400

    except Exception as error:
        print("Error running disable_vpc_endpoint_for_service", error)
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def enable_vpc_endpoint(event, context):

    result = ""
    status_code = 500

    try:
        input_body = event.get("body")
        if input_body:
            json_param = json.loads(input_body)
            region = json_param["region"]
            app = json_param["app"]
            service = json_param["service"]

            client = boto3.client('ec2', region_name=region)
            response = client.describe_vpcs()
            vpc_id = ""
            for vpc in response["Vpcs"]:
                for tag in vpc.get("Tags", []):
                    if tag.get("Key", "") == "Name":
                        if tag.get("Value", "").startswith(app):
                            vpc_id = vpc.get("VpcId", "")

            response = client.describe_vpc_endpoints()

            for endpoint in response["VpcEndpoints"]:
                if endpoint.get("ServiceName", "").endswith(service):
                    if endpoint.get("VpcId", "") == vpc_id:
                        client.modify_vpc_endpoint(VpcEndpointId=endpoint["VpcEndpointId"], ResetPolicy=True)

            status_code = 200
        else:
            result = "Error, incorrect post body"
            status_code = 400

    except Exception as error:
        print("Error running disable_vpc_endpoint_for_service", error)
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def clean_databases(event, context):

    result = ""
    status_code = 500

    try:
        clean_table("us-east-1")
        status_code = 200

    except Exception as error:
        print("Error running stop_all_tasks", error)
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def clean_table(region):

    tables = ['trade-matching-in-gateway-trade-dynamodb-store', 'trade-matching-in-gateway-settlement-dynamodb-store',
              'trade-matching-ingress-trade-dynamodb-store', 'trade-matching-ingress-settlement-dynamodb-store',
              'trade-matching-egress-trade-dynamodb-store', 'trade-matching-egress-settlement-dynamodb-store',
              'trade-matching-out-gateway-settlement-dynamodb-store', 'trade-matching-out-gateway-trade-dynamodb-store',
              "recon-audit-dynamodb-store", "settlement-in-gateway-settlement-dynamodb-store",
              "settlement-ingress-settlement-dynamodb-store", 'settlement-egress-settlement-dynamodb-store',
              "settlement-out-gateway-settlement-dynamodb-store"]
    dynamo = boto3.resource('dynamodb', region_name=region)
    try:
        for t in tables:
            table = dynamo.Table(t)
            logging.info('Cleaning table {0}'.format(t))
            # get the table keys

            tableKeyNames = ['id']

            # logging.info(tableKeyNames)
            ProjectionExpression = ", ".join(tableKeyNames)

            response = table.scan(ProjectionExpression=ProjectionExpression)
            data = response.get('Items')

            logging.info("Found {0} Records to clean".format(len(data)))
            while 'LastEvaluatedKey' in response:
                response = table.scan(
                    ProjectionExpression=ProjectionExpression,
                    ExclusiveStartKey=response['LastEvaluatedKey']
                )
                data.extend(response['Items'])
            tableKeyNames2 = ['id']
            with table.batch_writer() as batch:
                for each in data:
                    test = {key: each[key] for key in tableKeyNames2}
                    # logging.info(test)
                    batch.delete_item(
                        Key=test
                    )
        # now clean RDS tables
        params = {}
        trade_matching_core_database = get_secret("trade-matching-core-database", region)
        update_rds(trade_matching_core_database, "DELETE FROM trade_allocation")
        update_rds(trade_matching_core_database, "DELETE FROM trade_message")

        settlement_core_database = get_secret("settlement-core-database", region)
        update_rds(settlement_core_database, "DELETE FROM settlement_message")

    except Exception as e:
        logging.error("Exception in clean_table ", e)


def list_task_definition(region, prefix):
    client = boto3.client("ecs", region_name=region)
    task_list = []
    response = client.list_clusters(
        maxResults=100
    )

    task_response = client.list_task_definitions()

    clusters = response['clusterArns']
    tasks = task_response["taskDefinitionArns"]
    for task in tasks:
        if prefix in task:
            if region.lower() == "us-west-2" and "generator" in task:
                logging.info("Skipping generator on us-west-2")
            else:
                task_list.append({
                    "cluster": match_cluster_to_task(clusters, task, prefix),
                    "task": task
                })

    return task_list


def match_cluster_to_task(clusters, task, prefix):
    task_name = task[task.rindex(prefix):].split(':')[0]
    for cluster in clusters:
        if task_name in cluster:
            return cluster

    return ""


def start_tasks(region, tasks):
    client = boto3.client("ecs", region_name=region)
    # make sure all tasks are off.
    for t in tasks:
        logging.info("Starting task {0} on cluster {1} ".format(t['task'], t["cluster"]))
        # get cluster instances
        response = client.list_container_instances(
            cluster=t["cluster"],
            status='ACTIVE'
        )
        instances = response['containerInstanceArns']

        # start the task
        response = client.start_task(
            cluster=t["cluster"],
            containerInstances=[instances[0]],
            taskDefinition=t['task'],
            propagateTags='TASK_DEFINITION'
        )
        logging.info(response)


def list_running_tasks(region):
    client = boto3.client("ecs", region_name=region)
    task_list = []
    response = client.list_clusters(
        maxResults=100
    )
    clusters = response['clusterArns']
    logging.info("Found {0} Clusters in account".format(len(clusters)))
    for cluster in clusters:
        task_response = client.list_tasks(
            cluster=cluster,
        )
        logging.info("Total {0} tasks, running in cluster {1}".format(len(task_response['taskArns']), cluster))
        for task in task_response["taskArns"]:
            logging.info(task)
            task_list.append({
                "cluster": cluster,
                "task": task
            })
    return task_list


def stop_task(region, cluster, task):
    client = boto3.client("ecs", region_name=region)
    logging.info("Stopping task {0} on cluster {1}".format(task, cluster))
    response = client.stop_task(
        cluster=cluster,
        task=task,
        reason='Manuel stop'
    )
    return True


def get_app_recon_step(event, context):

    result = ''
    result_value = 0
    status_code = 500
    region = "us-east-1"
    try:
        recon = deep_get(event, ["queryStringParameters", "recon"])
        print("RECON = " + recon)
        if recon == "TM-INBOUND-INGRESS-T":
            result_value = trade_matching_inbound_ingress_trade_reconciliation(region)
        elif recon == "TM-INBOUND-INGRESS-S":
            result_value = trade_matching_inbound_ingress_settlement_reconciliation(region)
        elif recon == "TM-INGRESS-CORE-T":
            if is_global_cluster_available("trade-matching", "core"):
                result_value = trade_matching_ingress_core_trade_reconciliation(region)
        elif recon == "TM-INGRESS-CORE-S":
            if is_global_cluster_available("trade-matching", "core"):
                result_value = trade_matching_ingress_core_settlement_reconciliation(region)
        elif recon == "TM-CORE-EGRESS-T":
            if is_global_cluster_available("trade-matching", "core"):
                result_value = trade_matching_core_egress_trade_reconciliation(region)
        elif recon == "TM-EGRESS-OUTBOUND-T":
            result_value = trade_matching_egress_outbound_trade_reconciliation(region)
        elif recon == "TM-EGRESS-OUTBOUND-S":
            result_value = trade_matching_egress_outbound_settlement_reconciliation(region)
        elif recon == "TM-OUTBOUND-SM-INBOUND-S":
            result_value = trade_matching_outbound_settlement_inbound_reconciliation(region)
        elif recon == "SM-INBOUND-INGRESS-S":
            result_value = settlement_inbound_ingress_settlement_reconciliation(region)
        elif recon == "SM-INGRESS-CORE-S":
            if is_global_cluster_available("settlement", "core"):
                result_value = settlement_ingress_core_settlement_reconciliation(region)
        elif recon == "SM-CORE-EGRESS-S":
            if is_global_cluster_available("settlement", "core"):
                result_value = settlement_core_egress_settlement_reconciliation(region)
        elif recon == "SM-EGRESS-OUTBOUND-S":
            result_value = settlement_egress_outbound_settlement_reconciliation(region)
        elif recon == "SM-OUTBOUND-TM-INBOUND-S":
            result_value = settlement_outbound_trade_matching_inbound_reconciliation(region)
        else:
            result_value = 0

        result = str(result_value) + ""

        status_code = 200

    except Exception as error:
        print("Error running get_app_recon_step", error)
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def get_executions(event, context):

    result = ''
    status_code = 500
    try:
        client = boto3.client('ssm', region_name="us-east-1")
        response = client.describe_automation_executions()

        execution_summary_list = list()
        for execution in response["AutomationExecutionMetadataList"]:
            execution_summary = ExecutionSummary()
            execution_summary.automation_execution_id = execution.get("AutomationExecutionId", "")
            execution_summary.document_name = execution.get("DocumentName", "")
            execution_summary.document_version = execution.get("DocumentVersion", "")
            execution_summary.automation_execution_status = execution.get("AutomationExecutionStatus", "")
            execution_summary.execution_start_time = execution.get("ExecutionStartTime", "")
            execution_summary.execution_end_time = execution.get("ExecutionEndTime", "")
            execution_summary.outputs = execution.get("Outputs", "")
            execution_summary.mode = execution.get("Mode", "")
            execution_summary.current_step_name = execution.get("CurrentStepName", "")
            execution_summary.current_action = execution.get("CurrentAction", "")
            execution_summary.automation_type = execution.get("AutomationType", "")
            execution_summary_list.append(execution_summary)

        result = [execution_summary.to_dict() for execution_summary in execution_summary_list]
        status_code = 200

    except Exception as error:
        print("Error running get_automation_executions", error)
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, default=str)
    }

    return response


class ExecutionSummary:
    """
    It represents an automation execution summary.
    """
    def __init__(self):
        """
        Initializes the App State.
        """
        self.automation_execution_id = ""
        self.document_name = ""
        self.document_version = ""
        self.automation_execution_status = ""
        self.execution_start_time = ""
        self.execution_end_time = ""
        self.outputs = ""
        self.mode = ""
        self.current_step_name = ""
        self.current_action = ""
        self.automation_type = ""

    def to_dict(self):
        return {
            'automation_execution_id': self.automation_execution_id,
            'document_name': self.document_name,
            'document_version': self.document_version,
            'automation_execution_status': self.automation_execution_status,
            'execution_start_time': self.execution_start_time,
            'execution_end_time': self.execution_end_time,
            'outputs': self.outputs,
            'mode': self.mode,
            'current_step_name': self.current_step_name,
            'current_action': self.current_action,
            'automation_type': self.automation_type
        }


def get_execution_detail(event, context):

    result = ''
    status_code = 500
    try:
        execution_id = deep_get(event, ["queryStringParameters", "id"])

        client = boto3.client('ssm', region_name="us-east-1")
        response = client.get_automation_execution(AutomationExecutionId=execution_id)
        execution = response["AutomationExecution"]

        execution_detail = ExecutionDetail()
        execution_detail.automation_execution_id = execution.get("AutomationExecutionId", "")
        execution_detail.document_name = execution.get("DocumentName", "")
        execution_detail.document_version = execution.get("DocumentVersion", "")
        execution_detail.automation_execution_status = execution.get("AutomationExecutionStatus", "")
        execution_detail.execution_start_time = execution.get("ExecutionStartTime", "")
        execution_detail.execution_end_time = execution.get("ExecutionEndTime", "")
        execution_detail.parameters = execution.get("Parameters", "")
        execution_detail.outputs = json.dumps(execution.get("Outputs", ""))
        execution_detail.mode = execution.get("Mode", "")

        execution_steps = execution["StepExecutions"]
        counter = 0
        for execution_step in execution_steps:
            counter = counter + 1
            step_detail = ExecutionStepDetail()
            step_detail.step_number = str(counter) + ""
            step_detail.step_name = execution_step.get("StepName", "")
            step_detail.action = execution_step.get("Action", "")
            step_detail.execution_start_time = execution_step.get("ExecutionStartTime", "")
            step_detail.execution_end_time = execution_step.get("ExecutionEndTime", "")
            step_detail.step_status = execution_step.get("StepStatus", "")
            inputs = execution_step.get("Inputs", None)
            if inputs is not None:
                step_detail.input_payload = inputs.get("InputPayload", "")
            outputs = execution_step.get("Outputs", None)
            if outputs is not None:
                output_payload_list = outputs.get("OutputPayload", None)
                if output_payload_list is not None:
                    output_payload = output_payload_list[0]
                    step_detail.output_payload = json.dumps(json.loads(output_payload).get("Payload", ""))
                    step_detail.execution_log = json.dumps(json.loads(output_payload).get("ExecutionLog", ""))
                    print(step_detail.execution_log)
            step_detail.step_execution_id = execution_step.get("StepExecutionId", "")
            execution_detail.steps.append(step_detail)

        result = execution_detail.to_dict()
        status_code = 200

    except Exception as error:
        print("Error running get_automation_executions", error)
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, default=str)
    }

    return response


class ExecutionDetail:
    """
    It represents an automation execution summary.
    """
    def __init__(self):
        """
        Initializes the App State.
        """
        self.automation_execution_id = ""
        self.document_name = ""
        self.document_version = ""
        self.automation_execution_status = ""
        self.execution_start_time = ""
        self.execution_end_time = ""
        self.parameters = ""
        self.outputs = ""
        self.mode = ""
        self.steps = list()

    def to_dict(self):
        return {
            'automation_execution_id': self.automation_execution_id,
            'document_name': self.document_name,
            'document_version': self.document_version,
            'automation_execution_status': self.automation_execution_status,
            'execution_start_time': self.execution_start_time,
            'execution_end_time': self.execution_end_time,
            'parameters': self.parameters,
            'outputs': self.outputs,
            'mode': self.mode,
            'steps': [step.to_dict() for step in self.steps]
        }


class ExecutionStepDetail:
    """
    It represents an automation execution summary.
    """
    def __init__(self):
        """
        Initializes the App State.
        """
        self.step_number = ""
        self.step_name = ""
        self.action = ""
        self.execution_start_time = ""
        self.execution_end_time = ""
        self.step_status = ""
        self.input_payload = ""
        self.output_payload = ""
        self.execution_log = ""
        self.step_execution_id = ""

    def to_dict(self):
        return {
            'step_number': self.step_number,
            'step_name': self.step_name,
            'action': self.action,
            'execution_start_time': self.execution_start_time,
            'execution_end_time': self.execution_end_time,
            'step_status': self.step_status,
            'input_payload': self.input_payload,
            'output_payload': self.output_payload,
            'execution_log': self.execution_log,
            'step_execution_id': self.step_execution_id
        }


def run_experiment(event, context):

    result = ''
    status_code = 500

    try:
        input_body = event.get("body")
        if input_body:
            json_param = json.loads(input_body)
            region = json_param["region"]
            name = json_param["name"]

            client = boto3.client('fis', region_name=region)

            response = client.list_experiment_templates()

            id = ""
            for experiment in response["experimentTemplates"]:
                if experiment.get("tags", dict()).get("Name", "") == name:
                    id = experiment["id"]

            if id == "":
                result = "Error, could not find the experiment"
                status_code = 400
            else:
                client.start_experiment(experimentTemplateId=id, tags={'Name': name})
                status_code = 200
        else:
            result = "Error, incorrect post body"
            status_code = 400
    except Exception as error:
        print("Error running run_experiment " + str(error))
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def trade_matching_inbound_ingress_trade_reconciliation(region):

    logging.info("Starting TradeMatchingInboundIngressTrade Reconciliation")
    return dynamodb_dynamodb_reconciliation(region, "trade-matching-in-gateway-trade-dynamodb-store", "trade-matching-ingress-trade-dynamodb-store")


def trade_matching_inbound_ingress_settlement_reconciliation(region):

    logging.info("Starting TradeMatchingInboundIngressSettlement Reconciliation")
    return dynamodb_dynamodb_reconciliation(region, "trade-matching-in-gateway-settlement-dynamodb-store", "trade-matching-ingress-settlement-dynamodb-store")


def trade_matching_ingress_core_trade_reconciliation(region):

    logging.info("Starting TradeMatchingIngressCoreTrade Reconciliation")
    return dynamodb_rds_trade_reconciliation(region, "trade-matching-ingress-trade-dynamodb-store", "trade-matching-core-database")


def trade_matching_ingress_core_settlement_reconciliation(region):

    logging.info("Starting TradeMatchingIngressCoreSettlement Reconciliation")
    return 0;
    # return dynamodb_rds_trade_reconciliation(region, "trade-matching-ingress-settlement-dynamodb-store", "trade-matching-core-database")


def trade_matching_core_egress_trade_reconciliation(region):

    logging.info("Starting TradeMatchingCoreEgressTrade Reconciliation")
    return rds_dynamodb_trade_reconciliation(region, "trade-matching-core-database", "trade-matching-egress-trade-dynamodb-store")


def trade_matching_egress_outbound_trade_reconciliation(region):

    logging.info("Starting TradeMatchingEgressOutboundTrade Reconciliation")
    return dynamodb_dynamodb_reconciliation(region, "trade-matching-egress-trade-dynamodb-store", "trade-matching-out-gateway-trade-dynamodb-store")


def trade_matching_egress_outbound_settlement_reconciliation(region):
    logging.info("Starting TradeMatchingEgressOutboundSettlement Reconciliation")
    return dynamodb_dynamodb_reconciliation(region, "trade-matching-egress-settlement-dynamodb-store", "trade-matching-out-gateway-settlement-dynamodb-store")


def trade_matching_outbound_settlement_inbound_reconciliation(region):
    logging.info("Starting TradeMatchingOutboundSettlementInbound Reconciliation")
    return dynamodb_dynamodb_reconciliation(region, "trade-matching-out-gateway-settlement-dynamodb-store", "settlement-in-gateway-settlement-dynamodb-store")


def settlement_inbound_ingress_settlement_reconciliation(region):

    logging.info("Starting SettlementInboundIngress Reconciliation")
    return dynamodb_dynamodb_reconciliation(region, "settlement-in-gateway-settlement-dynamodb-store", "settlement-ingress-settlement-dynamodb-store")


def settlement_ingress_core_settlement_reconciliation(region):

    logging.info("Starting SettlementIngressCore Reconciliation")
    return dynamodb_rds_settlement_reconciliation(region, "settlement-ingress-settlement-dynamodb-store", "settlement-core-database")


def settlement_core_egress_settlement_reconciliation(region):

    logging.info("Starting SettlementCoreEgress Reconciliation")
    return rds_dynamodb_settlement_reconciliation(region, "settlement-core-database", "settlement-egress-settlement-dynamodb-store")


def settlement_egress_outbound_settlement_reconciliation(region):

    logging.info("Starting SettlementEgressOutbound Reconciliation")
    return dynamodb_dynamodb_reconciliation(region, "settlement-egress-settlement-dynamodb-store", "settlement-out-gateway-settlement-dynamodb-store")


def settlement_outbound_trade_matching_inbound_reconciliation(region):

    logging.info("Starting Settlement Outbound Trade Matching Inbound Reconciliation")
    return dynamodb_dynamodb_reconciliation(region, "settlement-out-gateway-settlement-dynamodb-store", "trade-matching-in-gateway-settlement-dynamodb-store")


def dynamodb_dynamodb_reconciliation(region, table1, table2):

    logging.info("Starting DynamoDB and DynamoDB Reconciliation : " + table1 + " " + table2)
    try:

        source_items = query_source_dynamodb_items(ROLLBACK_TIME_IN_SECONDS, table1, region)

        logging.info("Checking for {0} records".format(len(source_items)))

        missing_items = query_destination_dynamodb_items(source_items, ROLLBACK_TIME_IN_SECONDS, table2, region)

        logging.info("Found {0} Messages to Reconcile".format(len(missing_items)))

        return len(missing_items)

    except Exception as e:
        logging.error("Error in DynamoDB and DynamoDB Reconciliation : " + table1 + " " + table2, e)
        return 0


def dynamodb_rds_trade_reconciliation(region, table1, table2):

    logging.info("Starting DynamoDB and RDS Reconciliation : " + table1 + " " + table2)

    try:
        source_items = query_source_dynamodb_items(ROLLBACK_TIME_IN_SECONDS, table1, region)

        logging.info("Checking for {0} records".format(len(source_items)))

        missing_items = query_destination_rds_trades(source_items, table2, region)

        logging.info("Found {0} Messages to Reconcile".format(len(missing_items)))

        return len(missing_items)

    except Exception as e:
        logging.error("Error in DynamoDB and RDS Reconciliation : " + table1 + " " + table2, e)
        return 0


def dynamodb_rds_settlement_reconciliation(region, table1, table2):

    logging.info("Starting DynamoDB and RDS Reconciliation : " + table1 + " " + table2)

    try:
        source_items = query_source_dynamodb_items(ROLLBACK_TIME_IN_SECONDS, table1, region)

        logging.info("Checking for {0} records".format(len(source_items)))

        missing_items = query_destination_rds_settlements(source_items, table2, region)

        logging.info("Found {0} Messages to Reconcile".format(len(missing_items)))

        return len(missing_items)

    except Exception as e:
        logging.error("Error in DynamoDB and RDS Reconciliation : " + table1 + " " + table2, e)
        return 0


def rds_dynamodb_trade_reconciliation(region, table1, table2):

    logging.info("Starting RDS and DynamoDB Reconciliation : " + table1 + " " + table2)

    try:
        source_items = query_source_rds_trades(ROLLBACK_TIME_IN_SECONDS, table1, region)

        logging.info("Checking for {0} records".format(len(source_items)))

        ids = []
        for item in source_items:
            ids.append(item["uuid"])

        missing_items = query_destination_dynamodb_items(ids, ROLLBACK_TIME_IN_SECONDS, table2, region)

        logging.info("Found {0} Messages to Reconcile".format(len(missing_items)))

        return len(missing_items)

    except Exception as e:
        logging.error("Error in RDS and DynamoDB Reconciliation : " + table1 + " " + table2, e)
        return 0


def rds_dynamodb_settlement_reconciliation(region, table1, table2):

    logging.info("Starting RDS and DynamoDB Reconciliation : " + table1 + " " + table2)

    try:
        source_items = query_source_rds_settlements(ROLLBACK_TIME_IN_SECONDS, table1, region)

        logging.info("Checking for {0} records".format(len(source_items)))

        ids = []
        for item in source_items:
            ids.append(item["uuid"])

        missing_items = query_destination_dynamodb_items(ids, ROLLBACK_TIME_IN_SECONDS, table2, region)

        logging.info("Found {0} Messages to Reconcile".format(len(missing_items)))

        return len(missing_items)

    except Exception as e:
        logging.error("Error in RDS and DynamoDB Reconciliation : " + table1 + " " + table2, e)
        return 0


def is_global_cluster_available(app, component):

    aws_region = "us-east-1"

    client = boto3.client('secretsmanager', region_name=aws_region)
    global_cluster_name = client.get_secret_value(SecretId=(app + "-" + component + "-database-cluster"))['SecretString']

    client = boto3.client('rds', region_name=aws_region)
    response = client.describe_global_clusters(GlobalClusterIdentifier=global_cluster_name)
    available = response["GlobalClusters"][0]["Status"] == "available"
    print("Global Database Cluster Available : " + global_cluster_name + " " + str(available))
    return available


def query_source_dynamodb_items(rollback_time_in_sec: str, table_name: str, region: str):
    partition_dates = get_partition_dates(rollback_time_in_sec)
    dynamodb_client = boto3.client("dynamodb", region_name=region)
    start_time = str(int(time.time() - int(rollback_time_in_sec)))
    results = []
    for day in partition_dates:
        logging.info("Querying {0} for : {1}".format(table_name, day))
        response = dynamodb_client.query(
            TableName=table_name,
            IndexName="currentDate",
            KeyConditionExpression='#currentDate = :currentDate and #timestamp > :timestamp',
            ExpressionAttributeNames={"#currentDate": "currentDate", "#timestamp": "timestamp"},
            ExpressionAttributeValues={
                ':currentDate': {'S': day},
                ":timestamp": {"N": start_time}
            },
            ProjectionExpression="id",
            ScanIndexForward=False
            # add filter - description is not there for dejon future!
        )
        # logging.info(response)
        if response["Count"] > 0:
            results.extend(response['Items'])
    ids = []
    for item in results:
        ids.append(item["id"]["S"])
    return ids


def query_destination_dynamodb_items(source_ids: [], rollback_time_in_sec: str, table_name: str, region: str):
    results = []
    batch_max = 100
    batch_ids = []
    partition_dates = get_partition_dates(rollback_time_in_sec)
    batch_id = 1
    # split the ids to batches to run efficient queries
    for trx_id in source_ids:
        batch_ids.append(trx_id)
        if len(batch_ids) == batch_max:
            processed_batch = query_dynamo_db_batch(batch_id, batch_ids, partition_dates, rollback_time_in_sec, table_name, region)
            results.extend(processed_batch)
            batch_id = batch_id + 1
            batch_ids.clear()
        else:
            continue

    if len(batch_ids) > 0:
        results.extend(query_dynamo_db_batch(batch_id, batch_ids, partition_dates, rollback_time_in_sec, table_name, region))

    return find_diff(source_ids, results)


def get_partition_dates(rollback_time_in_sec: str) -> []:
    # logging.info(rollback_time_in_sec)
    partition_dates = []
    delta = timedelta(days=1)
    now = datetime.now()
    end_date = now.date()
    diff = now - timedelta(seconds=int(rollback_time_in_sec))
    start_date = diff.date()

    while start_date <= end_date:
        partition_dates.append(start_date.strftime("%Y-%m-%d"))
        start_date += delta
    logging.info(partition_dates)
    return partition_dates


def query_dynamo_db_batch(batch_id, ids: [], partition_dates: [], rollback_time_in_sec, table_name, region, full_mode=False):
    results = []
    ids_template = []
    expression_attribute_values = {}
    start_time = str(int(time.time() - int(rollback_time_in_sec)))
    for i in range(len(ids)):
        current_id = ":id" + str(i)
        ids_template.append(current_id)
        expression_attribute_values[current_id] = {"S": ids[i]}
    expression_attribute_values[":timestamp"] = {"N": start_time}
    dynamodb_client = boto3.client("dynamodb", region_name=region)
    # breakpoint()
    for day in partition_dates:
        logging.info("Query destination table {0} with batch {1} against partition {2}".format(table_name, batch_id, day))
        expression_attribute_values[":currentDate"] = {'S': day}
        if full_mode:
            response = dynamodb_client.query(
                TableName=table_name,
                IndexName="currentDate",
                KeyConditionExpression='#currentDate = :currentDate and #timestamp > :timestamp',
                ExpressionAttributeNames={"#currentDate": "currentDate", "#timestamp": "timestamp"},
                FilterExpression="id IN (" + ','.join(ids_template) + ")",
                ExpressionAttributeValues=expression_attribute_values,
                ScanIndexForward=False
            )
            if response["Count"] > 0:
                for found_id in response["Items"]:
                    results.append(found_id)
        else:
            response = dynamodb_client.query(
                TableName=table_name,
                IndexName="currentDate",
                KeyConditionExpression='#currentDate = :currentDate and #timestamp > :timestamp',
                ExpressionAttributeNames={"#currentDate": "currentDate", "#timestamp": "timestamp"},
                FilterExpression="id IN (" + ','.join(ids_template) + ")",
                ProjectionExpression="id",
                ExpressionAttributeValues=expression_attribute_values,
                ScanIndexForward=False
            )
            if response["Count"] > 0:
                for found_id in response["Items"]:
                    results.append(found_id['id']['S'])

    return results


def query_destination_rds_trades(source_trades: [], table, region):
    db_params = get_secret(table, region)
    results = []
    if len(source_trades) == 0:
        return results
    ids = str(",".join("'{0}'".format(i) for i in source_trades))
    query = "Select uuid from trade_message where uuid IN ({0})".format(ids)
    query_results = query_rds(db_params=db_params, query=query)

    if len(query_results) > 0:
        for item in query_results:
            results.append(item[0])
    diff = find_diff(source_trades, results)
    return diff


def query_destination_rds_settlements(source_trades: [], table, region):
    db_params = get_secret(table, region)
    results = []
    if len(source_trades) == 0:
        return results
    ids = str(",".join("'{0}'".format(i) for i in source_trades))
    query = "Select id from settlement_message where id IN ({0})".format(ids)
    query_results = query_rds(db_params=db_params, query=query)

    if len(query_results) > 0:
        for item in query_results:
            results.append(item[0])
    diff = find_diff(source_trades, results)
    return diff


def query_source_rds_trades(rollback_time_in_sec, table, region):
    db_params = get_secret(table, region)
    results = []
    allocations = {}
    start_time = str(int(time.time() - int(rollback_time_in_sec)))
    logging.info(start_time)
    query = "Select * from trade_message tm " \
            "join trade_allocation ta on tm.id = ta.trade_message_id " \
            "where tm.timestamp >{0} and (tm.status='MATCHED' or tm.status='MISMATCHED')".format(start_time)
    query_results = query_rds_realdict(db_params=db_params, query=query)
    if len(query_results) > 0:
        results = core_trade_db_mapper(query_results)

    return results


def query_source_rds_settlements(rollback_time_in_sec, table, region):
    db_params = get_secret(table, region)
    results = []
    allocations = {}
    start_time = str(int(time.time() - int(rollback_time_in_sec)))
    logging.info(start_time)
    query = "Select * from settlement_message where status='Settled'"
    query_results = query_rds_realdict(db_params=db_params, query=query)
    if len(query_results) > 0:
        results = core_settlement_db_mapper(query_results)

    return results


def find_diff(list1: [], list2: []) -> []:
    return list(set(list1).difference(list2))


def query_rds(db_params, query):
    # params = json.loads(db_params)
    params = db_params
    host = params["host"]
    dbname = params["dbname"]
    username = params["username"]
    password = params["password"]
    conn = None
    results = None

    try:
        conn = psycopg2.connect(
            host=host,
            database=dbname,
            user=username,
            password=password)
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute(query)
        results = cur.fetchall()
    except (Exception, psycopg2.DatabaseError) as error:
        logging.error(error)
    finally:
        if conn is not None:
            conn.close()
            print('Database connection closed.')
    return results


def update_rds(db_params, query):
    # params = json.loads(db_params)
    params = db_params
    host = params["host"]
    dbname = params["dbname"]
    username = params["username"]
    password = params["password"]
    conn = None
    results = None

    try:
        conn = psycopg2.connect(
            host=host,
            database=dbname,
            user=username,
            password=password)
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute(query)
        conn.commit()
    except (Exception, psycopg2.DatabaseError) as error:
        logging.error(error)
    finally:
        if conn is not None:
            conn.close()
            print('Database connection closed.')
    return results


def query_rds_realdict(db_params, query):
    # params = json.loads(db_params)
    params = db_params
    host = params["host"]
    dbname = params["dbname"]
    username = params["username"]
    password = params["password"]
    conn = None
    results = None
    try:
        conn = psycopg2.connect(
            host=host,
            database=dbname,
            user=username,
            password=password,
            cursor_factory=RealDictCursor)
        cur = conn.cursor()
        cur.execute(query)
        results = cur.fetchall()
    except (Exception, psycopg2.DatabaseError) as error:
        logging.error(error)
    finally:
        if conn is not None:
            conn.close()
            print('Database connection closed.')
    return results


def convert_db_date(timestamp_input):
    #2020-02-22T16:37:23
    return timestamp_input.strftime('%Y-%m-%dT%H:%M:%SZ')


def core_trade_db_mapper(items: []):
    results = {}

    for item in items:
        # logging.info(item)
        rec_id = item["uuid"]
        record = {
            "id": rec_id,
            "uuid": item["uuid"],
            "curr_date": item["curr_date"],
            "curr_time": item["curr_time"],
            "sender_id": item["sender_id"],
            "im_id": item["im_id"],
            "broker_id": item["broker_id"],
            "trade_id": item["trade_id"],
            "security": item["security"],
            "transaction_indicator": item["transaction_indicator"],
            "price": str(item["price"]),
            "quantity": item["quantity"],
            "trade_date": convert_db_date(item["trade_date"]),
            "settlement_date": convert_db_date(item["settlement_date"]),
            "delivery_instructions": item["delivery_instructions"],
            "status": item["status"],
            "timestamp": ''  # str(item["timestamp"])
            # "allocations": []
        }

        single_allocation = {
            "tradeAllocationID": item["trade_allocation_id"],
            "allocationQuantity": item["allocation_quantity"],
            "allocationAccount": item["allocation_account"],
            "allocationStatus": item["allocation_status"]
        }

        if rec_id in results:
            existing_record = results[rec_id]
            existing_record["allocations"].append(single_allocation)
        else:
            allocation_collection = [single_allocation]
            record["allocations"] = allocation_collection
            results[rec_id] = record

    return list(results.values())


def core_settlement_db_mapper(items: []):
    results = []
    # logging.info(items[0])
    # breakpoint()
    #
    for item in items:
        # logging.info(item)
        record = {
            "id": item["id"],
            "currentDate": item["curr_date"],
            "currentTime": item["curr_time"],
            "timestamp": '',
            "senderID": item["sender_id"],
            "imID": item["im_id"],
            "brokerID": item["broker_id"],
            "tradeID": item["trade_id"],
            "allocationID": int(item["allocation_id"]),
            "quantity": int(item["quantity"]),
            "security": item["security"],
            "transactionIndicator": item["transaction_indicator"],
            "price": float(item["price"]),
            "tradeDate": convert_db_date(item["trade_date"]),
            "settlementDate": convert_db_date(item["settlement_date"]),
            "deliveryInstructions": item["delivery_instructions"],
            "status": item["status"],
            "account": item["account"],
        }
        results.append(record)

    return results


def trade_matching_settlement_outbound_inbound_settlement_mapper(item):
    logging.info(item)
    breakpoint()
    return item


def invoke_command():

    # params = {"queryStringParameters": {"app": "settlement", "scope": "app", "region": "us-east-1", "state": "On"}}
    # response = get_arc_control_state("trade-matching", "dns", "us-east-1")
    event = dict()
    # event["body"] = """{"region": "us-east-1", "document": "Test001", "app": "trade-matching", "type": "App Rotation", "mode": "test"}"""
    # event["body"] = """{"app": "trade-matching"}"""

    # if recon == "TM-INBOUND-INGRESS-T":
    #     result_value = g(region)
    # elif recon == "TM-INBOUND-INGRESS-S":
    #     result_value = trade_matching_inbound_ingress_settlement_reconciliation(region)
    # elif recon == "TM-INGRESS-CORE-T":
    #     result_value = trade_matching_ingress_core_trade_reconciliation(region)
    # elif recon == "TM-INGRESS-CORE-S":
    #     result_value = trade_matching_ingress_core_settlement_reconciliation(region)
    # elif recon == "TM-CORE-EGRESS-T":
    #     if is_global_cluster_available("trade-matching", "core"):
    #         result_value = trade_matching_core_egress_trade_reconciliation(region)
    # elif recon == "TM-EGRESS-OUTBOUND-T":
    #     result_value = trade_matching_egress_outbound_trade_reconciliation(region)
    # elif recon == "TM-EGRESS-OUTBOUND-S":
    #     result_value = trade_matching_egress_outbound_settlement_reconciliation(region)
    # elif recon == "TM-OUTBOUND-SM-INBOUND-S":
    #     result_value = trade_matching_outbound_settlement_inbound_reconciliation(region)
    # elif recon == "SM-INBOUND-INGRESS-S":
    #     result_value = settlement_inbound_ingress_settlement_reconciliation(region)
    # elif recon == "SM-INGRESS-CORE-S":
    #     result_value = settlement_ingress_core_settlement_reconciliation(region)
    # elif recon == "SM-CORE-EGRESS-S":
    #     if is_global_cluster_available("settlement", "core"):
    #         result_value = settlement_core_egress_settlement_reconciliation(region)
    # elif recon == "SM-EGRESS-OUTBOUND-S":
    #     result_value = settlement_egress_outbound_settlement_reconciliation(region)
    # elif recon == "SM-OUTBOUND-TM-INBOUND-S":
    #     result_value = settlement_outbound_trade_matching_inbound_reconciliation(region)

    # params = {"queryStringParameters": {"recon": "TM-INBOUND-INGRESS-T"}}
    # response = get_app_recon_step(params, None)
    # print(response)
    #
    # params = {"queryStringParameters": {"recon": "TM-INBOUND-INGRESS-S"}}
    # response = get_app_recon_step(params, None)
    # print(response)
    #
    # params = {"queryStringParameters": {"recon": "TM-INGRESS-CORE-T"}}
    # response = get_app_recon_step(params, None)
    # print(response)
    #
    # params = {"queryStringParameters": {"recon": "TM-INGRESS-CORE-S"}}
    # response = get_app_recon_step(params, None)
    # print(response)
    #
    # params = {"queryStringParameters": {"recon": "TM-CORE-EGRESS-T"}}
    # response = get_app_recon_step(params, None)
    # print(response)
    #
    # params = {"queryStringParameters": {"recon": "TM-EGRESS-OUTBOUND-T"}}
    # response = get_app_recon_step(params, None)
    # print(response)
    #
    # params = {"queryStringParameters": {"recon": "TM-EGRESS-OUTBOUND-S"}}
    # response = get_app_recon_step(params, None)
    # print(response)
    #
    # params = {"queryStringParameters": {"recon": "TM-OUTBOUND-SM-INBOUND-S"}}
    # response = get_app_recon_step(params, None)
    # print(response)
    #
    # params = {"queryStringParameters": {"recon": "SM-INBOUND-INGRESS-S"}}
    # response = get_app_recon_step(params, None)
    # print(response)
    #
    # params = {"queryStringParameters": {"recon": "SM-INGRESS-CORE-S"}}
    # response = get_app_recon_step(params, None)
    # print(response)
    #
    # params = {"queryStringParameters": {"recon": "SM-CORE-EGRESS-S"}}
    # response = get_app_recon_step(params, None)
    # print(response)
    #
    # params = {"queryStringParameters": {"recon": "SM-EGRESS-OUTBOUND-S"}}
    # response = get_app_recon_step(params, None)
    # print(response)
    #
    # params = {"queryStringParameters": {"recon": "SM-OUTBOUND-TM-INBOUND-S"}}
    # response = get_app_recon_step(params, None)
    # print(response)

    # params = {"queryStringParameters": {"id": "8072f773-2e54-4869-be82-e466f0857472"}}
    # response = get_execution_detail(params, None)
    # print(response)

    # event = dict()
    # event["body"] = """{"region":"us-east-1","name":"tm-in-gateway-stop-all-ECS-instances"}"""
    # run_experiment(event, None)

    # event = dict()
    # event["body"] = """{"region":"us-east-1","app":"trade-matching", "component":"in-gateway"}"""
    # start_tasks_for_app_component(event, None)

    # event = dict()
    # event["body"] = """{"region":"us-east-1","app":"trade-matching","service":"kinesis-streams"}"""
    # disable_vpc_endpoint_for_service(event, None)

    event = dict()
    event["body"] = """{"region":"us-east-1","app":"trade-matching","service":"kinesis-streams"}"""
    enable_vpc_endpoint(event, None)

if __name__ == "__main__":
    invoke_command()


