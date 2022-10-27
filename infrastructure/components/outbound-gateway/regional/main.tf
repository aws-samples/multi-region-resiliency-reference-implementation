// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "amazon-mq" {

  source                = "../../../modules/amazonmq"

  AWS_REGION            = var.AWS_REGION
  AWS_BACKUP_REGION     = var.AWS_BACKUP_REGION
  APP                   = var.APP
  APP_SHORT             = var.APP_SHORT
  COMPONENT             = var.COMPONENT
  COMPONENT_SHORT       = var.COMPONENT_SHORT
  ENV                   = var.ENV
  VPC_ID                = var.VPC_ID
  SUBNET_IDS            = [var.PRIVATE_SUBNET_IDS[0], var.PRIVATE_SUBNET_IDS[1]]
  MQ_SECURITY_GROUP_ID     = var.MQ_SECURITY_GROUP_ID
}

module "kinesis-trade" {

  source                = "../../../modules/kinesis"
  count                 = var.TRADE_FLOW? 1:0

  AWS_REGION            = var.AWS_REGION
  APP                   = var.APP
  COMPONENT             = "${var.COMPONENT}-trade"
  ENV                   = var.ENV
  SHARDS                = var.SHARDS
}

module "kinesis-settlement" {

  source                = "../../../modules/kinesis"
  count                 = var.SETTLEMENT_FLOW? 1:0

  AWS_REGION            = var.AWS_REGION
  APP                   = var.APP
  COMPONENT             = "${var.COMPONENT}-settlement"
  ENV                   = var.ENV
  SHARDS                = var.SHARDS
}

module "ecs" {

  source                = "../../../modules/ecs"

  AWS_REGION            = var.AWS_REGION
  APP                   = var.APP
  APP_SHORT             = var.APP_SHORT
  COMPONENT             = var.COMPONENT
  COMPONENT_SHORT       = var.COMPONENT_SHORT
  ENV                   = var.ENV
  VPC_ID                = var.VPC_ID
  SUBNET_IDS            = var.PRIVATE_SUBNET_IDS
  ELB_SECURITY_GROUP_ID = var.ELB_SECURITY_GROUP_ID
  ECS_SECURITY_GROUP_ID = var.ECS_SECURITY_GROUP_ID
  CONTAINER_COUNT       = "3"
  TASK_COUNT            = "3"
}
