// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "private-certificate-authority-primary" {

  source                = "../../../modules/private-ca"

  AWS_PRIMARY_REGION    = var.AWS_PRIMARY_REGION
  AWS_SECONDARY_REGION  = var.AWS_SECONDARY_REGION
  APP                   = var.APP
  DOMAIN                = var.DOMAIN
  ALGORITHM             = var.ALGORITHM
  KEY_ALGORITHM         = var.KEY_ALGORITHM
  SIGNING_ALGORITHM     = var.SIGNING_ALGORITHM
  VALIDITY              = var.VALIDITY
}

module "private-certificate-authority-secondary" {

  source                = "../../../modules/private-ca"

  AWS_PRIMARY_REGION    = var.AWS_SECONDARY_REGION
  AWS_SECONDARY_REGION  = var.AWS_PRIMARY_REGION
  APP                   = var.APP
  DOMAIN                = var.DOMAIN
  ALGORITHM             = var.ALGORITHM
  KEY_ALGORITHM         = var.KEY_ALGORITHM
  SIGNING_ALGORITHM     = var.SIGNING_ALGORITHM
  VALIDITY              = var.VALIDITY
}
