// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "trade-matching-in-gateway-mq" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  AWS_PRIMARY_REGION        = var.AWS_PRIMARY_REGION
  AWS_SECONDARY_REGION      = var.AWS_SECONDARY_REGION
  APP                       = "trade-matching"
  COMPONENT                 = "in-gateway"
}

module "trade-matching-out-gateway-mq" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  AWS_PRIMARY_REGION        = var.AWS_PRIMARY_REGION
  AWS_SECONDARY_REGION      = var.AWS_SECONDARY_REGION
  APP                       = "trade-matching"
  COMPONENT                 = "out-gateway"
}

module "settlement-in-gateway-mq" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  AWS_PRIMARY_REGION        = var.AWS_PRIMARY_REGION
  AWS_SECONDARY_REGION      = var.AWS_SECONDARY_REGION
  APP                       = "settlement"
  COMPONENT                 = "in-gateway"
}

module "settlement-out-gateway-mq" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  AWS_PRIMARY_REGION        = var.AWS_PRIMARY_REGION
  AWS_SECONDARY_REGION      = var.AWS_SECONDARY_REGION
  APP                       = "settlement"
  COMPONENT                 = "out-gateway"
}

