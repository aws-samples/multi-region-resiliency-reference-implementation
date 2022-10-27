import boto3
from datetime import datetime
import time
# import json
import string
import random

def detach_and_promote_aurora(event, context):

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " detach_and_promote_aurora Invoked")
    aws_region = event['AWS_REGION']
    aws_primary_region = event['AWS_PRIMARY_REGION']
    aws_secondary_region = event['AWS_SECONDARY_REGION']
    app = event['APP']
    component = event['COMPONENT']

    client = boto3.client('secretsmanager', region_name=aws_region)
    global_cluster_name = client.get_secret_value(SecretId=(app + "-" + component + "-database-cluster"))['SecretString']
    # database = json.loads(client.get_secret_value(SecretId=(app + "-" + component + "-database"))['SecretString'])

    client = boto3.client('secretsmanager', region_name=aws_primary_region)
    security_group_id = client.get_secret_value(SecretId=(app + "-" + aws_primary_region + "-aurora-sg"))['SecretString']

    letters = string.ascii_lowercase
    suffix = ''.join(random.choice(letters) for i in range(3))

    client = boto3.client('rds', region_name=aws_secondary_region)
    response = client.describe_global_clusters(GlobalClusterIdentifier=global_cluster_name)
    reader_cluster = ""
    if response['GlobalClusters'][0]['GlobalClusterMembers'][0]['IsWriter']:
        reader_cluster = response['GlobalClusters'][0]['GlobalClusterMembers'][1]['DBClusterArn']
    else:
        reader_cluster = response['GlobalClusters'][0]['GlobalClusterMembers'][0]['DBClusterArn']

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " global cluster: " + global_cluster_name)
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " removing db cluster: " + reader_cluster)
    client.remove_from_global_cluster(GlobalClusterIdentifier=global_cluster_name, DbClusterIdentifier=reader_cluster)
    time.sleep(60)
    # reader_cluster = "arn:aws:rds:us-west-2:285719923712:cluster:settlement-core-secondary-cluster"
    client = boto3.client('rds', region_name=aws_secondary_region)
    # waiter = client.get_waiter('db_instance_available')
    # waiter.wait(DBInstanceIdentifier='settlement-core-secondary-cluster-instance')

    client = boto3.client('rds', region_name=aws_secondary_region)
    db_cluster_available = False
    while not db_cluster_available:
        response = client.describe_db_clusters(DBClusterIdentifier=reader_cluster)
        if response["DBClusters"][0]["Status"] == "available":
            db_cluster_available = True
        if not db_cluster_available:
            time.sleep(5)

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " successfully removed global database cluster")

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " creating global cluster: " + (global_cluster_name + "-" + suffix))
    client.create_global_cluster(
        GlobalClusterIdentifier=global_cluster_name+"-" + suffix,
        SourceDBClusterIdentifier=reader_cluster
    )

    time.sleep(60)

    client = boto3.client('secretsmanager', region_name="us-east-1")
    client.put_secret_value(SecretId=(app + "-" + component + "-database-cluster"), SecretString=(global_cluster_name + "-" + suffix))

    client = boto3.client('rds', region_name=aws_secondary_region)
    global_cluster_available = False
    while not global_cluster_available:
        response = client.describe_global_clusters(GlobalClusterIdentifier=global_cluster_name+"-" + suffix)
        if response["GlobalClusters"][0]["Status"] == "available":
            global_cluster_available = True
        if not global_cluster_available:
            time.sleep(5)
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " successfully created global cluster: " + (global_cluster_name + "-" + suffix))

    time.sleep(60)

    db_cluster_available = False
    while not db_cluster_available:
        response = client.describe_db_clusters(DBClusterIdentifier=reader_cluster)
        if response["DBClusters"][0]["Status"] == "available":
            db_cluster_available = True
        if not db_cluster_available:
            time.sleep(5)
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " successfully added reader cluster to global cluster: " + (global_cluster_name + "-" + suffix))

    client = boto3.client('kms', region_name=aws_primary_region)
    response = client.create_key(Description="aurora-encryption-key")

    client = boto3.client('rds', region_name=aws_primary_region)
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " creating another cluster in primary region : " + app + "-" + component + "-primary-cluster-" + suffix)
    client.create_db_cluster(
        DBClusterIdentifier=app + "-" + component + "-primary-cluster-" + suffix,
        GlobalClusterIdentifier=global_cluster_name+"-"+suffix,
        Engine="aurora-postgresql",
        EngineVersion="11.9",
        DBSubnetGroupName=app + "-" + aws_primary_region + "-db-subnet-group",
        VpcSecurityGroupIds=[security_group_id],
        KmsKeyId=response["KeyMetadata"]["KeyId"]
    )
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " successfully created another cluster in primary region : " + app + "-" + component + "-primary-cluster-" + suffix)

    # client = boto3.client('rds', region_name=aws_secondary_region)
    # global_cluster_available = False
    # while not global_cluster_available:
    #     response = client.describe_db_clusters(DBClusterIdentifier=app + "-" + component + "-primary-cluster-" + suffix)
    #     if response["DBClusters"][0]["Status"] == "available":
    #         global_cluster_available = True
    #     if not global_cluster_available:
    #         time.sleep(5)

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " creating another database in primary region : " + app + "-" + component + "-primary-cluster-instance-"+suffix)
    client.create_db_instance(
        DBInstanceClass="db.r4.large",
        DBClusterIdentifier=app + "-" + component + "-primary-cluster-" + suffix,
        DBInstanceIdentifier=app + "-" + component + "-primary-cluster-instance-" + suffix,
        Engine="aurora-postgresql"
    )
    # waiter = client.get_waiter('db_instance_available')
    # waiter.wait(DBInstanceIdentifier='settlement-core-primary-cluster-instance-' + suffix)
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " successfully initiated creation of another database in primary region : " + app + "-" + component + "-primary-cluster-instance-"+suffix)

    return {'global_cluster': global_cluster_name}


if __name__ == "__main__":
    event = dict()
    event["APP"] = "trade-matching"
    event["AWS_REGION"] = "us-east-1"
    event["AWS_PRIMARY_REGION"] = "us-east-1"
    event["AWS_SECONDARY_REGION"] = "us-west-2"
    event["COMPONENT"] = "core"
    detach_and_promote_aurora(event, None)