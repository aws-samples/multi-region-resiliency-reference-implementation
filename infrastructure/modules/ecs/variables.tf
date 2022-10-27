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
  default = "t2.large"
}

variable "ECS_AMIS" {

  type = map(string)
  default = {
    us-east-1 = "ami-0c5c9bcfb36b772fe"
    us-west-2 = "ami-0b250f625dc7f2bc9"
  }
}

# Full List: http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
