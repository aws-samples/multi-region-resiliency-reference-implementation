// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

provider "aws" {

  region = var.AWS_REGION
}

provider "aws" {

  alias  = "acm_provider"
  region = var.AWS_REGION
}