// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "sm_in_gateway_stop_all_ECS_instances" {

  source        = "./template1"

  NAME          = "sm-in-gateway-stop-all-ECS-tasks"
  APP           = "settlement"
  COMPONENT     = "in-gateway"
  SELECTION     = "ALL"
  STOP          = "sm-in-gateway-ecs-task-count"
  ROLE          = "team-fis-role"
}

module "sm_ingress_stop_all_ECS_instances" {

  source        = "./template1"

  NAME          = "sm-ingress-stop-all-ECS-tasks"
  APP           = "settlement"
  COMPONENT     = "ingress"
  SELECTION     = "ALL"
  STOP          = "sm-ingress-ecs-task-count"
  ROLE          = "team-fis-role"
}

module "sm_core_matching_stop_all_ECS_instances" {

  source        = "./template1"

  NAME          = "sm-core-matching-stop-all-ECS-tasks"
  APP           = "settlement"
  COMPONENT     = "core-matching"
  SELECTION     = "ALL"
  STOP          = "sm-core-matching-ecs-task-count"
  ROLE          = "team-fis-role"
}

module "sm_egress_stop_all_ECS_instances" {

  source        = "./template1"

  NAME          = "sm-egress-stop-all-ECS-tasks"
  APP           = "settlement"
  COMPONENT     = "egress"
  SELECTION     = "ALL"
  STOP          = "sm-egress-ecs-task-count"
  ROLE          = "team-fis-role"
}

module "sm_out_gateway_stop_all_ECS_instances" {

  source        = "./template1"

  NAME          = "sm-out-gateway-stop-all-ECS-tasks"
  APP           = "settlement"
  COMPONENT     = "out-gateway"
  SELECTION     = "ALL"
  STOP          = "sm-out-gateway-ecs-task-count"
  ROLE          = "team-fis-role"
}