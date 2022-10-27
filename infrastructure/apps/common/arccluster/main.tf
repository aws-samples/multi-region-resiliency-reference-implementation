// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_route53recoverycontrolconfig_cluster" "approtation-cluster" {

  name = "approtation-cluster"
}

resource "aws_route53recoverycontrolconfig_control_panel" "trade-matching-control-panel" {

  name        = "trade-matching-control-panel"
  cluster_arn = aws_route53recoverycontrolconfig_cluster.approtation-cluster.arn
}

resource "aws_route53recoverycontrolconfig_control_panel" "settlement-control-panel" {

  name        = "settlement-control-panel"
  cluster_arn = aws_route53recoverycontrolconfig_cluster.approtation-cluster.arn
}

module "approtation-cluster-secret" {

  source              = "../../../modules/secret"
  NAME                = "approtation-cluster"
  VALUE               = aws_route53recoverycontrolconfig_cluster.approtation-cluster.arn
  AWS_BACKUP_REGION   = var.AWS_SECONDARY_REGION
}

module "trade-matching-control-panel-secret" {

  source              = "../../../modules/secret"
  NAME                = "trade-matching-control-panel"
  VALUE               = aws_route53recoverycontrolconfig_control_panel.trade-matching-control-panel.arn
  AWS_BACKUP_REGION   = var.AWS_SECONDARY_REGION
}

module "settlement-control-panel-secret" {

  source              = "../../../modules/secret"
  NAME                = "settlement-control-panel"
  VALUE               = aws_route53recoverycontrolconfig_control_panel.settlement-control-panel.arn
  AWS_BACKUP_REGION   = var.AWS_SECONDARY_REGION
}