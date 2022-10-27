import json
from datetime import datetime

from botocore.exceptions import ClientError
import boto3
import logging
import traceback
import base64


def clear_databases(event, context):

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " clear_databases Invoked")
    region = event['AWS_REGION']

    tables = ['trade-matching-in-gateway-trade-dynamodb-store', 'trade-matching-in-gateway-settlement-dynamodb-store',
              'trade-matching-ingress-trade-dynamodb-store', 'trade-matching-ingress-settlement-dynamodb-store',
              'trade-matching-egress-trade-dynamodb-store', 'trade-matching-egress-settlement-dynamodb-store',
              'trade-matching-out-gateway-settlement-dynamodb-store', 'trade-matching-out-gateway-trade-dynamodb-store',
              'settlement-in-gateway-settlement-dynamodb-store', "settlement-ingress-settlement-dynamodb-store",
              'settlement-egress-settlement-dynamodb-store', "settlement-out-gateway-settlement-dynamodb-store"]
    dynamo = boto3.resource('dynamodb', region_name=region)
    try:
        for t in tables:
            print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " Clearing Table : " + t)
            table = dynamo.Table(t)

            tableKeyNames = ['id']

            ProjectionExpression = ", ".join(tableKeyNames)

            response = table.scan(ProjectionExpression=ProjectionExpression)
            data = response.get('Items')

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

        # trade_matching_core_database = get_secret("trade-matching-core-database", region)
        # print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " Clearing Table : " + "trade-matching-core-database")
        # update_rds(trade_matching_core_database, "DELETE FROM trade_allocation")
        # update_rds(trade_matching_core_database, "DELETE FROM trade_message")
        #
        # settlement_core_database = get_secret("settlement-core-database", region)
        # print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " Clearing Table : " + "settlement-core-database")
        # update_rds(settlement_core_database, "DELETE FROM settlement_message")

    except Exception as e:
        logging.error("Exception in clear_databases", e)


def get_secret(secret_name, region_name):

    secret = None
    session = boto3.session.Session()
    endpoint_url = "https://secretsmanager." + region_name + ".amazonaws.com"
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name,
        endpoint_url=endpoint_url
    )

    try:
        get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    except ClientError as e:
        if e.response['Error']['Code'] == 'DecryptionFailureException':
            raise e
        elif e.response['Error']['Code'] == 'InternalServiceErrorException':
            raise e
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            raise e
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            raise e
        elif e.response['Error']['Code'] == 'ResourceNotFoundException':
            raise e
    except Exception as e:
        raise e
    else:
        if 'SecretString' in get_secret_value_response:
            secret = get_secret_value_response['SecretString']
        else:
            decoded_binary_secret = base64.b64decode(get_secret_value_response['SecretBinary'])
    return json.loads(secret)  # returns the secret as dictionary


# def update_rds(db_params, query):
#     # params = json.loads(db_params)
#     params = db_params
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
#         cur = conn.cursor(cursor_factory=RealDictCursor)
#         cur.execute(query)
#         conn.commit()
#     except (Exception, psycopg2.DatabaseError) as error:
#         logging.error(error)
#     finally:
#         if conn is not None:
#             conn.close()
#     return results


if __name__ == "__main__":
    event = dict()
    event["AWS_REGION"] = "us-west-2"
    event["APP"] = "trade-matching"
    clear_databases(event, None)


