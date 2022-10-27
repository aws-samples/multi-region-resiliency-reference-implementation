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

variable "ENV" {

  type = string
}

variable "CIDR" {

  type = string
}

variable "PRIVATE_SUBNETS" {

  type = list(string)
}

variable "PUBLIC_SUBNETS" {

  type = list(string)
}