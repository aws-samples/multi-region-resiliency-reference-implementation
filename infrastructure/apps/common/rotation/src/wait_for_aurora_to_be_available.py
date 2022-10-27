import boto3
from datetime import datetime
import time
# import json


def wait_for_aurora_to_be_available(event, context):

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " wait_for_aurora_to_be_available Invoked")
    aws_region = event['AWS_REGION']
    app = event['APP']
    component = event['COMPONENT']

    client = boto3.client('secretsmanager', region_name=aws_region)
    global_cluster_name = client.get_secret_value(SecretId=(app + "-" + component + "-database-cluster"))['SecretString']

    client = boto3.client('rds', region_name=aws_region)
    global_cluster_available = False
    while not global_cluster_available:
        response = client.describe_global_clusters(GlobalClusterIdentifier=global_cluster_name)
        if response["GlobalClusters"][0]["Status"] == "available":
            global_cluster_available = True
        else:
            time.sleep(5)

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " global cluster is available ")


if __name__ == "__main__":
    event = dict()
    event["APP"] = "trade-matching"
    event["AWS_REGION"] = "us-east-1"
    event["COMPONENT"] = "core"
    wait_for_aurora_to_be_available(event, None)