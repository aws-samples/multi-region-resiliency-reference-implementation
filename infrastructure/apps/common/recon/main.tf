// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "dynamodb" {

  source                = "../../../modules/dynamodb"

  APP                   = var.APP
  COMPONENT             = var.COMPONENT
  ENV                   = var.ENV
  AWS_PRIMARY_REGION    = var.AWS_PRIMARY_REGION
  AWS_SECONDARY_REGION  = var.AWS_SECONDARY_REGION
}