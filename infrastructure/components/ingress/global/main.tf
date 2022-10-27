// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "dynamodb-trade" {

  source                = "../../../modules/dynamodb"
  count                 = var.TRADE_FLOW? 1:0

  APP                   = var.APP
  COMPONENT             = "${var.COMPONENT}-trade"
  ENV                   = var.ENV
  AWS_PRIMARY_REGION    = var.AWS_PRIMARY_REGION
  AWS_SECONDARY_REGION  = var.AWS_SECONDARY_REGION
}

module "dynamodb-settlement" {

  source                = "../../../modules/dynamodb"
  count                 = var.SETTLEMENT_FLOW? 1:0

  APP                   = var.APP
  COMPONENT             = "${var.COMPONENT}-settlement"
  ENV                   = var.ENV
  AWS_PRIMARY_REGION    = var.AWS_PRIMARY_REGION
  AWS_SECONDARY_REGION  = var.AWS_SECONDARY_REGION
}
