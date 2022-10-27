// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

provider "aws" {

  alias  = "primary-provider"
  region = var.AWS_PRIMARY_REGION
}

provider "aws" {

  alias  = "secondary-provider"
  region = var.AWS_SECONDARY_REGION
}




