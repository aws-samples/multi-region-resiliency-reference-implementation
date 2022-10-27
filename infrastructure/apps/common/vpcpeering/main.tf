// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "trade-matching-primary-to-trade-matching-secondary" {

  source                = "../../../modules/vpc-peering"

  AWS_REGION            = var.AWS_REGION
  APP1                  = "trade-matching"
  REGION1               = var.AWS_PRIMARY_REGION
  APP2                  = "trade-matching"
  REGION2               = var.AWS_SECONDARY_REGION
}

module "trade-matching-primary-to-settlement-primary" {

  source                = "../../../modules/vpc-peering"

  AWS_REGION            = var.AWS_REGION
  APP1                  = "trade-matching"
  REGION1               = var.AWS_PRIMARY_REGION
  APP2                  = "settlement"
  REGION2               = var.AWS_PRIMARY_REGION
}

module "trade-matching-primary-to-settlement-secondary" {

  source                = "../../../modules/vpc-peering"

  AWS_REGION            = var.AWS_REGION
  APP1                  = "trade-matching"
  REGION1               = var.AWS_PRIMARY_REGION
  APP2                  = "settlement"
  REGION2               = var.AWS_SECONDARY_REGION
}

module "trade-matching-secondary-to-settlement-primary" {

  source                = "../../../modules/vpc-peering"

  AWS_REGION            = var.AWS_REGION
  APP1                  = "trade-matching"
  REGION1               = var.AWS_SECONDARY_REGION
  APP2                  = "settlement"
  REGION2               = var.AWS_PRIMARY_REGION
}

module "trade-matching-secondary-to-settlement-secondary" {

  source                = "../../../modules/vpc-peering"

  AWS_REGION            = var.AWS_REGION
  APP1                  = "trade-matching"
  REGION1               = var.AWS_SECONDARY_REGION
  APP2                  = "settlement"
  REGION2               = var.AWS_SECONDARY_REGION
}

module "settlement-primary-to-settlement-secondary" {

  source                = "../../../modules/vpc-peering"

  AWS_REGION            = var.AWS_REGION
  APP1                  = "settlement"
  REGION1               = var.AWS_PRIMARY_REGION
  APP2                  = "settlement"
  REGION2               = var.AWS_SECONDARY_REGION
}



