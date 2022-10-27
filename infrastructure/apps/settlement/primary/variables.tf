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

variable "ENV" {

  type = string
}

variable "CIDR" {

  type = string
}

variable "PEER_CIDR" {

  type = list(string)
}

variable "PRIVATE_SUBNETS" {

  type = list(string)
}

variable "PUBLIC_SUBNETS" {

  type = list(string)
}

variable "TRADE_FLOW" {

  type = bool
}

variable "SETTLEMENT_FLOW" {

  type = bool
}