import boto3
from datetime import datetime, timedelta
import time


def wait_for_dynamodb_to_replicate(event, context):

    type = event['TYPE']
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " TYPE = " + str(type))

    if type == "DR":
        print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " will not wait for DynamoDB to replicate as it is disaster recovery (DR)")
    else:
        print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " wait_for_dynamodb_to_replicate Invoked")
        aws_region = event['AWS_REGION']
        aws_receiving_region = event['AWS_RECEIVING_REGION']
        app = event['APP']

        # client = boto3.client('ssm', region_name=aws_region)
        in_trade_table = app + "-in-gateway-trade-dynamodb-store"
        in_settlement_table = app + "-in-gateway-settlement-dynamodb-store"
        ingress_trade_table = app + "-ingress-trade-dynamodb-store"
        ingress_settlement_table = app + "-ingress-settlement-dynamodb-store"
        egress_trade_table = app + "-egress-trade-dynamodb-store"
        egress_settlement_table = app + "-egress-settlement-dynamodb-store"
        out_trade_table = app + "-out-gateway-trade-dynamodb-store"
        out_settlement_table = app + "-out-gateway-settlement-dynamodb-store"

        client = boto3.client('cloudwatch', region_name=aws_region)
        if app == "trade-matching":
            wait_for_replication(client, aws_receiving_region, in_trade_table)
            wait_for_replication(client, aws_receiving_region, ingress_trade_table)
            wait_for_replication(client, aws_receiving_region, egress_trade_table)
            wait_for_replication(client, aws_receiving_region, out_trade_table)
            wait_for_replication(client, aws_receiving_region, in_settlement_table)
            wait_for_replication(client, aws_receiving_region, ingress_settlement_table)
            wait_for_replication(client, aws_receiving_region, egress_settlement_table)
            wait_for_replication(client, aws_receiving_region, out_settlement_table)
        else:
            wait_for_replication(client, aws_receiving_region, in_settlement_table)
            wait_for_replication(client, aws_receiving_region, ingress_settlement_table)
            wait_for_replication(client, aws_receiving_region, egress_settlement_table)
            wait_for_replication(client, aws_receiving_region, out_settlement_table)


def wait_for_replication(client, receiving_region, table_name):

    complete = False
    while not complete:
        response = client.get_metric_data(
            MetricDataQueries=[
                {
                    'Id': 'identifier',
                    'MetricStat': {
                        'Metric': {
                            'Namespace': 'AWS/DynamoDB',
                            'MetricName': 'ReplicationLatency',
                            'Dimensions': [
                                {
                                    'Name': 'TableName',
                                    'Value': table_name
                                },
                                {
                                    'Name': 'ReceivingRegion',
                                    'Value': receiving_region
                                }
                            ]
                        },
                        'Period': 60,
                        'Stat': 'Sum',
                        'Unit': 'Milliseconds'
                    }
                },
            ],

            StartTime=datetime.utcnow() - timedelta(minutes=1),
            EndTime=datetime.utcnow()
        )

        value = sum(response['MetricDataResults'][0]['Values'])
        print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " " + table_name + " ReplicationLatency = " + str(value))
        complete = (value == 0)

        if not complete:
            time.sleep(5)


if __name__ == "__main__":
    event = dict()
    event["APP"] = "settlement"
    event["TYPE"] = "App Rotation"
    event["AWS_REGION"] = "us-east-1"
    event["AWS_RECEIVING_REGION"] = "us-west-2"

    wait_for_dynamodb_to_replicate(event, None)