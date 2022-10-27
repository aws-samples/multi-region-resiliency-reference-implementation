// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "AWS_REGION" {

  type = string
}

variable "AWS_BACKUP_REGION" {

  type = string
  default = "us-west-2"
}

variable "APP" {

  type = string
}

variable "LOCATION" {

  type = string
}

variable "ENV" {

  type = string
}

variable "KEY_ARN" {

  type = string
}