// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "sm_in_gateway_stop_one_ECS_instances" {

  source        = "./template1"

  NAME          = "sm-in-gateway-stop-one-ECS-task"
  APP           = "settlement"
  COMPONENT     = "in-gateway"
  SELECTION     = "COUNT(1)"
  STOP          = "sm-in-gateway-ecs-task-count"
  ROLE          = "team-fis-role"
}

module "sm_ingress_stop_one_ECS_instances" {

  source        = "./template1"

  NAME          = "sm-ingress-stop-one-ECS-task"
  APP           = "settlement"
  COMPONENT     = "ingress"
  SELECTION     = "COUNT(1)"
  STOP          = "sm-ingress-ecs-task-count"
  ROLE          = "team-fis-role"
}

module "sm_core_matching_stop_one_ECS_instances" {

  source        = "./template1"

  NAME          = "sm-core-matching-stop-one-ECS-task"
  APP           = "settlement"
  COMPONENT     = "core-matching"
  SELECTION     = "COUNT(1)"
  STOP          = "sm-core-matching-ecs-task-count"
  ROLE          = "team-fis-role"
}

module "sm_egress_stop_one_ECS_instances" {

  source        = "./template1"

  NAME          = "sm-egress-stop-one-ECS-task"
  APP           = "settlement"
  COMPONENT     = "egress"
  SELECTION     = "COUNT(1)"
  STOP          = "sm-egress-ecs-task-count"
  ROLE          = "team-fis-role"
}

module "sm_out_gateway_stop_one_ECS_instances" {

  source        = "./template1"

  NAME          = "sm-out-gateway-stop-one-ECS-task"
  APP           = "settlement"
  COMPONENT     = "out-gateway"
  SELECTION     = "COUNT(1)"
  STOP          = "sm-out-gateway-ecs-task-count"
  ROLE          = "team-fis-role"
}