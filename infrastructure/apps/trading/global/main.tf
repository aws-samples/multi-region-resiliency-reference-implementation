// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "trading" {

  source                    = "../../template/global"

  AWS_REGION                = var.AWS_REGION
  AWS_PRIMARY_REGION        = var.AWS_PRIMARY_REGION
  AWS_SECONDARY_REGION      = var.AWS_SECONDARY_REGION
  APP                       = var.APP
  ENV                       = var.ENV
  TRADE_FLOW                = var.TRADE_FLOW
  SETTLEMENT_FLOW           = var.SETTLEMENT_FLOW
}