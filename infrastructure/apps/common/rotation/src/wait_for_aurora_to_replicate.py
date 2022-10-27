import boto3
from datetime import datetime, timedelta
import time


def wait_for_aurora_to_replicate(event, context):

    type = event['TYPE']
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " TYPE = " + str(type))

    if type == "DR":
        print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " will not wait for Aurora to replicate as it is disaster recovery (DR)")
    else:
        print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " wait_for_aurora_to_replicate Invoked")
        aws_region = event['AWS_REGION']
        app = event['APP']
        component = event['COMPONENT']

        client = boto3.client('secretsmanager', region_name=aws_region)
        global_cluster_name = client.get_secret_value(SecretId=(app + "-" + component + "-database-cluster"))['SecretString']

        client = boto3.client('cloudwatch', region_name=aws_region)

        complete = False
        while not complete:
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
                StartTime=datetime.utcnow() - timedelta(minutes=1),
                EndTime=datetime.utcnow()
            )

            value = sum(response['MetricDataResults'][0]['Values'])
            print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " AuroraGlobalDBRPOLag = " + str(value))
            complete = (value == 0)

            if not complete:
                time.sleep(5)


if __name__ == "__main__":
    event = dict()
    event["APP"] = "settlement"
    event["TYPE"] = "App Rotation"
    event["AWS_REGION"] = "us-east-1"
    event["COMPONENT"] = "core"
    wait_for_aurora_to_replicate(event, None)