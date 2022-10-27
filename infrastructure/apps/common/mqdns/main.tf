// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "trade-matching-in" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  AWS_PRIMARY_REGION        = var.AWS_PRIMARY_REGION
  AWS_SECONDARY_REGION      = var.AWS_SECONDARY_REGION
  APP                       = "trade-matching"
  PEER_APP                  = "settlement"
  COMPONENT                 = "in-gateway"
  COMPONENT_SHORT           = "in"
}

module "trade-matching-out" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  AWS_PRIMARY_REGION        = var.AWS_PRIMARY_REGION
  AWS_SECONDARY_REGION      = var.AWS_SECONDARY_REGION
  APP                       = "trade-matching"
  PEER_APP                  = "settlement"
  COMPONENT                 = "out-gateway"
  COMPONENT_SHORT           = "out"
}

module "settlement-in" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  AWS_PRIMARY_REGION        = var.AWS_PRIMARY_REGION
  AWS_SECONDARY_REGION      = var.AWS_SECONDARY_REGION
  APP                       = "settlement"
  PEER_APP                  = "trade-matching"
  COMPONENT                 = "in-gateway"
  COMPONENT_SHORT           = "in"
}

module "settlement-out" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  AWS_PRIMARY_REGION        = var.AWS_PRIMARY_REGION
  AWS_SECONDARY_REGION      = var.AWS_SECONDARY_REGION
  APP                       = "settlement"
  PEER_APP                  = "trade-matching"
  COMPONENT                 = "out-gateway"
  COMPONENT_SHORT           = "out"
}



