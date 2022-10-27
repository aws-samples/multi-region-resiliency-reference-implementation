// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "AWS_REGION" {

  type    = string
  default = "us-east-1"
}

variable "BUCKET_NAME" {

  type    = string
  default = "app-rotation-dashboard-portal"
}

variable "ENV" {

  type    = string
  default = "awsd1"
}