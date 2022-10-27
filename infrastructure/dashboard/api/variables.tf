// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "aws_region" {

  description = "AWS region for all resources."

  type    = string
  default = "us-east-1"
}

variable "ENV" {

  description = "The environment"

  type    = string
  default = "awsd1"
}