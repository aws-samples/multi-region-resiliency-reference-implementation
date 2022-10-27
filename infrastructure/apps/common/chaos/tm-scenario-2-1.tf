// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "tm_in_gateway_stop_all_ECS_EC2_instances" {

  source        = "./template3"

  NAME          = "tm-in-gateway-stop-all-ECS-EC2-instances"
  APP           = "trade-matching"
  COMPONENT     = "in-gateway"
  SELECTION     = "ALL"
  STOP          = "tm-in-gateway-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "tm_ingress_stop_all_ECS_EC2_instances" {

  source        = "./template3"

  NAME          = "tm-ingress-stop-all-ECS-EC2-instances"
  APP           = "trade-matching"
  COMPONENT     = "ingress"
  SELECTION     = "ALL"
  STOP          = "tm-ingress-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "tm_core_matching_stop_all_ECS_EC2_instances" {

  source        = "./template3"

  NAME          = "tm-core-matching-stop-all-ECS-EC2-instances"
  APP           = "trade-matching"
  COMPONENT     = "core-matching"
  SELECTION     = "ALL"
  STOP          = "tm-core-matching-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "tm_egress_stop_all_ECS_EC2_instances" {

  source        = "./template3"

  NAME          = "tm-egress-stop-all-ECS-EC2-instances"
  APP           = "trade-matching"
  COMPONENT     = "egress"
  SELECTION     = "ALL"
  STOP          = "tm-egress-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "tm_out_gateway_stop_all_ECS_EC2_instances" {

  source        = "./template3"

  NAME          = "tm-out-gateway-stop-all-ECS-EC2-instances"
  APP           = "trade-matching"
  COMPONENT     = "out-gateway"
  SELECTION     = "ALL"
  STOP          = "tm-out-gateway-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}