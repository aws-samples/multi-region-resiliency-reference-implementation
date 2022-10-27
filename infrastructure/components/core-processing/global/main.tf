// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "aurora" {

  source                = "../../../modules/aurora"

  APP                   = var.APP
  COMPONENT             = var.COMPONENT
  AWS_PRIMARY_REGION    = var.AWS_PRIMARY_REGION
  AWS_SECONDARY_REGION  = var.AWS_SECONDARY_REGION
  ENV                   = var.ENV
}



