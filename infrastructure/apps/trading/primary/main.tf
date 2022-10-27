// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "trading" {

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

module "trade-generator" {

  source                    = "../../../components/trade-generator/regional"

  AWS_REGION                = var.AWS_REGION
  APP                       = "trade"
  APP_SHORT                 = "tm"
  COMPONENT                 = "generator"
  ENV                       = var.ENV
  VPC_ID                    = module.trading.vpc_id
  PUBLIC_SUBNET_IDS         = module.trading.public_subnets
  PRIVATE_SUBNET_IDS        = module.trading.private_subnets
  ELB_SECURITY_GROUP_ID     = module.trading.elb_security_group_id
  ECS_SECURITY_GROUP_ID     = module.trading.ecs_security_group_id
}