// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {

  alarm_arn = "arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alarm:${var.STOP}"
  role_arn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.ROLE}"
}

resource "aws_cloudformation_stack" "terminate_EC2_instances" {

  name = var.NAME

  parameters = {

    name        = var.NAME
    application = var.APP
    component   = var.COMPONENT
    selection   = var.SELECTION
    stop        = local.alarm_arn
    role        = local.role_arn
  }

  template_body = <<STACK
{
  "Parameters" : {
    "name" : {
      "Type" : "String"
    },
    "application" : {
      "Type" : "String"
    },
    "component" : {
      "Type" : "String"
    },
    "selection" : {
      "Type" : "String"
    },
    "stop" : {
      "Type" : "String"
    },
    "role" : {
      "Type" : "String"
    }
  },
  "Resources" : {
    "TerminateEC2Instances": {
      "Type" : "AWS::FIS::ExperimentTemplate",
		"Properties": {
          "Description": "Terminate EC2 instances for the application component",
          "Tags": {
            "Name": {"Ref": "name"}
          },
          "Targets": {
              "myInstances": {
                  "ResourceType": "aws:ec2:instance",
                  "ResourceTags": {
                      "Application": {"Ref": "application"},
                      "Component": {"Ref": "component"}
                  },
                  "SelectionMode": {"Ref": "selection"}
              }
          },
          "Actions": {
              "StopInstances": {
                  "ActionId": "aws:ec2:terminate-instances",
                  "Description": "terminate EC2 instances",
                  "Targets": {
                      "Instances": "myInstances"
                  }
              }
          },
          "StopConditions": [
              {
                  "Source": "aws:cloudwatch:alarm",
                  "Value": {"Ref": "stop"}
              }
          ],
          "RoleArn": {"Ref": "role"}
		}
    }
  }
}
STACK
  #checkov:skip=CKV_AWS_124: "Ensure that CloudFormation stacks are sending event notifications to an SNS topic"
}


