import boto3
from datetime import datetime
import time
import json


def update_database_secret(event, context):

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " update_database_secret Invoked")
    aws_region = event['AWS_REGION']
    app = event['APP']
    component = event['COMPONENT']

    client = boto3.client('secretsmanager', region_name=aws_region)
    global_cluster_name = client.get_secret_value(SecretId=(app + "-" + component + "-database-cluster"))['SecretString']
    database_secret = client.get_secret_value(SecretId=(app + "-" + component + "-database"))['SecretString']
    database_secret_data = json.loads(database_secret)

    client = boto3.client('rds', region_name=aws_region)
    response = client.describe_global_clusters(GlobalClusterIdentifier=global_cluster_name)
    writer_cluster = ""
    if response['GlobalClusters'][0]['GlobalClusterMembers'][0]['IsWriter']:
        writer_cluster = response['GlobalClusters'][0]['GlobalClusterMembers'][0]['DBClusterArn']
    else:
        writer_cluster = response['GlobalClusters'][0]['GlobalClusterMembers'][1]['DBClusterArn']

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " global cluster writer cluster arn : " + writer_cluster)

    writer_cluster_identifier = writer_cluster.split(":")[-1]

    db_cluster_info = client.describe_db_clusters(DBClusterIdentifier=writer_cluster_identifier)
    writer_cluster_endpoint = db_cluster_info["DBClusters"][0]["Endpoint"]
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " global cluster writer cluster endpoint : " + writer_cluster_endpoint)

    database_secret_data["host"] = writer_cluster_endpoint
    # print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " database secret " + json.dumps(database_secret_data))

    client = boto3.client('secretsmanager', region_name="us-east-1")
    client.put_secret_value(SecretId=(app + "-" + component + "-database"), SecretString=json.dumps(database_secret_data))

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " updated database secret ")


if __name__ == "__main__":
    event = dict()
    event["APP"] = "settlement"
    event["AWS_REGION"] = "us-east-1"
    event["COMPONENT"] = "core"
    update_database_secret(event, None)