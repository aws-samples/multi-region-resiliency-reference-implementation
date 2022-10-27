// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "tm_in_gateway_stop_one_ECS_EC2_instances" {

  source        = "./template3"

  NAME          = "tm-in-gateway-stop-one-ECS-EC2-instance"
  APP           = "trade-matching"
  COMPONENT     = "in-gateway"
  SELECTION     = "COUNT(1)"
  STOP          = "tm-in-gateway-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "tm_ingress_stop_one_ECS_EC2_instances" {

  source        = "./template3"

  NAME          = "tm-ingress-stop-one-ECS-EC2-instance"
  APP           = "trade-matching"
  COMPONENT     = "ingress"
  SELECTION     = "COUNT(1)"
  STOP          = "tm-ingress-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "tm_core_matching_stop_one_ECS_EC2_instances" {

  source        = "./template3"

  NAME          = "tm-core-matching-stop-one-ECS-EC2-instance"
  APP           = "trade-matching"
  COMPONENT     = "core-matching"
  SELECTION     = "COUNT(1)"
  STOP          = "tm-core-matching-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "tm_egress_stop_one_ECS_EC2_instances" {

  source        = "./template3"

  NAME          = "tm-egress-stop-one-ECS-EC2-instance"
  APP           = "trade-matching"
  COMPONENT     = "egress"
  SELECTION     = "COUNT(1)"
  STOP          = "tm-egress-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

module "tm_out_gateway_stop_one_ECS_EC2_instances" {

  source        = "./template3"

  NAME          = "tm-out-gateway-stop-one-ECS-EC2-instance"
  APP           = "trade-matching"
  COMPONENT     = "out-gateway"
  SELECTION     = "COUNT(1)"
  STOP          = "tm-out-gateway-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}