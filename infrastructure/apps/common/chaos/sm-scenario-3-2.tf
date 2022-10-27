// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "sm_in_gateway_terminate_one_ECS_EC2_instances" {

  source        = "./template3"

  NAME          = "sm-in-gateway-terminate-one-ECS-EC2-instance"
  APP           = "settlement"
  COMPONENT     = "in-gateway"
  SELECTION     = "COUNT(1)"
  STOP          = "sm-in-gateway-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "sm_ingress_terminate_one_ECS_EC2_instances" {

  source        = "./template3"

  NAME          = "sm-ingress-terminate-one-ECS-EC2-instance"
  APP           = "settlement"
  COMPONENT     = "ingress"
  SELECTION     = "COUNT(1)"
  STOP          = "sm-ingress-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "sm_core_matching_terminate_one_ECS_EC2_instances" {

  source        = "./template3"

  NAME          = "sm-core-matching-terminate-one-ECS-EC2-instance"
  APP           = "settlement"
  COMPONENT     = "core-matching"
  SELECTION     = "COUNT(1)"
  STOP          = "sm-core-matching-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "sm_egress_terminate_one_ECS_EC2_instances" {

  source        = "./template3"

  NAME          = "sm-egress-terminate-one-ECS-EC2-instance"
  APP           = "settlement"
  COMPONENT     = "egress"
  SELECTION     = "COUNT(1)"
  STOP          = "sm-egress-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "sm_out_gateway_terminate_one_ECS_EC2_instances" {

  source        = "./template3"

  NAME          = "sm-out-gateway-terminate-one-ECS-EC2-instance"
  APP           = "settlement"
  COMPONENT     = "out-gateway"
  SELECTION     = "COUNT(1)"
  STOP          = "sm-out-gateway-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}