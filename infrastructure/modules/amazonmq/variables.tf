// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "AWS_REGION" {

  type = string
}

variable "AWS_BACKUP_REGION" {

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

variable "MQ_INSTANCE_TYPE" {

  type = string
  default = "mq.m5.large"
}

variable "VPC_ID" {

  type = string
}

variable "SUBNET_IDS" {

  type = list(string)
}

variable "MQ_SECURITY_GROUP_ID" {

  type = string
}

variable "ENGINE_TYPE" {

  type = string
  default = "ActiveMQ"
}

variable "ENGINE_VERSION" {

  type = string
  default = "5.16.4"
}