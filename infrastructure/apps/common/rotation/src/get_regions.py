import boto3
from datetime import datetime
import json


def get_regions(event, context):

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " get_regions Invoked")
    aws_region = event['AWS_REGION']
    aws_region1 = event['AWS_REGION1']
    aws_region2 = event['AWS_REGION2']
    app = event['APP']

    client = boto3.client('secretsmanager', region_name=aws_region)
    approtation_cluster = client.get_secret_value(SecretId='approtation-cluster')['SecretString']
    region_1_main_control_arn = client.get_secret_value(SecretId=(app + "-dns-" + aws_region1 + "-arc-control"))['SecretString']
    region_2_main_control_arn = client.get_secret_value(SecretId=(app + "-dns-" + aws_region2 + "-arc-control"))['SecretString']

    client = boto3.client('route53-recovery-control-config', region_name='us-west-2')
    cluster = client.describe_cluster(ClusterArn=approtation_cluster)
    endpoints = cluster['Cluster']['ClusterEndpoints']
    regions = ["us-east-1", "us-west-2", "eu-west-1", "ap-northeast-1", "ap-southeast-2"]
    counter = 0
    sorted_endpoints = []
    for region in regions:
        for endpoint in endpoints:
            if endpoint["Region"] == region:
                sorted_endpoints.append(endpoint["Endpoint"])

    for endpoint in sorted_endpoints:

        try:
            print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " route 53 recover cluster endpoint: " + endpoint)
            client = boto3.client('route53-recovery-cluster', region_name=aws_region, endpoint_url=endpoint)
            region1_control_state = client.get_routing_control_state(RoutingControlArn=region_1_main_control_arn)
            region2_control_state = client.get_routing_control_state(RoutingControlArn=region_2_main_control_arn)

            print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " " + aws_region1 + " is " + region1_control_state["RoutingControlState"])
            print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " " + aws_region2 + " is " + region2_control_state["RoutingControlState"])

            active_region = ""
            passive_region = ""
            if region1_control_state["RoutingControlState"] == "On":
                active_region = aws_region1
                passive_region = aws_region2
            else:
                active_region = aws_region2
                passive_region = aws_region1

            print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " Active Region = " + active_region + " Passive Region = " + passive_region)

            # regions = Regions()
            # regions.active_region = active_region
            # regions.passive_region = passive_region
            # print(regions.to_dict())
            return {'active_region': active_region, 'passive_region': passive_region}
        except Exception as e:
            print(e)


class Regions:
    """
    It represents the state of the regions.
    """
    def __init__(self):
        """
        Initializes the App State.
        """
        self.active_region = ""
        self.passive_region = ""

    def to_dict(self):
        return {
            'active_region': self.active_region,
            'passive_region': self.passive_region,
        }


if __name__ == "__main__":
    event = dict()
    event["APP"] = "trade-matching"
    event["AWS_REGION"] = "us-east-1"
    event["AWS_REGION1"] = "us-east-1"
    event["AWS_REGION2"] = "us-west-2"
    get_regions(event, None)