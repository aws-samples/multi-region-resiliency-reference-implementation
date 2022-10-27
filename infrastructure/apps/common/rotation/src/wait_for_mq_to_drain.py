import boto3
from datetime import datetime, timedelta
import time


def wait_for_mq_to_drain(event, context):

    type = event['TYPE']
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " TYPE = " + str(type))

    if type == "DR":
        print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " will not wait for MQ messages to get processed as it is disaster recovery (DR)")
    else:
        print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " wait_for_mq_to_drain Invoked")
        aws_region = event['AWS_REGION']
        app = event['APP']
        component = event['COMPONENT']
        queue = event['QUEUE']

        broker = app + "-" + component + "-" + aws_region + "-mq-broker"
        connector = "approtation"

        client = boto3.client('cloudwatch', region_name=aws_region)

        complete = False
        while not complete:
            response = client.get_metric_data(
                MetricDataQueries=[
                    {
                        'Id': 'identifier',
                        'MetricStat': {
                            'Metric': {
                                'Namespace': 'AWS/AmazonMQ',
                                'MetricName': 'QueueSize',
                                'Dimensions': [
                                    {
                                        'Name': 'Broker',
                                        'Value': broker
                                    },
                                    {
                                       'Name': 'Queue',
                                       'Value': queue
                                    },
                                    {
                                        'Name': 'NetworkConnector',
                                        'Value': connector
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
            print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " broker = " + broker + " queue = " + queue + " QueueSize = " + str(value))
            complete = (value == 0)

            if not complete:
                time.sleep(5)


if __name__ == "__main__":
    event = dict()
    event["APP"] = "settlement"
    event["TYPE"] = "App Rotation"
    event["AWS_REGION"] = "us-east-1"
    event["COMPONENT"] = "core"
    event["QUEUE"] = "trades"
    wait_for_mq_to_drain(event, None)