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

variable "ENV" {

  type = string
}

variable "COMPONENT" {

  type = string
}

variable "DB_ENGINE" {

  type = string
  default = "aurora-postgresql"
}

variable "DB_ENGINE_VERSION" {

  type = string
  default = "11.9"
}

variable "DB_INSTANCE_CLASS" {

  type = string
  default = "db.r4.large"
}