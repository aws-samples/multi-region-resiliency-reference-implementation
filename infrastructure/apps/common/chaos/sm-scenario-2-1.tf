// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "sm_in_gateway_stop_all_ECS_EC2_instances" {

  source        = "./template2"

  NAME          = "sm-in-gateway-stop-all-ECS-EC2-instances"
  APP           = "settlement"
  COMPONENT     = "in-gateway"
  SELECTION     = "ALL"
  STOP          = "sm-in-gateway-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "sm_ingress_stop_all_ECS_EC2_instances" {

  source        = "./template2"

  NAME          = "sm-ingress-stop-all-ECS-EC2-instances"
  APP           = "settlement"
  COMPONENT     = "ingress"
  SELECTION     = "ALL"
  STOP          = "sm-ingress-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "sm_core_matching_stop_all_ECS_EC2_instances" {

  source        = "./template2"

  NAME          = "sm-core-matching-stop-all-ECS-EC2-instances"
  APP           = "settlement"
  COMPONENT     = "core-matching"
  SELECTION     = "ALL"
  STOP          = "sm-core-matching-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "sm_egress_stop_all_ECS_EC2_instances" {

  source        = "./template2"

  NAME          = "sm-egress-stop-all-ECS-EC2-instances"
  APP           = "settlement"
  COMPONENT     = "egress"
  SELECTION     = "ALL"
  STOP          = "sm-egress-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "sm_out_gateway_stop_all_ECS_EC2_instances" {

  source        = "./template2"

  NAME          = "sm-out-gateway-stop-all-ECS-EC2-instances"
  APP           = "settlement"
  COMPONENT     = "out-gateway"
  SELECTION     = "ALL"
  STOP          = "sm-out-gateway-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}