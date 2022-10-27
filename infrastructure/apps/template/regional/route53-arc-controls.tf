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

resource "aws_route53recoverycontrolconfig_routing_control" "app-dns-routing-control" {

  name              = "${var.APP}-dns-${var.AWS_REGION}"
  cluster_arn       = data.aws_secretsmanager_secret_version.approtation-cluster-secret-version.secret_string
  control_panel_arn = data.aws_secretsmanager_secret_version.app-control-panel-secret-version.secret_string
}

module "app-dns-routing-control-secret" {

  source                = "../../../modules/secret"

  NAME                  = "${var.APP}-dns-${var.AWS_REGION}-arc-control"
  VALUE                 = aws_route53recoverycontrolconfig_routing_control.app-dns-routing-control.arn
  AWS_BACKUP_REGION     = var.AWS_BACKUP_REGION
}

resource "aws_route53recoverycontrolconfig_routing_control" "app-queue-routing-control" {

  name              = "${var.APP}-queue-${var.AWS_REGION}"
  cluster_arn       = data.aws_secretsmanager_secret_version.approtation-cluster-secret-version.secret_string
  control_panel_arn = data.aws_secretsmanager_secret_version.app-control-panel-secret-version.secret_string
}

module "app-queue-routing-control-secret" {

  source                = "../../../modules/secret"

  NAME                  = "${var.APP}-queue-${var.AWS_REGION}-arc-control"
  VALUE                 = aws_route53recoverycontrolconfig_routing_control.app-queue-routing-control.arn
  AWS_BACKUP_REGION     = var.AWS_BACKUP_REGION
}

resource "aws_route53recoverycontrolconfig_routing_control" "app-main-routing-control" {

  name              = "${var.APP}-app-${var.AWS_REGION}"
  cluster_arn       = data.aws_secretsmanager_secret_version.approtation-cluster-secret-version.secret_string
  control_panel_arn = data.aws_secretsmanager_secret_version.app-control-panel-secret-version.secret_string
}

module "app-main-routing-control-secret" {

  source                = "../../../modules/secret"

  NAME                  = "${var.APP}-app-${var.AWS_REGION}-arc-control"
  VALUE                 = aws_route53recoverycontrolconfig_routing_control.app-main-routing-control.arn
  AWS_BACKUP_REGION     = var.AWS_BACKUP_REGION
}

resource "aws_route53_health_check" "health-check" {

  type = "RECOVERY_CONTROL"
  routing_control_arn = aws_route53recoverycontrolconfig_routing_control.app-dns-routing-control.arn

  tags = {
    Name = "${var.APP}-${var.AWS_REGION}-arc-health-check"
  }
}

data "aws_kms_key" "secret-manager-secret-key" {

  key_id = "alias/secret-manager-secret-key"
}

resource "aws_secretsmanager_secret" "health-check-secret" {

  name = "${var.APP}-${var.AWS_REGION}-arc-health-check"
  kms_key_id = data.aws_kms_key.secret-manager-secret-key.key_id

  replica {
    region = "${var.AWS_BACKUP_REGION}"
  }
}

resource "aws_secretsmanager_secret_version" "health-check-secret-version" {

  secret_id     = aws_secretsmanager_secret.health-check-secret.id
  secret_string = aws_route53_health_check.health-check.id
}

