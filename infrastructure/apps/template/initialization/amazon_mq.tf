// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "random_password" "in-gateway-mq-password" {

  length           = 12
  upper            = true
  lower            = true
  number           = true
  special          = false
  override_special = "!@#$%&*()-_+[]{}<>?"
}

locals {
  in-gateway-mq-password_value =  random_password.in-gateway-mq-password.result
}

module "in-gateway-mq-secret" {

  source                = "../../../modules/secret"

  NAME                  = "${var.APP}-in-gateway-mq"
  VALUE                 = local.in-gateway-mq-password_value
  AWS_BACKUP_REGION     = var.AWS_SECONDARY_REGION
}

resource "random_password" "out-gateway-mq-password" {

  length           = 12
  upper            = true
  lower            = true
  number           = true
  special          = false
  override_special = "!@#$%&*()-_+[]{}<>?"
}

locals {
  out-gateway-mq-password_value =  random_password.out-gateway-mq-password.result
}

module "out-gateway-mq-secret" {

  source                = "../../../modules/secret"

  NAME                  = "${var.APP}-out-gateway-mq"
  VALUE                 = local.out-gateway-mq-password_value
  AWS_BACKUP_REGION     = var.AWS_SECONDARY_REGION
}
