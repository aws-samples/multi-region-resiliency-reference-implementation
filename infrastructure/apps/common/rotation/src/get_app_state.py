import json
from datetime import datetime

from botocore.exceptions import ClientError
import boto3
import logging
import traceback
# import psycopg2
# from psycopg2.extras import RealDictCursor
import base64


def get_app_state(event, context):

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " get_app_state Invoked")
    region = event['AWS_REGION']

    app_state = AppState()

    # try:

    dynamodb = boto3.resource('dynamodb', region_name=region)

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + "First")
    app_state.tm_inbound_trade = get_dynamodb_table_count(dynamodb, "trade-matching-in-gateway-trade-dynamodb-store")
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + "Second")
    app_state.tm_inbound_settlement = get_dynamodb_table_count(dynamodb, "trade-matching-in-gateway-settlement-dynamodb-store")
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + "Third")
    app_state.tm_ingress_trade = get_dynamodb_table_count(dynamodb, "trade-matching-ingress-trade-dynamodb-store")
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + "Fourth")
    app_state.tm_ingress_settlement = get_dynamodb_table_count(dynamodb, "trade-matching-ingress-settlement-dynamodb-store")
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + "Fifth")
    app_state.tm_egress_trade = get_dynamodb_table_count(dynamodb, "trade-matching-egress-trade-dynamodb-store")
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + "Sixty")
    app_state.tm_egress_settlement = get_dynamodb_table_count(dynamodb, "trade-matching-egress-settlement-dynamodb-store")
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + "Seventh")
    app_state.tm_outbound_trade = get_dynamodb_table_count(dynamodb, "trade-matching-out-gateway-trade-dynamodb-store")
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + "Eight")
    app_state.tm_outbound_settlement = get_dynamodb_table_count(dynamodb, "trade-matching-out-gateway-settlement-dynamodb-store")
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + "Nine")
    app_state.sm_inbound_settlement = get_dynamodb_table_count(dynamodb, "settlement-in-gateway-settlement-dynamodb-store")
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + "Ten")
    app_state.sm_ingress_settlement = get_dynamodb_table_count(dynamodb, "settlement-ingress-settlement-dynamodb-store")
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + "Eleven")
    app_state.sm_egress_settlement = get_dynamodb_table_count(dynamodb, "settlement-egress-settlement-dynamodb-store")
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + "Twelve")
    app_state.sm_outbound_settlement = get_dynamodb_table_count(dynamodb, "settlement-out-gateway-settlement-dynamodb-store")

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + "Thirteen : \n " + json.dumps(app_state.to_dict(), indent=2, sort_keys=True, default=str))

    # connection = get_db_connection("trade-matching-core-database", region)
    # app_state.tm_core_trade = get_rds_table_count(connection, """select count(*) from trade_message tm""")
    # app_state.tm_core_allocation = get_rds_table_count(connection, """select count(*) from trade_allocation tm""")
    #
    # connection = get_db_connection("settlement-core-database", region)
    # app_state.sm_core_settlement = get_rds_table_count(connection, """select count(*) from settlement_message tm""")

    return {'app_state': json.dumps(app_state.to_dict(), default=str)}

    # return {'app_state': "99"}

    # except Exception as error:
    #     print("Error running get_app_data", error)
    #     traceback.print_exc()

    # return {
    #     'app_state': json.dumps(app_state.to_dict(), indent=2, sort_keys=True, default=str)
    # }

    # return {'app_state': json.dumps(app_state.to_dict(), indent=2, sort_keys=True, default=str)}


def compare_app_states(event, context):

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " get_app_state Invoked")
    region = event['AWS_REGION']
    # app_state_1_json = event['APP-STATE-1']
    # app_state_2_json = event['APP-STATE-2']
    #
    # app_state_1 = json.loads(app_state_1_json)
    # app_state_2 = json.loads(app_state_2_json)
    #
    # result = False
    #
    # if (app_state_1.tm_inbound_trade == app_state_2.tm_inbound_trade and
    #     app_state_1.tm_inbound_settlement == app_state_2.tm_inbound_settlement and
    #     app_state_1.tm_ingress_trade == app_state_2.tm_ingress_trade and
    #     app_state_1.tm_ingress_settlement == app_state_2.tm_ingress_settlement and
    #     app_state_1.tm_core_trade == app_state_2.tm_core_trade and
    #     app_state_1.tm_core_allocation == app_state_2.tm_core_allocation and
    #     app_state_1.tm_egress_trade == app_state_2.tm_egress_trade and
    #     app_state_1.tm_egress_settlement == app_state_2.tm_egress_settlement and
    #     app_state_1.tm_outbound_trade == app_state_2.tm_outbound_trade and
    #     app_state_1.tm_outbound_settlement == app_state_2.tm_outbound_settlement and
    #     app_state_1.sm_inbound_settlement == app_state_2.sm_inbound_settlement and
    #     app_state_1.sm_ingress_settlement == app_state_2.sm_ingress_settlement and
    #     app_state_1.sm_core_settlement == app_state_2.sm_core_settlement and
    #     app_state_1.sm_egress_settlement == app_state_2.sm_egress_settlement and
    #     app_state_1.sm_outbound_settlement == app_state_2.sm_outbound_settlement):
    #     result = True
    # else:
    #     result = False

    return {'result': True}


class AppState:
    """
    It represents the state of an App.
    """
    def __init__(self):
        """
        Initializes the App State.
        """
        self.tm_inbound_trade = 0
        self.tm_inbound_settlement = 0
        self.tm_ingress_trade = 0
        self.tm_ingress_settlement = 0
        self.tm_core_trade = 0
        self.tm_core_allocation = 0
        self.tm_egress_trade = 0
        self.tm_egress_settlement = 0
        self.tm_outbound_trade = 0
        self.tm_outbound_settlement = 0
        self.sm_inbound_settlement = 0
        self.sm_ingress_settlement = 0
        self.sm_core_settlement = 0
        self.sm_egress_settlement = 0
        self.sm_outbound_settlement = 0

    def to_dict(self):
        return {
            'tm_inbound_trade': self.tm_inbound_trade,
            'tm_inbound_settlement': self.tm_inbound_settlement,
            'tm_ingress_trade': self.tm_ingress_trade,
            'tm_ingress_settlement': self.tm_ingress_settlement,
            'tm_core_trade': self.tm_core_trade,
            'tm_core_allocation': self.tm_core_allocation,
            'tm_egress_trade': self.tm_egress_trade,
            'tm_egress_settlement': self.tm_egress_settlement,
            'tm_outbound_trade': self.tm_outbound_trade,
            'tm_outbound_settlement': self.tm_outbound_settlement,
            'sm_inbound_settlement': self.sm_inbound_settlement,
            'sm_ingress_settlement': self.sm_ingress_settlement,
            'sm_core_settlement': self.sm_core_settlement,
            'sm_egress_settlement': self.sm_egress_settlement,
            'sm_outbound_settlement': self.sm_outbound_settlement
        }


def get_dynamodb_table_count(dynamodb, dbname):

    try:
        table = dynamodb.Table(dbname)
        response = table.scan(Select='COUNT')
        return response['Count']

    except Exception as error:
        print("Error running get_dynamodb_table_count", error)
        traceback.print_exc()

    return 0


# def get_db_connection(secret_name, region_name):
#
#     connection = None
#     secret_result = get_secret(secret_name, region_name)
#     username = secret_result['username']
#     password = secret_result['password']
#     engine = secret_result['engine']
#     dbname = secret_result['dbname']
#     host = secret_result['host']
#     port = secret_result['port']
#     conn = None
#     try:
#         connection = psycopg2.connect(
#             host=host,
#             database=dbname,
#             user=username,
#             password=password,
#             port=port)
#     except (Exception, psycopg2.Error) as error:
#         if conn:
#             print("Failed to init DB connection", error)
#
#     return connection
#
#
# def get_rds_table_count(connection, query):
#
#     try:
#
#         cursor = connection.cursor(cursor_factory=RealDictCursor)
#         cursor.execute(query, )
#         records = cursor.fetchall()
#         return records[0]["count"]
#
#     except Exception as error:
#         print("Error running get_app_data", error)
#         traceback.print_exc()
#
#     return 0
#
#
# def get_secret(secret_name, region_name):
#
#     secret = None
#     session = boto3.session.Session()
#     endpoint_url = "https://secretsmanager." + region_name + ".amazonaws.com"
#     client = session.client(
#         service_name='secretsmanager',
#         region_name=region_name,
#         endpoint_url=endpoint_url
#     )
#
#     try:
#         get_secret_value_response = client.get_secret_value(SecretId=secret_name)
#     except ClientError as e:
#         if e.response['Error']['Code'] == 'DecryptionFailureException':
#             raise e
#         elif e.response['Error']['Code'] == 'InternalServiceErrorException':
#             raise e
#         elif e.response['Error']['Code'] == 'InvalidParameterException':
#             raise e
#         elif e.response['Error']['Code'] == 'InvalidRequestException':
#             raise e
#         elif e.response['Error']['Code'] == 'ResourceNotFoundException':
#             raise e
#     except Exception as e:
#         raise e
#     else:
#         if 'SecretString' in get_secret_value_response:
#             secret = get_secret_value_response['SecretString']
#         else:
#             decoded_binary_secret = base64.b64decode(get_secret_value_response['SecretBinary'])
#     return json.loads(secret)  # returns the secret as dictionary


if __name__ == "__main__":
    event = dict()
    event["AWS_REGION"] = "us-west-2"
    response = get_app_state(event, None)
    print("Response: " + str(response))


