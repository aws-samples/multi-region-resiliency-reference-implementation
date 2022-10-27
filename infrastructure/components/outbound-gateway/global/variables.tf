// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "AWS_PRIMARY_REGION" {

  type = string
}

variable "AWS_SECONDARY_REGION" {

  type = string
}

variable "APP" {

  type = string
}

variable "COMPONENT" {

  type = string
  default = "out-gateway"
}

variable "ENV" {

  type = string
}

variable "TRADE_FLOW" {

  type = bool
}

variable "SETTLEMENT_FLOW" {

  type = bool
}

