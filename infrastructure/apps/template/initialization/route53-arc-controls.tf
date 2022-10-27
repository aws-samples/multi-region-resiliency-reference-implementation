// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

data "aws_secretsmanager_secret" "approtation-cluster-secret" {

  name = "approtation-cluster"
}

data "aws_secretsmanager_secret_version" "approtation-cluster-secret-version" {

  secret_id = data.aws_secretsmanager_secret.approtation-cluster-secret.id
}

data "aws_secretsmanager_secret" "app-control-panel-secret" {

  name = "${var.APP}-control-panel"
}

data "aws_secretsmanager_secret_version" "app-control-panel-secret-version" {

  secret_id = data.aws_secretsmanager_secret.app-control-panel-secret.id
}

resource "aws_route53recoverycontrolconfig_routing_control" "app-generator-routing-control" {

  name              = "${var.APP}-generator"
  cluster_arn       = data.aws_secretsmanager_secret_version.approtation-cluster-secret-version.secret_string
  control_panel_arn = data.aws_secretsmanager_secret_version.app-control-panel-secret-version.secret_string
}

module "app-dns-routing-control-secret" {

  source                = "../../../modules/secret"

  NAME                  = "${var.APP}-generator-arc-control"
  VALUE                 = aws_route53recoverycontrolconfig_routing_control.app-generator-routing-control.arn
  AWS_BACKUP_REGION     = var.AWS_SECONDARY_REGION
}
