// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "sm_in_gateway_stop_one_ECS_EC2_instances" {

  source        = "./template2"

  NAME          = "sm-in-gateway-stop-one-ECS-EC2-instance"
  APP           = "settlement"
  COMPONENT     = "in-gateway"
  SELECTION     = "COUNT(1)"
  STOP          = "sm-in-gateway-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "sm_ingress_stop_one_ECS_EC2_instances" {

  source        = "./template2"

  NAME          = "sm-ingress-stop-one-ECS-EC2-instance"
  APP           = "settlement"
  COMPONENT     = "ingress"
  SELECTION     = "COUNT(1)"
  STOP          = "sm-ingress-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "sm_core_matching_stop_one_ECS_EC2_instances" {

  source        = "./template2"

  NAME          = "sm-core-matching-stop-one-ECS-EC2-instance"
  APP           = "settlement"
  COMPONENT     = "core-matching"
  SELECTION     = "COUNT(1)"
  STOP          = "sm-core-matching-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "sm_egress_stop_one_ECS_EC2_instances" {

  source        = "./template2"

  NAME          = "sm-egress-stop-one-ECS-EC2-instance"
  APP           = "settlement"
  COMPONENT     = "egress"
  SELECTION     = "COUNT(1)"
  STOP          = "sm-egress-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "sm_out_gateway_stop_one_ECS_EC2_instances" {

  source        = "./template2"

  NAME          = "sm-out-gateway-stop-one-ECS-EC2-instance"
  APP           = "settlement"
  COMPONENT     = "out-gateway"
  SELECTION     = "COUNT(1)"
  STOP          = "sm-out-gateway-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}