import boto3
from datetime import datetime


def update_arc_control(event, context):

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " update_arc_control Invoked")
    aws_region = event['AWS_REGION']
    app = event['APP']
    scope = event['SCOPE']
    state = event['STATE']
    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " Region: " + aws_region + " App: " + app + " Scope: " + scope + " State: " + state)

    client = boto3.client('secretsmanager', region_name=aws_region)
    cluster = client.get_secret_value(SecretId='approtation-cluster')['SecretString']
    if scope == "generator":
        control = client.get_secret_value(SecretId=(app + "-" + scope + "-arc-control"))['SecretString']
    else:
        control = client.get_secret_value(SecretId=(app + "-" + scope + "-" + aws_region + "-arc-control"))['SecretString']

    client = boto3.client('route53-recovery-control-config', region_name='us-west-2')
    cluster = client.describe_cluster(ClusterArn=cluster)
    endpoints = cluster['Cluster']['ClusterEndpoints']
    regions = ["us-east-1", "us-west-2", "eu-west-1", "ap-northeast-1", "ap-southeast-2"]
    done = False
    for region in regions:
        for endpoint in endpoints:
            if endpoint["Region"] == region:

                try:
                    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " route 53 recovery cluster endpoint: " + endpoint["Endpoint"])
                    client = boto3.client('route53-recovery-cluster', region_name=region, endpoint_url=endpoint["Endpoint"])

                    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " updating control: " + control + " to " + state)
                    client.update_routing_control_state(RoutingControlArn=control, RoutingControlState=state)
                    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " successfully updated control")

                    done = True
                    break
                except Exception as e:
                    print(e)
        if done:
            break

if __name__ == "__main__":
    event = dict()
    event["AWS_REGION"] = "us-west-2"
    event["APP"] = "trade-matching"
    event["SCOPE"] = "dns"
    event["STATE"] = "Off"
    update_arc_control(event, None)