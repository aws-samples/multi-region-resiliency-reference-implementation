import base64
import random
from datetime import datetime
import boto3
import botocore
# import psycopg2
import json


def damage_maker(event, context):

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " damage_maker Invoked")
    region = event['AWS_REGION']
    app = event['APP']
    mode = event['MODE']
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " Region: " + region + " App: " + app + " Mode: " + mode)
    if mode == 'test':
        min_rec = 1
        max_rec = 5
        print("Starting damage maker")
        tables = get_tables_app(region,  app)
        results = []
        for key, value in tables.items():
            if "dynamodb" in key:
                results.append(do_damage_dynamodb(region, value, min_rec, max_rec))
            # else:
            #     results.append(do_damage_auroradb(region, key, value, min_rec, max_rec))

        print(results)
        print("Damage maker finished.")
    else:
        print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " will not introduce damage as it is in prod mode")


def do_damage_dynamodb(region, table_name, min_rec, max_rec):
    print("Starting random deletion on table {0}".format(table_name))
    results = ""
    try:
        dynamo = boto3.resource('dynamodb', region_name=region)
        table = dynamo.Table(table_name)
        number_of_records = random.randint(min_rec, max_rec)

        table_key_names = ['id']
        projection_expression = table_key_names[0]
        response = table.scan(ProjectionExpression=projection_expression)
        data = response.get('Items')
        records_to_delete = []
        selected_ids = {}
        if number_of_records <= len(data):
            while len(records_to_delete) < number_of_records:
                random_number = random.randint(0, len(data) - 1)
                random_rec = data[random_number]
                if str(random_number) in selected_ids:
                    print("Already picked up this record, trying another record")
                else:
                    selected_ids[str(random_number)] = True
                    records_to_delete.append(random_rec)
        else:
            raise Exception("Not enough records in table {0}".format(table_name))

        with table.batch_writer() as batch:
            for each in records_to_delete:
                test = {key: each[key] for key in table_key_names}
                print(test)
                batch.delete_item(
                    Key=test
                )
        results = "Deleted {0} records in table {1}".format(number_of_records, table_name)
    except Exception as e:
        print(e)
        results = str(e)

    return results


# def do_damage_auroradb(region, param_key, params, min_rec, max_rec):
#     if param_key == "trade_matching_core_database":
#         query = "Select uuid as id from trade_message"
#     else:
#         query = "Select id from settlement_message"
#     query_results = query_rds(params, query)
#     ids = []
#     if len(query_results) > 0:
#         for item in query_results:
#             ids.append(item[0])
#
#     number_of_records = random.randint(min_rec, max_rec)
#
#     records_to_delete = []
#     selected_ids = {}
#     if number_of_records <= len(ids):
#         while len(records_to_delete) < number_of_records:
#             random_number = random.randint(0, len(ids) - 1)
#             random_rec = ids[random_number]
#             if str(random_number) in selected_ids:
#                 print("Already picked up this record, trying another record")
#             else:
#                 selected_ids[str(random_number)] = True
#                 records_to_delete.append(random_rec)
#     else:
#         raise Exception("Not enough records in table {0}".format(param_key))
#
#     db_ids = "'" + "','".join(records_to_delete) + "'"
#     print("Now execute deletion on selected {0} Id's".format(len(records_to_delete)))
#     delete_query_trade = "delete from trade_allocation where trade_message_id in (Select id from trade_message where uuid in ({0}))".format(db_ids)
#     delete_query_trade2 = "delete from trade_message where uuid in({0})".format(db_ids)
#     delete_query_settlement = "delete from settlement_message where id in ({0})".format(db_ids)
#
#     if param_key == "trade_matching_core_database":
#         print(delete_query_trade)
#         query_result = query_rds(params, delete_query_trade, False)
#         print(query_result)
#         print(delete_query_trade2)
#         query_result = query_rds(params, delete_query_trade2, False)
#         print(query_result)
#     else:
#         query_result = query_rds(params, delete_query_settlement, False)
#         print(query_result)
#     results = "Deleted {0} records in table {1}".format(number_of_records, param_key)
#     return results
#
#
# def query_rds(db_params, query, return_result=True):
#     params = json.loads(db_params)
#     host = params["host"]
#     dbname = params["dbname"]
#     username = params["username"]
#     password = params["password"]
#     conn = None
#     results = None
#
#     try:
#         conn = psycopg2.connect(
#             host=host,
#             database=dbname,
#             user=username,
#             password=password)
#         cur = conn.cursor()
#         cur.execute(query)
#         if return_result:
#             results = cur.fetchall()
#         else:
#             return True
#     except (Exception, psycopg2.DatabaseError) as error:
#         print(error)
#     finally:
#         if conn is not None:
#             conn.commit()
#             conn.close()
#             print('Database connection closed.')
#     return results


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


def get_tables(region):
    params = {}
    dynamodb_inbound_table = get_secret("trade-matching-in-gateway-dynamodb", region)
    dynamodb_tm_ingress_t_table = get_secret("trade-matching-ingress-trade-dynamodb", region)
    dynamodb_tm_egress_t_table = get_secret("trade-matching-egress-trade-dynamodb", region)
    # dynamodb_egress_settlement_table = get_secret("trade-matching-egress-settlement-dynamodb", region)
    dynamodb_tm_outbound_t_table = get_secret("trade-matching-out-gateway-trade-dynamodb", region)
    dynamodb_tm_outbound_st_table = get_secret("trade-matching-out-gateway-settlement-dynamodb", region)

    trade_matching_core_database = get_secret("trade-matching-core-database", region)

    dynamodb_st_inbound_st_table = get_secret("settlement-in-gateway-settlement-dynamodb", region)
    dynamodb_st_ingress_st_table = get_secret("settlement-ingress-settlement-dynamodb", region)
    dynamodb_st_egress_st_table = get_secret("settlement-egress-settlement-dynamodb", region)
    dynamodb_st_outbound_st_table = get_secret("settlement-out-gateway-settlement-dynamodb", region)
    settlement_core_database = get_secret("settlement-core-database", region)


    params["dynamodb_inbound_table"] = dynamodb_inbound_table
    params["dynamodb_tm_ingress_t_table"] = dynamodb_tm_ingress_t_table
    params["dynamodb_egress_table"] = dynamodb_tm_egress_t_table
    # params["dynamodb_egress_settlement_table"] = dynamodb_egress_settlement_table
    params["dynamodb_tm_outbound_t_table"] = dynamodb_tm_outbound_t_table
    params["dynamodb_tm_outbound_st_table"] = dynamodb_tm_outbound_st_table
    params["trade_matching_core_database"] = trade_matching_core_database

    params["dynamodb_st_inbound_st_table"] = dynamodb_st_inbound_st_table
    params["dynamodb_st_ingress_st_table"] = dynamodb_st_ingress_st_table
    params["dynamodb_st_egress_st_table"] = dynamodb_st_egress_st_table
    params["dynamodb_st_outbound_st_table"] = dynamodb_st_outbound_st_table
    params["settlement_core_database"] = settlement_core_database
    return params


def get_tables_app(region, app):
    params = {}


    if app == "trade-matching":
        dynamodb_tm_ingress_t_table = get_secret("trade-matching-ingress-trade-dynamodb", region)
        dynamodb_tm_ingress_st_table = get_secret("trade-matching-ingress-settlement-dynamodb", region)

        dynamodb_tm_egress_t_table = get_secret("trade-matching-egress-trade-dynamodb", region)

        dynamodb_tm_outbound_t_table = get_secret("trade-matching-out-gateway-trade-dynamodb", region)
        dynamodb_tm_outbound_st_table = get_secret("trade-matching-out-gateway-settlement-dynamodb", region)
        dynamodb_st_inbound_st_table = get_secret("settlement-in-gateway-settlement-dynamodb", region)
        trade_matching_core_database = get_secret("trade-matching-core-database", region)

        # dynamodb_st_inbound_st_table = get_secret("settlement-in-gateway-settlement-dynamodb", region)
        # dynamodb_st_ingress_st_table = get_secret("settlement-ingress-settlement-dynamodb", region)
        # dynamodb_st_egress_st_table = get_secret("settlement-egress-settlement-dynamodb", region)
        # dynamodb_st_outbound_st_table = get_secret("settlement-out-gateway-settlement-dynamodb", region)
        # settlement_core_database = get_secret("settlement-core-database", region)
        # params["dynamodb_inbound_table"] = dynamodb_inbound_table
        params["dynamodb_tm_ingress_t_table"] = dynamodb_tm_ingress_t_table
        params["dynamodb_egress_table"] = dynamodb_tm_egress_t_table
        # params["dynamodb_egress_settlement_table"] = dynamodb_egress_settlement_table
        params["dynamodb_tm_outbound_t_table"] = dynamodb_tm_outbound_t_table
        params["dynamodb_tm_outbound_st_table"] = dynamodb_tm_outbound_st_table
        params["trade_matching_core_database"] = trade_matching_core_database
        params["dynamodb_st_inbound_st_table"] = dynamodb_st_inbound_st_table
        params["dynamodb_tm_ingress_st_table"] = dynamodb_tm_ingress_st_table
        # params["dynamodb_st_inbound_st_table"] = dynamodb_st_inbound_st_table
        # params["dynamodb_st_ingress_st_table"] = dynamodb_st_ingress_st_table
        # params["dynamodb_st_egress_st_table"] = dynamodb_st_egress_st_table
        # params["dynamodb_st_outbound_st_table"] = dynamodb_st_outbound_st_table
        # params["settlement_core_database"] = settlement_core_database
    else:
        # dynamodb_tm_ingress_t_table = get_secret("trade-matching-ingress-trade-dynamodb", region)
        #
        # dynamodb_tm_egress_t_table = get_secret("trade-matching-egress-trade-dynamodb", region)
        # # dynamodb_egress_settlement_table = get_secret("trade-matching-egress-settlement-dynamodb", region)
        #
        # dynamodb_tm_outbound_t_table = get_secret("trade-matching-out-gateway-trade-dynamodb", region)
        # dynamodb_tm_outbound_st_table = get_secret("trade-matching-out-gateway-settlement-dynamodb", region)
        #
        # trade_matching_core_database = get_secret("trade-matching-core-database", region)
        dynamodb_tm_inbound_st_table = get_secret("trade-matching-in-gateway-settlement-dynamodb", region)

        dynamodb_st_ingress_st_table = get_secret("settlement-ingress-settlement-dynamodb", region)
        dynamodb_st_egress_st_table = get_secret("settlement-egress-settlement-dynamodb", region)
        dynamodb_st_outbound_st_table = get_secret("settlement-out-gateway-settlement-dynamodb", region)
        settlement_core_database = get_secret("settlement-core-database", region)
        # params["dynamodb_inbound_table"] = dynamodb_inbound_table
        # params["dynamodb_tm_ingress_t_table"] = dynamodb_tm_ingress_t_table
        # params["dynamodb_egress_table"] = dynamodb_tm_egress_t_table
        # # params["dynamodb_egress_settlement_table"] = dynamodb_egress_settlement_table
        # params["dynamodb_tm_outbound_t_table"] = dynamodb_tm_outbound_t_table
        # params["dynamodb_tm_outbound_st_table"] = dynamodb_tm_outbound_st_table
        # params["trade_matching_core_database"] = trade_matching_core_database

        # params["dynamodb_st_inbound_st_table"] = dynamodb_st_inbound_st_table

        params["dynamodb_st_ingress_st_table"] = dynamodb_st_ingress_st_table
        params["dynamodb_st_egress_st_table"] = dynamodb_st_egress_st_table
        params["dynamodb_st_outbound_st_table"] = dynamodb_st_outbound_st_table
        params["settlement_core_database"] = settlement_core_database
        params["dynamodb_tm_inbound_st_table"] = dynamodb_tm_inbound_st_table
    return params


if __name__ == "__main__":
    event = dict()
    event["AWS_REGION"] = "us-east-1"
    event['APP'] = "trade-matching"
    event['MODE'] = "test"
    damage_maker(event, None)
