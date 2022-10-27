// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "sm_in_gateway_terminate_all_ECS_EC2_instances" {

  source        = "./template3"

  NAME          = "sm-in-gateway-terminate-all-ECS-EC2-instances"
  APP           = "settlement"
  COMPONENT     = "in-gateway"
  SELECTION     = "ALL"
  STOP          = "sm-in-gateway-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "sm_ingress_terminate_all_ECS_EC2_instances" {

  source        = "./template3"

  NAME          = "sm-ingress-terminate-all-ECS-EC2-instances"
  APP           = "settlement"
  COMPONENT     = "ingress"
  SELECTION     = "ALL"
  STOP          = "sm-ingress-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "sm_core_matching_terminate_all_ECS_EC2_instances" {

  source        = "./template3"

  NAME          = "sm-core-matching-terminate-all-ECS-EC2-instances"
  APP           = "settlement"
  COMPONENT     = "core-matching"
  SELECTION     = "ALL"
  STOP          = "sm-core-matching-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "sm_egress_terminate_all_ECS_EC2_instances" {

  source        = "./template3"

  NAME          = "sm-egress-terminate-all-ECS-EC2-instances"
  APP           = "settlement"
  COMPONENT     = "egress"
  SELECTION     = "ALL"
  STOP          = "sm-egress-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "sm_out_gateway_terminate_all_ECS_EC2_instances" {

  source        = "./template3"

  NAME          = "sm-out-gateway-terminate-all-ECS-EC2-instances"
  APP           = "settlement"
  COMPONENT     = "out-gateway"
  SELECTION     = "ALL"
  STOP          = "sm-out-gateway-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}