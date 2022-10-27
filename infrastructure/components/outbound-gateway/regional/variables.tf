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
  default = "out-gateway"
}

variable "COMPONENT_SHORT" {

  type = string
  default = "out"
}

variable "ENV" {

  type = string
}

variable "VPC_ID" {

  type = string
}

variable "PUBLIC_SUBNET_IDS" {

  type = list(string)
}

variable "PRIVATE_SUBNET_IDS" {

  type = list(string)
}

variable "MQ_SECURITY_GROUP_ID" {

  type = string
}

variable "ELB_SECURITY_GROUP_ID" {

  type = string
}

variable "ECS_SECURITY_GROUP_ID" {

  type = string
}

variable "SHARDS" {

  type = number
  default = 6
}

variable "TRADE_FLOW" {

  type = bool
}

variable "SETTLEMENT_FLOW" {

  type = bool
}