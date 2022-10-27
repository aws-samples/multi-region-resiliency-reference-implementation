# Copyright 2022 Amazon.com and its affiliates; all rights reserved.
# This file is Amazon Web Services Content and may not be duplicated or distributed without permission.

import logging
import boto3
from datetime import datetime


def disable_vpc_endpoint(event, context):

    logging.basicConfig(format='%(asctime)s %(message)s', level=logging.INFO)

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " disable_vpc_endpoint")

    region = event["REGION"]
    app = event["APP"]
    service = event["SERVICE"]

    client = boto3.client('ec2', region_name=region)

    response = client.describe_vpcs()
    vpc_id = ""
    for vpc in response["Vpcs"]:
        for tag in vpc.get("Tags", []):
            if tag.get("Key", "") == "Name":
                if tag.get("Value", "").startswith(app):
                    vpc_id = vpc.get("VpcId", "")

    response = client.describe_vpc_endpoints()

    for endpoint in response["VpcEndpoints"]:
        if endpoint.get("ServiceName", "").endswith(service):
            if endpoint.get("VpcId", "") == vpc_id:
                client.modify_vpc_endpoint(VpcEndpointId=endpoint["VpcEndpointId"], PolicyDocument=str(endpoint["PolicyDocument"].replace("Allow", "Deny")))


if __name__ == "__main__":
    event = dict()
    event["REGION"] = "us-east-1"
    event["APP"] = "trade-matching"
    event["SERVICE"] = "rds"
    disable_vpc_endpoint(event, None)