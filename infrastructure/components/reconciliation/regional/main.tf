// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

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
  CONTAINER_COUNT       = "1"
  TASK_COUNT            = "0"
}

resource "aws_ssm_parameter" "reconciliation-roll-back-time" {

  name  = "/approtation/reconciliation/roll-back-time"
  type  = "SecureString"
  value = "86400"
  overwrite = true
}
