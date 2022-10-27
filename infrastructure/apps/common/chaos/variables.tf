// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "AWS_REGION" {

  type    = string
  default = "us-east-1"
}

variable "AWS_PRIMARY_REGION" {

  type    = string
  default = "us-east-1"
}

variable "AWS_SECONDARY_REGION" {

  type    = string
  default = "us-west-2"
}

variable "ENV" {

  type    = string
  default = "awsd1"
}