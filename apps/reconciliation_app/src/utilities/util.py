# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import os
import ssl
import time
import traceback
from datetime import datetime
import random
import boto3
import botocore
import json
import logging
import psycopg2
from psycopg2.extras import RealDictCursor
import string
import random
import sys
import stomp
from stomp.exception import ConnectFailedException

def enable_logging():
    root = logging.getLogger()
    if root.handlers:
        for handler in root.handlers:
            root.removeHandler(handler)
    logging.basicConfig(format='%(asctime)s %(message)s', level=logging.INFO)


def get_secret(secret_name, region):
    """
        Get the secret dictionary - key/value
    :param secret_name: the name of the secret
    :param region: the region where the secret is located
    :return: the secret dictionary
    """
    secret = None
    # Create a Secrets Manager client
    session = boto3.session.Session()
    # print("before secret")
    # endpoint_url = "https://secretsmanager.us-east-2.amazonaws.com"
    client = session.client(
        service_name='secretsmanager',
        region_name=region
        # endpoint_url=endpoint_url
    )
    # endpoint_url='https://secretsmanager.us-west-2.amazonaws.com'

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except botocore.exceptions.ClientError as e:
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
    # print("after secret")
    if isinstance(secret, str):
        return secret
    return json.loads(secret)  # returns the secret as dictionary


def get_params(region: str) -> dict:
    params = {}
    ssm = boto3.client('ssm', region_name=region)
    # dynamodb_inbound_table = ssm.get_parameter(Name='/approtation/trade-matching/in-gateway/dynamodb', WithDecryption=True)
    # dynamodb_ingress_table = ssm.get_parameter(Name='/approtation/trade-matching/ingress/dynamodb', WithDecryption=True)
    # dynamodb_egress_table = ssm.get_parameter(Name='/approtation/trade-matching/egress-trade/dynamodb', WithDecryption=True)
    # dynamodb_egress_settlement_table = ssm.get_parameter(Name='/approtation/trade-matching/egress-settlement/dynamodb', WithDecryption=True)
    # dynamodb_outbound_table = ssm.get_parameter(Name='/approtation/trade-matching/out-gateway-trade/dynamodb', WithDecryption=True)
    # dynamodb_outbound_settlement_table = ssm.get_parameter(Name='/approtation/trade-matching/out-gateway-settlement/dynamodb', WithDecryption=True)
    dynamodb_tm_inbound_t_table = get_secret("trade-matching-in-gateway-trade-dynamodb", region)
    dynamodb_tm_inbound_st_table = get_secret("trade-matching-in-gateway-settlement-dynamodb", region)

    dynamodb_tm_ingress_t_table = get_secret("trade-matching-ingress-trade-dynamodb", region)
    dynamodb_tm_ingress_st_table = get_secret("trade-matching-ingress-settlement-dynamodb", region)

    dynamodb_tm_egress_t_table = get_secret("trade-matching-egress-trade-dynamodb", region)
    dynamodb_tm_egress_st_table = get_secret("trade-matching-egress-settlement-dynamodb", region)

    dynamodb_tm_outbound_t_table = get_secret("trade-matching-out-gateway-trade-dynamodb", region)
    dynamodb_tm_outbound_st_table = get_secret("trade-matching-out-gateway-settlement-dynamodb", region)

    dynamodb_recon_audit = get_secret("recon-audit-dynamodb", region)

    dynamodb_st_inbound_st_table = get_secret("settlement-in-gateway-settlement-dynamodb", region)
    dynamodb_st_ingress_st_table = get_secret("settlement-ingress-settlement-dynamodb", region)
    dynamodb_st_egress_st_table = get_secret("settlement-egress-settlement-dynamodb", region)
    dynamodb_st_outbound_st_table = get_secret("settlement-out-gateway-settlement-dynamodb", region)

    kinesis_stream_ingress_t = ssm.get_parameter(Name='/approtation/trade-matching/ingress-trade/kinesis', WithDecryption=True)
    kinesis_stream_ingress_st = ssm.get_parameter(Name='/approtation/trade-matching/ingress-settlement/kinesis', WithDecryption=True)
    kinesis_stream_egress_t = ssm.get_parameter(Name='/approtation/trade-matching/egress-trade/kinesis', WithDecryption=True)
    kinesis_stream_egress_st = ssm.get_parameter(Name='/approtation/trade-matching/egress-settlement/kinesis', WithDecryption=True)

    kinesis_stream_core_t = ssm.get_parameter(Name='/approtation/trade-matching/core-trade/kinesis', WithDecryption=True)
    kinesis_stream_core_st = ssm.get_parameter(Name='/approtation/trade-matching/core-settlement/kinesis', WithDecryption=True)

    kinesis_stream_outbound_t = ssm.get_parameter(Name='/approtation/trade-matching/out-gateway-trade/kinesis', WithDecryption=True)
    kinesis_stream_outbound_st = ssm.get_parameter(Name='/approtation/trade-matching/out-gateway-settlement/kinesis',
                                                WithDecryption=True)

    kinesis_settlement_stream_ingress = ssm.get_parameter(Name='/approtation/settlement/ingress-settlement/kinesis', WithDecryption=True)
    kinesis_settlement_stream_core = ssm.get_parameter(Name='/approtation/settlement/core-settlement/kinesis', WithDecryption=True)
    kinesis_settlement_stream_egress = ssm.get_parameter(Name='/approtation/settlement/egress-settlement/kinesis', WithDecryption=True)
    kinesis_settlement_stream_outbound = ssm.get_parameter(Name='/approtation/settlement/out-gateway-settlement/kinesis', WithDecryption=True)

    rollback_time_in_sec = ssm.get_parameter(Name='/approtation/reconciliation/roll-back-time', WithDecryption=True)
    trade_matching_core_database = get_secret("trade-matching-core-database", region)
    settlement_core_database = get_secret("settlement-core-database", region)

    trade_matching_in_gateway_mq = get_secret("trade-matching-in-gateway-mq-connection", region)
    trade_matching_out_gateway_mq = get_secret("trade-matching-out-gateway-mq-connection", region)
    settlement_in_gateway_mq = get_secret("settlement-in-gateway-mq-connection", region)
    settlement_out_gateway_mq = get_secret("settlement-out-gateway-mq-connection", region)

    params["dynamodb_tm_inbound_t_table"] = dynamodb_tm_inbound_t_table
    params["dynamodb_tm_inbound_st_table"] = dynamodb_tm_inbound_st_table
    params["dynamodb_tm_ingress_t_table"] = dynamodb_tm_ingress_t_table
    params["dynamodb_tm_ingress_st_table"] = dynamodb_tm_ingress_st_table
    params["dynamodb_tm_egress_t_table"] = dynamodb_tm_egress_t_table
    params["dynamodb_tm_egress_st_table"] = dynamodb_tm_egress_st_table
    params["dynamodb_tm_outbound_t_table"] = dynamodb_tm_outbound_t_table
    params["dynamodb_tm_outbound_st_table"] = dynamodb_tm_outbound_st_table

    params["dynamodb_st_inbound_st_table"] = dynamodb_st_inbound_st_table
    params["dynamodb_st_ingress_st_table"] = dynamodb_st_ingress_st_table
    params["dynamodb_st_egress_st_table"] = dynamodb_st_egress_st_table
    params["dynamodb_st_outbound_st_table"] = dynamodb_st_outbound_st_table

    params["kinesis_stream_ingress_t"] = kinesis_stream_ingress_t['Parameter']['Value']
    params["kinesis_stream_ingress_st"] = kinesis_stream_ingress_st['Parameter']['Value']
    params["kinesis_stream_egress_t"] = kinesis_stream_egress_t['Parameter']['Value']
    params["kinesis_stream_egress_st"] = kinesis_stream_egress_st['Parameter']['Value']
    params["kinesis_stream_core_t"] = kinesis_stream_core_t['Parameter']['Value']
    params["kinesis_stream_core_st"] = kinesis_stream_core_st['Parameter']['Value']

    params["kinesis_stream_outbound_t"] = kinesis_stream_outbound_t['Parameter']['Value']
    params["kinesis_stream_outbound_st"] = kinesis_stream_outbound_st['Parameter']['Value']

    params["kinesis_settlement_stream_ingress"] = kinesis_settlement_stream_ingress['Parameter']['Value']
    params["kinesis_settlement_stream_core"] = kinesis_settlement_stream_core['Parameter']['Value']
    params["kinesis_settlement_stream_egress"] = kinesis_settlement_stream_egress['Parameter']['Value']
    params["kinesis_settlement_stream_outbound"] = kinesis_settlement_stream_outbound['Parameter']['Value']

    params["rollback_time_in_sec"] = rollback_time_in_sec['Parameter']['Value']
    params["trade_matching_core_database"] = trade_matching_core_database
    params["settlement_core_database"] = settlement_core_database
    params["trade_matching_in_gateway_mq"] = trade_matching_in_gateway_mq
    params["trade_matching_out_gateway_mq"] = trade_matching_out_gateway_mq
    params["settlement_in_gateway_mq"] = settlement_in_gateway_mq
    params["settlement_out_gateway_mq"] = settlement_out_gateway_mq

    params["reconciliation_table"] = dynamodb_recon_audit
    logging.info(params)
    return params


def find_diff(list1: [], list2: []) -> []:
    return list(set(list1).difference(list2))


def distribute_messages_to_kinesis(stream_name: str, records: [], source: [], region: str, mapping_func, override_partition_key=False):
    client = boto3.client('kinesis', region_name=region)
    ids = dict.fromkeys(records)
    i = 1
    logging.info("Starting distributing of messages to {0}".format(stream_name))
    for item in source:
        # logging.info(item)
        record = mapping_func(item)
        rec_id = None
        if 'id' in record:
            rec_id = record['id']
        if rec_id in ids:
            if i % 10 == 0:
                logging.info("Reconcile {0} Messages".format(i))
            i = i + 1

            if override_partition_key:
                record['id'] = random.randint(10000, 500000)
                partition_key = ''.join(random.choices(string.ascii_letters + string.digits, k=16))
                # logging.info("Custom partition_key key " + partition_key)
                # logging.info(record)
                response = client.put_record(
                    StreamName=stream_name,
                    Data=json.dumps(record),
                    PartitionKey=partition_key
                )
            else:
                response = client.put_record(
                    StreamName=stream_name,
                    Data=json.dumps(record),
                    PartitionKey=rec_id
                )
    logging.info("Reconcile total of {0} Messages".format(len(records)))
    # #TODO: Update support for larger messages up to 1MB
    # response = client.put_records(
    #     Records=[
    #         {
    #             'Data': b'bytes',
    #             'ExplicitHashKey': 'string',
    #             'PartitionKey': 'string'
    #         },
    #     ],
    #     StreamName=stream_name
    # )


def query_rds(db_params, query):
    params = json.loads(db_params)
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


def query_rds_realdict(db_params, query):
    params = json.loads(db_params)
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


def check_table_exist(table_name, region):
    dynamodb_client = boto3.client('dynamodb', region_name=region)
    result = False
    try:
        response = dynamodb_client.describe_table(TableName=table_name)
        result = True
    except dynamodb_client.exceptions.ResourceNotFoundException:
        # do something here as you require
        result = False
    return result


def create_table(table_name, region):
    # dynamodb = boto3.resource('dynamodb', region_name=region)
    # breakpoint()
    # try:
    #     table = dynamodb.create_table(
    #         TableName=table_name,
    #         KeySchema=[
    #             {
    #                 'AttributeName': 'id',
    #                 'KeyType': 'HASH'
    #             },
    #         ],
    #         AttributeDefinitions=[
    #             {
    #                 'AttributeName': 'id',
    #                 'AttributeType': 'S'
    #             },
    #         ],
    #         ProvisionedThroughput={
    #             'ReadCapacityUnits': 1,
    #             'WriteCapacityUnits': 1,
    #         }
    #     )
    #     logging.info("Table Status: " + table.table_status)
    # except Exception as e:
    #     logging.error("Error in create_table", e)
    #     return False
    return True


def id_generator(size=6, chars=string.ascii_uppercase + string.digits):
    return ''.join(random.choice(chars) for _ in range(size))


def add_reconciliation_record(table_name, region, job_type, record_type, status, source_records=0, missing_records=0, info="N/A"):
    dynamodb = boto3.resource('dynamodb', region_name=region)
    try:
        table = dynamodb.Table(table_name)
        key_ts = str(datetime.now().strftime("%Y-%m-%d %H%M%S")) + "-" + id_generator(size=4)
        table.put_item(Item={
            'id': key_ts,
            'region': region,
            'currentDate': str(datetime.now().strftime("%Y-%m-%d")),
            'currentTime': str(datetime.now().strftime("%H%M%S")),
            'jobType': job_type,
            'recordType': record_type,
            "timestamp": int(time.time()),
            "source": int(source_records),
            "missing": int(missing_records),
            "replay": int(missing_records),
            "status": status,
            "info": info

        })

    except Exception as e:
        logging.error("Error in add_reconciliation_record", e)


def distribute_message_activemq(records: [], source: [], region: str, mapping_func, activemq_params,
                                queue_name="settlements",
                                operation="settlement"):
    try:

        params = json.loads(activemq_params)

        endpoint = params["endpoint"]
        username = params["username"]
        password = params["password"]

        ids = dict.fromkeys(records)
        host, port = split_host_port(endpoint)
        port = 61614
        # host = 'b-011fb7ca-af6e-4ede-916c-143f6a744918-1.mq.us-east-1.amazonaws.com'
        # conn = stomp.Connection([(host, port)])
        conn = stomp.connect.StompConnection12([(host, port)], auto_content_length=False)

        # cert_file='/path/to/client.pem' ca_certs='/path/to/broker.pem'

        if region.lower() == "us-east-1":
            if operation == "settlement":
                cert_path = os.getenv('CERT_SETTLEMENT_IN_PATH_US_EAST1')
                cert_pk_path = os.getenv('CERT_SETTLEMENT_IN_PK_PATH_US_EAST1')
            else:
                cert_path = os.getenv('CERT_TRADE_IN_PATH_US_EAST1')
                cert_pk_path = os.getenv('CERT_TRADE_IN_PK_PATH_US_EAST1')
        elif region.lower() == "us-west-2":
            if operation == "settlement":
                cert_path = os.getenv('CERT_SETTLEMENT_IN_PATH_US_WEST2')
                cert_pk_path = os.getenv('CERT_SETTLEMENT_IN_PK_PATH_US_WEST2')
            else:
                cert_path = os.getenv('CERT_TRADE_IN_PATH_US_WEST2')
                cert_pk_path = os.getenv('CERT_TRADE_IN_PK_PATH_US_WEST2')

        logging.info(cert_path)
        logging.info(cert_pk_path)
        # CERT_SETTLEMENT_OUT_PATH_US_EAST1
        # CERT_SETTLEMENT_OUT_PATH_US_WEST2
        # CERT_TRADE_OUT_PATH_US_EAST1
        # CERT_TRADE_OUT_PATH_US_WEST2
        # override port
        # conn = stomp.Connection(host_and_ports=[(host, port)], use_ssl=True,
        #                         ssl_key_file=cert_pk_path, ssl_cert_file=cert_path)

        # conn.set_ssl(for_hosts=[(host, port)], ssl_version=ssl.PROTOCOL_TLSv1_2)
        conn.set_ssl(for_hosts=[(host, port)], ssl_version=ssl.PROTOCOL_TLS)

        logging.info("Starting distributing to ActiveMQ {0} messages".format(len(records)))
        # conn.connect(username=username, password=password, wait=True, reconnect_attempts_max=10, headers={'client-id': 'python-recon'})
        conn.connect(username=username, passcode=password, wait=True)
        logging.info("Connection to Queue {0} established".format(endpoint))
        i = 1
        for item in source:
            # logging.info(item)
            record = mapping_func(item)
            rec_id = None
            if 'id' in record:
                rec_id = record['id']
            if rec_id in ids:
                if i % 10 == 0:
                    logging.info("Reconcile {0} Messages".format(i))
                i = i + 1
                logging.info("Sending {0}".format(record))
                # conn.send(body=json.dumps(record), destination=queue_name)
                conn.send(headers={'content-type': 'text/plain', 'correlation-id': record['id']}, body=json.dumps(record),
                          destination=queue_name, persistent='true', suppress_content_length=True)
        logging.info("Reconcile total of {0} Messages".format(len(records)))

        conn.disconnect()
    except ConnectFailedException as err:
        logging.error(err)
        traceback.print_exc()
    except Exception as e:
        logging.error(e)
        traceback.print_exc()


def split_host_port(endpoint):
    if not endpoint.rsplit(':', 1)[-1].isdigit():
        return endpoint, None

    endpoint = endpoint.rsplit(':', 1)
    # host = endpoint[0]
    host = endpoint[0].rsplit('//', 2)
    port = int(endpoint[1])
    return host[1], port
