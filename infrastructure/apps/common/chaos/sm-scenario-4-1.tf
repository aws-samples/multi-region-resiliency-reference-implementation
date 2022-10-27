// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "sm_in_gateway_stress_all_ECS_EC2_instances" {

  source        = "./template4"

  NAME          = "sm-in-gateway-stress-all-ECS-EC2-instances"
  APP           = "settlement"
  COMPONENT     = "in-gateway"
  SELECTION     = "ALL"
  STOP          = "sm-in-gateway-ecs-ec2-cpu-stress"
  ROLE          = "team-fis-role"
}

module "sm_ingress_stress_all_ECS_EC2_instances" {

  source        = "./template4"

  NAME          = "sm-ingress-stress-all-ECS-EC2-instances"
  APP           = "settlement"
  COMPONENT     = "ingress"
  SELECTION     = "ALL"
  STOP          = "sm-ingress-ecs-ec2-cpu-stress"
  ROLE          = "team-fis-role"
}

module "sm_core_matching_stress_all_ECS_EC2_instances" {

  source        = "./template4"

  NAME          = "sm-core-matching-stress-all-ECS-EC2-instances"
  APP           = "settlement"
  COMPONENT     = "core-matching"
  SELECTION     = "ALL"
  STOP          = "sm-core-matching-ecs-ec2-cpu-stress"
  ROLE          = "team-fis-role"
}

module "sm_egress_stress_all_ECS_EC2_instances" {

  source        = "./template4"

  NAME          = "sm-egress-stress-all-ECS-EC2-instances"
  APP           = "settlement"
  COMPONENT     = "egress"
  SELECTION     = "ALL"
  STOP          = "sm-egress-ecs-ec2-cpu-stress"
  ROLE          = "team-fis-role"
}

module "sm_out_gateway_stress_all_ECS_EC2_instances" {

  source        = "./template4"

  NAME          = "sm-out-gateway-stress-all-ECS-EC2-instances"
  APP           = "settlement"
  COMPONENT     = "out-gateway"
  SELECTION     = "ALL"
  STOP          = "sm-out-gateway-ecs-ec2-cpu-stress"
  ROLE          = "team-fis-role"
}