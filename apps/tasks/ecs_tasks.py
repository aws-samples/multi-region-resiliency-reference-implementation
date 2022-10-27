# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0
import boto3
import json
import logging
import click
import psycopg2

# https://hands-on.cloud/working-with-ecs-in-python-using-boto3/
regions = ["us-east-1", "us-west-2"]

@click.command()
@click.option('--region', default="us-east-1", help='The region to fetch parameters and execute the app')
@click.option('--action', help='The type stop-all, list')
def cli(region: str, action: str):
    logging.basicConfig(format='%(asctime)s %(message)s', level=logging.INFO)

    logging.info("REGION: " + region)
    logging.info("ACTION: " + action)

    client = boto3.client("ecs", region_name="us-east-1")

    if action.lower() == "list":
        list_running_tasks(region)
    elif action.lower() == "clean":
        clean_table(region)
    elif action.lower() == "stop-all":
        tasks = list_running_tasks(region)
        for t in tasks:
            stop_task(region, t["cluster"], t["task"])
    elif action.lower() == "start-all":
        tasks = list_task_definition(region, "trade")
        start_trade_matching(region, tasks)
        tasks = list_task_definition(region, "settlement")
        start_trade_matching(region, tasks)
    elif action.lower() == "start-trade-matching":
        tasks = list_task_definition(region, "trade")
        start_trade_matching(region, tasks)
    elif action.lower() == "start-settlement":
        tasks = list_task_definition(region, "settlement")
        start_trade_matching(region, tasks)
    elif action.lower() == "start-all-regions":
        for r in regions:
            tasks = list_task_definition(r, "trade")
            start_trade_matching(r, tasks)
            tasks = list_task_definition(r, "settlement")
            start_trade_matching(r, tasks)
    elif action.lower() == "stop-all-regions":
        for r in regions:
            tasks = list_running_tasks(r)
            for t in tasks:
                stop_task(r, t["cluster"], t["task"])


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


def stop_task(region, cluster, task):
    client = boto3.client("ecs", region_name=region)
    logging.info("Stopping task {0} on cluster {1}".format(task, cluster))
    response = client.stop_task(
        cluster=cluster,
        task=task,
        reason='Manuel stop'
    )
    return True


def start_trade_matching(region, tasks):
    client = boto3.client("ecs", region_name=region)
    # make sure all tasks are off.
    for t in tasks:
        logging.info("Starting task {0} on cluster {1} ".format(t['task'], t["cluster"]))
        # check task is not runningn already
        #stop_task(region, t["cluster"], t["task"])
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
            taskDefinition=t['task']
        )
        logging.info(response)


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
        settlement_core_database = get_secret("settlement-core-database", region)
        params["trade_matching_core_database"] = trade_matching_core_database
        params["settlement_core_database"] = settlement_core_database

        result = query_rds(params["trade_matching_core_database"], "Select count(*) FROM trade_allocation")
        logging.info("Total records found in core trade_allocation {0}".format(result[0][0]))
        query_rds(params["trade_matching_core_database"], "DELETE FROM trade_allocation")
        logging.info("Deleted {0} records".format(result[0][0]))

        result = query_rds(params["trade_matching_core_database"], "Select count(*) FROM trade_message")
        logging.info("Total records found in core trade_message {0}".format(result[0][0]))
        query_rds(params["trade_matching_core_database"], "DELETE FROM trade_message")
        logging.info("Deleted {0} records".format(result[0][0]))

        result = query_rds(params["settlement_core_database"], "Select count(*) FROM settlement_message")
        logging.info("Total records found in core settlement_core_database {0}".format(result[0][0]))
        query_rds(params["settlement_core_database"], "DELETE FROM settlement_message")
        logging.info("Deleted {0} records".format(result[0][0]))
    except Exception as e:
        logging.error("Exception in clean_table ", e)


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
        conn.commit()
        results = cur.fetchall()
    except (Exception, psycopg2.DatabaseError) as error:
        logging.error(error)
    finally:
        if conn is not None:
            conn.close()
            print('Database connection closed.')
    return results


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


if __name__ == '__main__':
    cli()
