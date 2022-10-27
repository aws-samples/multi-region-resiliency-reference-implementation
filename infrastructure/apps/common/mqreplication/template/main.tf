// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

data "aws_secretsmanager_secret" "primary-mq-secret" {

  name = "${var.APP}-${var.COMPONENT}-${var.AWS_PRIMARY_REGION}-mq"
}

data "aws_secretsmanager_secret_version" "primary-mq-secret-version" {

  secret_id = data.aws_secretsmanager_secret.primary-mq-secret.id
}

data "aws_secretsmanager_secret" "secondary-mq-secret" {

  name = "${var.APP}-${var.COMPONENT}-${var.AWS_SECONDARY_REGION}-mq"
}

data "aws_secretsmanager_secret_version" "secondary-mq-secret-version" {

  secret_id = data.aws_secretsmanager_secret.secondary-mq-secret.id
}

locals {
  configuration_template = file("./configuration.xml")
  primary_mq_id = jsondecode(data.aws_secretsmanager_secret_version.primary-mq-secret-version.secret_string)["id"]
//  primary_mq_arn = jsondecode(data.aws_secretsmanager_secret_version.primary-mq-secret-version.secret_string)["arn"]
//  primary_mq_endpoint = jsondecode(data.aws_secretsmanager_secret_version.primary-mq-secret-version.secret_string)["endpoint"]
//  secondary_mq_id = jsondecode(data.aws_secretsmanager_secret_version.secondary-mq-secret-version.secret_string)["id"]
//  secondary_mq_arn = jsondecode(data.aws_secretsmanager_secret_version.secondary-mq-secret-version.secret_string)["arn"]
  secondary_mq_endpoint = replace(jsondecode(data.aws_secretsmanager_secret_version.secondary-mq-secret-version.secret_string)["endpoint"], "failover:", "")
  pattern = replace("<networkConnectors><networkConnector name=\"approtation\" userName=\"mqadmin\" duplex=\"true\" uri=\"masterslave:(xyz)\"/></networkConnectors>", "xyz", local.secondary_mq_endpoint)
  configuration = replace(local.configuration_template, "<networkConnectors></networkConnectors>", local.pattern)
}

resource "aws_mq_configuration" "mq-replication_configuration" {

  description    = "mq-replication"
  name           = "mq-replication"
  engine_type    = "ActiveMQ"
  engine_version = "5.15.0"

  data = local.configuration

  #checkov:skip=CKV_AWS_208: "Ensure MQBroker version is current"
}

resource "aws_cloudformation_stack" "mq-configuration-association" {

  name = "${var.APP}-${var.COMPONENT}-mq-configuration-association"

  parameters = {
    broker = local.primary_mq_id
    configuration = aws_mq_configuration.mq-replication_configuration.id
    configurationversion =  aws_mq_configuration.mq-replication_configuration.latest_revision
  }

  template_body = <<STACK
{
  "Parameters" : {
    "broker" : {
      "Type" : "String"
    },
    "configuration" : {
      "Type" : "String"
    },
    "configurationversion" : {
      "Type" : "String"
    }
  },
  "Resources" : {
    "primary2secondary": {
      "Type": "AWS::AmazonMQ::ConfigurationAssociation",
		"Properties": {
			"Broker": {
				"Ref": "broker"
			},
			"Configuration": {
				"Id": {
					"Ref": "configuration"
				},
                "Revision": {
					"Ref": "configurationversion"
				}
			}
		}
    }
  }
}
STACK
  #checkov:skip=CKV_AWS_124: "Ensure that CloudFormation stacks are sending event notifications to an SNS topic"
}
