// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "AWS_REGION" {
  type = string
}

variable "REPOSITORY_NAME" {
  type = string
  default = "approtation-repo"
}

variable "REPOSITORY_BRANCH_NAME" {
    description = "Source repo branch name"
    type = string
    default = "main"
}


variable "ENV" {
  type = string
}

