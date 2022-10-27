import boto3
from datetime import datetime

def switch_on_secondary_controls(event, context):

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " switch_on_secondary_controls Invoked")
    aws_region = event['AWS_REGION']
    secondary_region = event['AWS_SECONDARY_REGION']
    app = event['APP']

    client = boto3.client('secretsmanager', region_name=aws_region)
    approtation_cluster = client.get_secret_value(SecretId='approtation-cluster')['SecretString']
    app_secondary_control = client.get_secret_value(SecretId=(app + "-" + secondary_region + "-arc-control"))['SecretString']
    app_inbound_gateway_secondary_control = client.get_secret_value(SecretId=(app + "-inbound-gateway-" + secondary_region + "-arc-control"))['SecretString']

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

            print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " updating control: " + app_secondary_control + " to On")
            print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " updating control: " + app_inbound_gateway_secondary_control + " to On")
            client.update_routing_control_state(RoutingControlArn=app_secondary_control, RoutingControlState='On')
            client.update_routing_control_state(RoutingControlArn=app_inbound_gateway_secondary_control, RoutingControlState='On')
            print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " successfully updated controls")

            break;
        except Exception as e:
            print(e)


if __name__ == "__main__":
    event = dict()
    event["APP"] = "trade-matching"
    event["AWS_REGION"] = "us-east-1"
    event["AWS_SECONDARY_REGION"] = "us-west-2"
    switch_on_secondary_controls(event, None)