// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {

  document_arn = "arn:aws:ssm:us-east-1:${data.aws_caller_identity.current.account_id}:document/Disable-VPC-Endpoint"
  alarm_arn = "arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alarm:${var.STOP}"
  role_arn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.ROLE}"
  parameters = "{\"REGION\": \"${var.REGION}\", \"APP\": \"${var.APP}\", \"SERVICE\": \"${var.SERVICE}\"}"
}

resource "aws_cloudformation_stack" "stop_VPC_access" {

  name = var.NAME

  parameters = {

    name        = var.NAME
    document    = local.document_arn
    parameters  = local.parameters
    stop        = local.alarm_arn
    role        = local.role_arn
  }

  template_body = <<STACK
{
  "Parameters" : {
    "name" : {
      "Type" : "String"
    },
    "document" : {
      "Type" : "String"
    },
    "parameters" : {
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
    "StopVPCAccess": {
      "Type" : "AWS::FIS::ExperimentTemplate",
		"Properties": {
          "Description": "Stop access to the service within the VPC",
          "Tags": {
            "Name": {"Ref": "name"}
          },
          "Targets": {
          },
          "Actions": {
              "StopTasks": {
                  "ActionId": "aws:ssm:start-automation-execution",
                  "Description": "stop VPC access",
                  "Parameters": {
                      "documentArn": {"Ref": "document"},
                      "documentParameters": {"Ref": "parameters"},
                      "maxDuration": "PT30M"
                  },
                  "Targets": {
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


