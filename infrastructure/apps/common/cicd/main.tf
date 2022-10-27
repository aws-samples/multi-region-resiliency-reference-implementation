// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

provider "aws" {
  alias  = "primary"
  region = var.AWS_PRIMARY_REGION
}

provider "aws" {
  alias  = "secondary"
  region = var.AWS_SECONDARY_REGION
}

module "cicd_main" {
  source = "template"
  AWS_REGION            = var.AWS_PRIMARY_REGION
  ENV                   = var.ENV

}

module "cicd_secondary" {
  source = "template"
  AWS_REGION            = var.AWS_SECONDARY_REGION
  ENV                   = var.ENV
}