// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {

  alarm_arn = "arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alarm:${var.STOP}"
  role_arn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.ROLE}"
}

resource "aws_cloudformation_stack" "stress_EC2_instances_CPU" {

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
    "StressEC2InstancesCPU": {
      "Type" : "AWS::FIS::ExperimentTemplate",
		"Properties": {
          "Description": "Stress CPU of ECS EC2 instances for the application component",
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
              "CPUStress": {
                  "ActionId": "aws:ssm:send-command",
                  "Description": "stress CPU on ECS EC2 container",
                  "Parameters": {
                      "duration": "PT2M",
                      "documentArn": "arn:aws:ssm:us-east-1::document/AWSFIS-Run-CPU-Stress",
                      "documentParameters": "{\"DurationSeconds\": \"120\", \"InstallDependencies\": \"True\", \"CPU\": \"0\"}"
                  },
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


