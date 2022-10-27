// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "settlement" {

  source                    = "../../template/regional"

  AWS_REGION                = var.AWS_REGION
  AWS_BACKUP_REGION         = var.AWS_BACKUP_REGION
  APP                       = var.APP
  APP_SHORT                 = var.APP_SHORT
  ENV                       = var.ENV
  CIDR                      = var.CIDR
  PEER_CIDR                 = var.PEER_CIDR
  PRIVATE_SUBNETS           = var.PRIVATE_SUBNETS
  PUBLIC_SUBNETS            = var.PUBLIC_SUBNETS
  TRADE_FLOW                = var.TRADE_FLOW
  SETTLEMENT_FLOW           = var.SETTLEMENT_FLOW
}