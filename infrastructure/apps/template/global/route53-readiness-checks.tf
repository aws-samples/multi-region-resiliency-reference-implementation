// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

// inbound-gateway
resource "aws_route53recoveryreadiness_cell" "inbound-gateway-cell" {

  cell_name = "${var.APP}-global-inbound-gateway"
}

resource "aws_route53recoveryreadiness_resource_set" "inbound-gateway-trade-resource-set" {

  count = var.TRADE_FLOW ? 1:0
  resource_set_name = "${var.APP}-global-inbound-gateway-trade"
  resource_set_type = "AWS::DynamoDB::Table"

  resources {
    resource_arn = module.inbound-gateway.dynamodb_trade_arn
    readiness_scopes = [aws_route53recoveryreadiness_cell.inbound-gateway-cell.arn]
  }
}

resource "aws_route53recoveryreadiness_readiness_check" "inbound-gateway-trade-readiness-check" {

  count = var.TRADE_FLOW ? 1:0
  readiness_check_name = "${var.APP}-global-inbound-gateway-trade"
  resource_set_name    = aws_route53recoveryreadiness_resource_set.inbound-gateway-trade-resource-set[0].resource_set_name
}

resource "aws_route53recoveryreadiness_resource_set" "inbound-gateway-settlement-resource-set" {

  count = var.SETTLEMENT_FLOW ? 1:0
  resource_set_name = "${var.APP}-global-inbound-gateway-settlement"
  resource_set_type = "AWS::DynamoDB::Table"

  resources {
    resource_arn = module.inbound-gateway.dynamodb_settlement_arn
    readiness_scopes = [aws_route53recoveryreadiness_cell.inbound-gateway-cell.arn]
  }
}

resource "aws_route53recoveryreadiness_readiness_check" "inbound-gateway-settlement-readiness-check" {

  count = var.SETTLEMENT_FLOW ? 1:0
  readiness_check_name = "${var.APP}-global-inbound-gateway-settlement"
  resource_set_name    = aws_route53recoveryreadiness_resource_set.inbound-gateway-settlement-resource-set[0].resource_set_name
}

// ingress
resource "aws_route53recoveryreadiness_cell" "ingress-cell" {

  cell_name = "${var.APP}-global-ingress"
}

resource "aws_route53recoveryreadiness_resource_set" "ingress-trade-resource-set" {

  count = var.TRADE_FLOW ? 1:0
  resource_set_name = "${var.APP}-global-ingress-trade"
  resource_set_type = "AWS::DynamoDB::Table"

  resources {
    resource_arn = module.ingress.dynamodb_trade_arn
    readiness_scopes = [aws_route53recoveryreadiness_cell.ingress-cell.arn]
  }
}

resource "aws_route53recoveryreadiness_readiness_check" "ingress-trade-readiness-check" {

  count = var.TRADE_FLOW ? 1:0
  readiness_check_name = "${var.APP}-global-ingress-trade"
  resource_set_name    = aws_route53recoveryreadiness_resource_set.ingress-trade-resource-set[0].resource_set_name
}

resource "aws_route53recoveryreadiness_resource_set" "ingress-settlement-resource-set" {

  count = var.SETTLEMENT_FLOW ? 1:0
  resource_set_name = "${var.APP}-global-ingress-settlement"
  resource_set_type = "AWS::DynamoDB::Table"

  resources {
    resource_arn = module.ingress.dynamodb_settlement_arn
    readiness_scopes = [aws_route53recoveryreadiness_cell.ingress-cell.arn]
  }
}

resource "aws_route53recoveryreadiness_readiness_check" "ingress-settlement-readiness-check" {

  count = var.SETTLEMENT_FLOW ? 1:0
  readiness_check_name = "${var.APP}-global-ingress-settlement"
  resource_set_name    = aws_route53recoveryreadiness_resource_set.ingress-settlement-resource-set[0].resource_set_name
}

// core processing
resource "aws_route53recoveryreadiness_cell" "core-cell" {

  cell_name = "${var.APP}-global-core"
}

resource "aws_route53recoveryreadiness_resource_set" "core-resource-set" {

  resource_set_name = "${var.APP}-global-core"
  resource_set_type = "AWS::RDS::DBCluster"

  resources {
    resource_arn = module.core-processing.database_primary_cluster_arn
    readiness_scopes = [aws_route53recoveryreadiness_cell.core-cell.arn]
  }
}

resource "aws_route53recoveryreadiness_readiness_check" "core-readiness-check" {

  readiness_check_name = "${var.APP}-global-core"
  resource_set_name    = aws_route53recoveryreadiness_resource_set.core-resource-set.resource_set_name
}

// egress
resource "aws_route53recoveryreadiness_cell" "egress-cell" {

  cell_name = "${var.APP}-global-egress"
}

resource "aws_route53recoveryreadiness_resource_set" "egress-trade-resource-set" {

  count = var.TRADE_FLOW ? 1:0
  resource_set_name = "${var.APP}-global-egress-trade"
  resource_set_type = "AWS::DynamoDB::Table"

  resources {
    resource_arn = module.egress.dynamodb_trade_arn
    readiness_scopes = [aws_route53recoveryreadiness_cell.egress-cell.arn]
  }
}

resource "aws_route53recoveryreadiness_readiness_check" "egress-trade-readiness-check" {

  count = var.TRADE_FLOW ? 1:0
  readiness_check_name = "${var.APP}-global-egress-trade"
  resource_set_name    = aws_route53recoveryreadiness_resource_set.egress-trade-resource-set[0].resource_set_name
}

resource "aws_route53recoveryreadiness_resource_set" "egress-settlement-resource-set" {

  count = var.SETTLEMENT_FLOW ? 1:0
  resource_set_name = "${var.APP}-global-egress-settlement"
  resource_set_type = "AWS::DynamoDB::Table"

  resources {
    resource_arn = module.egress.dynamodb_settlement_arn
    readiness_scopes = [aws_route53recoveryreadiness_cell.egress-cell.arn]
  }
}

resource "aws_route53recoveryreadiness_readiness_check" "egress-settlement-readiness-check" {

  count = var.SETTLEMENT_FLOW ? 1:0
  readiness_check_name = "${var.APP}-global-egress-settlement"
  resource_set_name    = aws_route53recoveryreadiness_resource_set.egress-settlement-resource-set[0].resource_set_name
}

// outbound-gateway
resource "aws_route53recoveryreadiness_cell" "outbound-gateway-cell" {

  cell_name = "${var.APP}-global-outbound-gateway"
}

resource "aws_route53recoveryreadiness_resource_set" "outbound-gateway-trade-resource-set" {

  count = var.TRADE_FLOW ? 1:0
  resource_set_name = "${var.APP}-global-outbound-gateway-trade"
  resource_set_type = "AWS::DynamoDB::Table"

  resources {
    resource_arn = module.outbound-gateway.dynamodb_trade_arn
    readiness_scopes = [aws_route53recoveryreadiness_cell.outbound-gateway-cell.arn]
  }
}

resource "aws_route53recoveryreadiness_readiness_check" "outbound-gateway-trade-readiness-check" {

  count = var.TRADE_FLOW ? 1:0
  readiness_check_name = "${var.APP}-global-outbound-gateway-trade"
  resource_set_name    = aws_route53recoveryreadiness_resource_set.outbound-gateway-trade-resource-set[0].resource_set_name
}

resource "aws_route53recoveryreadiness_resource_set" "outbound-gateway-settlement-resource-set" {

  count = var.SETTLEMENT_FLOW ? 1:0
  resource_set_name = "${var.APP}-global-outbound-gateway-settlement"
  resource_set_type = "AWS::DynamoDB::Table"

  resources {
    resource_arn = module.outbound-gateway.dynamodb_settlement_arn
    readiness_scopes = [aws_route53recoveryreadiness_cell.outbound-gateway-cell.arn]
  }
}

resource "aws_route53recoveryreadiness_readiness_check" "outbound-gateway-settlement-readiness-check" {

  count = var.SETTLEMENT_FLOW ? 1:0
  readiness_check_name = "${var.APP}-global-outbound-gateway-settlement"
  resource_set_name    = aws_route53recoveryreadiness_resource_set.outbound-gateway-settlement-resource-set[0].resource_set_name
}

// global-cell
resource "aws_route53recoveryreadiness_cell" "global-cell" {

  cell_name = "${var.APP}-global"
  cells = [aws_route53recoveryreadiness_cell.inbound-gateway-cell.arn, aws_route53recoveryreadiness_cell.ingress-cell.arn, aws_route53recoveryreadiness_cell.core-cell.arn, aws_route53recoveryreadiness_cell.egress-cell.arn, aws_route53recoveryreadiness_cell.outbound-gateway-cell.arn]
}

module "secret" {

  source                = "../../../modules/secret"

  NAME                  = "${var.APP}-global-arc"
  VALUE                 = aws_route53recoveryreadiness_cell.global-cell.arn
  AWS_BACKUP_REGION     = var.AWS_SECONDARY_REGION
}
