// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "sm_in_gateway_stress_one_ECS_EC2_instances" {

  source        = "./template4"

  NAME          = "sm-in-gateway-stress-one-ECS-EC2-instance"
  APP           = "settlement"
  COMPONENT     = "in-gateway"
  SELECTION     = "COUNT(1)"
  STOP          = "sm-in-gateway-ecs-ec2-cpu-stress"
  ROLE          = "team-fis-role"
}

module "sm_ingress_stress_one_ECS_EC2_instances" {

  source        = "./template4"

  NAME          = "sm-ingress-stress-one-ECS-EC2-instance"
  APP           = "settlement"
  COMPONENT     = "ingress"
  SELECTION     = "COUNT(1)"
  STOP          = "sm-ingress-ecs-ec2-cpu-stress"
  ROLE          = "team-fis-role"
}

module "sm_core_matching_stress_one_ECS_EC2_instances" {

  source        = "./template4"

  NAME          = "sm-core-matching-stress-one-ECS-EC2-instance"
  APP           = "settlement"
  COMPONENT     = "core-matching"
  SELECTION     = "COUNT(1)"
  STOP          = "sm-core-matching-ecs-ec2-cpu-stress"
  ROLE          = "team-fis-role"
}

module "sm_egress_stress_one_ECS_EC2_instances" {

  source        = "./template4"

  NAME          = "sm-egress-stress-one-ECS-EC2-instance"
  APP           = "settlement"
  COMPONENT     = "egress"
  SELECTION     = "COUNT(1)"
  STOP          = "sm-egress-ecs-ec2-cpu-stress"
  ROLE          = "team-fis-role"
}

module "sm_out_gateway_stress_one_ECS_EC2_instances" {

  source        = "./template4"

  NAME          = "sm-out-gateway-stress-one-ECS-EC2-instance"
  APP           = "settlement"
  COMPONENT     = "out-gateway"
  SELECTION     = "COUNT(1)"
  STOP          = "sm-out-gateway-ecs-ec2-cpu-stress"
  ROLE          = "team-fis-role"
}