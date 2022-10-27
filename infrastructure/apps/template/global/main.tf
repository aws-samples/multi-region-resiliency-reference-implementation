// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "inbound-gateway" {

  source                = "../../../components/inbound-gateway/global"

  AWS_PRIMARY_REGION    = var.AWS_PRIMARY_REGION
  AWS_SECONDARY_REGION  = var.AWS_SECONDARY_REGION
  APP                   = var.APP
  ENV                   = var.ENV
  TRADE_FLOW            = var.TRADE_FLOW
  SETTLEMENT_FLOW       = var.SETTLEMENT_FLOW
}

module "ingress" {

  source                = "../../../components/ingress/global"

  AWS_PRIMARY_REGION    = var.AWS_PRIMARY_REGION
  AWS_SECONDARY_REGION  = var.AWS_SECONDARY_REGION
  APP                   = var.APP
  ENV                   = var.ENV
  TRADE_FLOW            = var.TRADE_FLOW
  SETTLEMENT_FLOW       = var.SETTLEMENT_FLOW
}

module "core-processing" {

  source                = "../../../components/core-processing/global"

  AWS_PRIMARY_REGION    = var.AWS_PRIMARY_REGION
  AWS_SECONDARY_REGION  = var.AWS_SECONDARY_REGION
  APP                   = var.APP
  ENV                   = var.ENV
  TRADE_FLOW            = var.TRADE_FLOW
  SETTLEMENT_FLOW       = var.SETTLEMENT_FLOW
}

module "egress" {

  source                = "../../../components/egress/global"

  AWS_PRIMARY_REGION    = var.AWS_PRIMARY_REGION
  AWS_SECONDARY_REGION  = var.AWS_SECONDARY_REGION
  APP                   = var.APP
  ENV                   = var.ENV
  TRADE_FLOW            = var.TRADE_FLOW
  SETTLEMENT_FLOW       = var.SETTLEMENT_FLOW
}

module "outbound-gateway" {

  source                = "../../../components/outbound-gateway/global"

  AWS_PRIMARY_REGION    = var.AWS_PRIMARY_REGION
  AWS_SECONDARY_REGION  = var.AWS_SECONDARY_REGION
  APP                   = var.APP
  ENV                   = var.ENV
  TRADE_FLOW            = var.TRADE_FLOW
  SETTLEMENT_FLOW       = var.SETTLEMENT_FLOW
}




