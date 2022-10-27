import boto3
from datetime import datetime


def rotate_aurora_global_database(event, context):

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " rotate_aurora_global_database Invoked")
    aws_region = event['AWS_REGION']
    app = event['APP']
    component = event['COMPONENT']

    client = boto3.client('secretsmanager', region_name=aws_region)
    global_cluster_name = client.get_secret_value(SecretId=(app + "-" + component + "-database-cluster"))['SecretString']

    client = boto3.client('rds', region_name=aws_region)
    response = client.describe_global_clusters(GlobalClusterIdentifier=global_cluster_name)
    reader_cluster = ""
    if response['GlobalClusters'][0]['GlobalClusterMembers'][0]['IsWriter']:
        reader_cluster = response['GlobalClusters'][0]['GlobalClusterMembers'][1]['DBClusterArn']
    else:
        reader_cluster = response['GlobalClusters'][0]['GlobalClusterMembers'][0]['DBClusterArn']

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " global cluster: " + global_cluster_name)
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " rotating to db cluster: " + reader_cluster)
    client.failover_global_cluster(GlobalClusterIdentifier=global_cluster_name, TargetDbClusterIdentifier=reader_cluster)
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " successfully rotated global database cluster")

    return {'global_cluster': global_cluster_name}


if __name__ == "__main__":
    event = dict()
    event["APP"] = "trade-matching"
    event["AWS_REGION"] = "us-east-1"
    event["COMPONENT"] = "core"
    rotate_aurora_global_database(event, None)