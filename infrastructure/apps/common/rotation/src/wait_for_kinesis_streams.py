import boto3
from datetime import datetime, timedelta
import time


def wait_for_kinesis_streams(event, context):

    type = event['TYPE']
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " TYPE = " + str(type))

    if type == "DR":
        print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " will not wait for Kinesis streams to get processed as it is disaster recovery (DR)")
    else:
        print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " wait_for_kinesis_streams Invoked")
        aws_region = event['AWS_REGION']
        app = event['APP']

        client = boto3.client('ssm', region_name=aws_region)

        if app == "trade-matching":
            ingress_trade_stream = client.get_parameter(Name=("/approtation/" + app + "/ingress-trade/kinesis"))["Parameter"]["Value"]
            ingress_settlement_stream = client.get_parameter(Name=("/approtation/" + app + "/ingress-settlement/kinesis"))["Parameter"]["Value"]
            core_trade_stream = client.get_parameter(Name=("/approtation/" + app + "/core-trade/kinesis"))["Parameter"]["Value"]
            core_settlement_stream = client.get_parameter(Name=("/approtation/" + app + "/core-settlement/kinesis"))["Parameter"]["Value"]
            egress_trade_stream = client.get_parameter(Name=("/approtation/" + app + "/egress-trade/kinesis"))["Parameter"]["Value"]
            egress_settlement_stream = client.get_parameter(Name=("/approtation/" + app + "/egress-settlement/kinesis"))["Parameter"]["Value"]
            out_trade_stream = client.get_parameter(Name=("/approtation/" + app + "/out-gateway-trade/kinesis"))["Parameter"]["Value"]
            out_settlement_stream = client.get_parameter(Name=("/approtation/" + app + "/out-gateway-settlement/kinesis"))["Parameter"]["Value"]
        else:
            ingress_settlement_stream = client.get_parameter(Name=("/approtation/" + app + "/ingress-settlement/kinesis"))["Parameter"]["Value"]
            core_settlement_stream = client.get_parameter(Name=("/approtation/" + app + "/core-settlement/kinesis"))["Parameter"]["Value"]
            egress_settlement_stream = client.get_parameter(Name=("/approtation/" + app + "/egress-settlement/kinesis"))["Parameter"]["Value"]
            out_settlement_stream = client.get_parameter(Name=("/approtation/" + app + "/out-gateway-settlement/kinesis"))["Parameter"]["Value"]

        client = boto3.client('cloudwatch', region_name=aws_region)
        if app == "trade-matching":
            wait_for_stream(client, ingress_trade_stream)
            wait_for_stream(client, core_trade_stream)
            wait_for_stream(client, egress_trade_stream)
            wait_for_stream(client, out_trade_stream)
            wait_for_stream(client, ingress_settlement_stream)
            wait_for_stream(client, core_settlement_stream)
            wait_for_stream(client, egress_settlement_stream)
            wait_for_stream(client, out_settlement_stream)
        else:
            wait_for_stream(client, ingress_settlement_stream)
            wait_for_stream(client, core_settlement_stream)
            wait_for_stream(client, egress_settlement_stream)
            wait_for_stream(client, out_settlement_stream)


def wait_for_stream(client, stream):

    complete = False
    while not complete:
        response = client.get_metric_data(
            MetricDataQueries=[
                {
                    'Id': 'identifier',
                    'MetricStat': {
                        'Metric': {
                            'Namespace': 'AWS/Kinesis',
                            'MetricName': 'GetRecords.Bytes',
                            'Dimensions': [
                                {
                                    'Name': 'StreamName',
                                    'Value': stream
                                }
                            ]
                        },
                        'Period': 60,
                        'Stat': 'Sum',
                        'Unit': 'Bytes'
                    }
                },
            ],

            StartTime=datetime.utcnow() - timedelta(minutes=1),
            EndTime=datetime.utcnow()
        )

        value = sum(response['MetricDataResults'][0]['Values'])
        print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " " + stream + " GetRecords.Bytes = " + str(value))
        complete = (value == 0)

        if not complete:
            time.sleep(5)


if __name__ == "__main__":
    event = dict()
    event["APP"] = "settlement"
    event["TYPE"] = "App Rotation"
    event["AWS_REGION"] = "us-east-1"
    wait_for_kinesis_streams(event, None)