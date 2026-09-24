// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "AWS_REGION" {

  type = string
}

variable "APP" {

  type = string
}

variable "APP_SHORT" {

  type = string
}

variable "COMPONENT" {

  type = string
}

variable "COMPONENT_SHORT" {

  type = string
}

variable "ENV" {

  type = string
}

variable "VPC_ID" {

  type = string
}

variable "SUBNET_IDS" {

  type = list(string)
}

variable "ELB_SECURITY_GROUP_ID" {

  type = string
}

variable "ECS_SECURITY_GROUP_ID" {

  type = string
}

variable "CONTAINER_COUNT" {

  type = string
}

variable "TASK_COUNT" {

  type = string
}

variable "ECS_INSTANCE_TYPE" {

  type = string
  default = "t3.large"
}

# The ECS-optimized AMI is resolved dynamically at deploy time from the public
# SSM parameter /aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id
