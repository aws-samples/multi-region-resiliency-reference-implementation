// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "inbound-gateway" {

  source                = "../../../components/inbound-gateway/regional"

  AWS_REGION            = var.AWS_REGION
  AWS_BACKUP_REGION     = var.AWS_BACKUP_REGION
  APP                   = var.APP
  APP_SHORT             = var.APP_SHORT
  ENV                   = var.ENV
  VPC_ID                = module.approtation-vpc.vpc_id
  PUBLIC_SUBNET_IDS     = module.approtation-vpc.public_subnets
  PRIVATE_SUBNET_IDS    = module.approtation-vpc.private_subnets
  MQ_SECURITY_GROUP_ID  = aws_security_group.mq_sg.id
  ELB_SECURITY_GROUP_ID = aws_security_group.elb-sg.id
  ECS_SECURITY_GROUP_ID = aws_security_group.ecs-sg.id
  TRADE_FLOW            = var.TRADE_FLOW
  SETTLEMENT_FLOW       = var.SETTLEMENT_FLOW
}

module "ingress" {

  source                = "../../../components/ingress/regional"

  AWS_REGION            = var.AWS_REGION
  APP                   = var.APP
  APP_SHORT             = var.APP_SHORT
  ENV                   = var.ENV
  VPC_ID                = module.approtation-vpc.vpc_id
  PUBLIC_SUBNET_IDS     = module.approtation-vpc.public_subnets
  PRIVATE_SUBNET_IDS    = module.approtation-vpc.private_subnets
  ELB_SECURITY_GROUP_ID = aws_security_group.elb-sg.id
  ECS_SECURITY_GROUP_ID = aws_security_group.ecs-sg.id
  TRADE_FLOW            = var.TRADE_FLOW
  SETTLEMENT_FLOW       = var.SETTLEMENT_FLOW
}

module "core-processing" {

  source                = "../../../components/core-processing/regional"

  AWS_REGION            = var.AWS_REGION
  APP                   = var.APP
  APP_SHORT             = var.APP_SHORT
  ENV                   = var.ENV
  VPC_ID                = module.approtation-vpc.vpc_id
  PUBLIC_SUBNET_IDS     = module.approtation-vpc.public_subnets
  PRIVATE_SUBNET_IDS    = module.approtation-vpc.private_subnets
  ELB_SECURITY_GROUP_ID = aws_security_group.elb-sg.id
  ECS_SECURITY_GROUP_ID = aws_security_group.ecs-sg.id
  TRADE_FLOW            = var.TRADE_FLOW
  SETTLEMENT_FLOW       = var.SETTLEMENT_FLOW
}

module "egress" {

  source                = "../../../components/egress/regional"

  AWS_REGION            = var.AWS_REGION
  APP                   = var.APP
  APP_SHORT             = var.APP_SHORT
  ENV                   = var.ENV
  VPC_ID                = module.approtation-vpc.vpc_id
  PUBLIC_SUBNET_IDS     = module.approtation-vpc.public_subnets
  PRIVATE_SUBNET_IDS    = module.approtation-vpc.private_subnets
  ELB_SECURITY_GROUP_ID = aws_security_group.elb-sg.id
  ECS_SECURITY_GROUP_ID = aws_security_group.ecs-sg.id
  TRADE_FLOW            = var.TRADE_FLOW
  SETTLEMENT_FLOW       = var.SETTLEMENT_FLOW
}

module "outbound-gateway" {

  source                = "../../../components/outbound-gateway/regional"

  AWS_REGION            = var.AWS_REGION
  AWS_BACKUP_REGION     = var.AWS_BACKUP_REGION
  APP                   = var.APP
  APP_SHORT             = var.APP_SHORT
  ENV                   = var.ENV
  VPC_ID                = module.approtation-vpc.vpc_id
  PUBLIC_SUBNET_IDS     = module.approtation-vpc.public_subnets
  PRIVATE_SUBNET_IDS    = module.approtation-vpc.private_subnets
  MQ_SECURITY_GROUP_ID  = aws_security_group.mq_sg.id
  ELB_SECURITY_GROUP_ID = aws_security_group.elb-sg.id
  ECS_SECURITY_GROUP_ID = aws_security_group.ecs-sg.id
  TRADE_FLOW            = var.TRADE_FLOW
  SETTLEMENT_FLOW       = var.SETTLEMENT_FLOW
}

module "reconciliation" {

  source                = "../../../components/reconciliation/regional"

  AWS_REGION            = var.AWS_REGION
  APP                   = var.APP
  APP_SHORT             = var.APP_SHORT
  ENV                   = var.ENV
  VPC_ID                = module.approtation-vpc.vpc_id
  PUBLIC_SUBNET_IDS     = module.approtation-vpc.public_subnets
  PRIVATE_SUBNET_IDS    = module.approtation-vpc.private_subnets
  ELB_SECURITY_GROUP_ID = aws_security_group.elb-sg.id
  ECS_SECURITY_GROUP_ID = aws_security_group.ecs-sg.id
}






