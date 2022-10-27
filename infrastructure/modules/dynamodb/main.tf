// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

data "aws_secretsmanager_secret" "dynamodb-primary-kms-key" {

  name = "${var.APP}-dynamodb-primary-kms-key"
}

data "aws_secretsmanager_secret_version" "dynamodb-primary-kms-key-version" {

  secret_id = data.aws_secretsmanager_secret.dynamodb-primary-kms-key.id
}

data "aws_secretsmanager_secret" "dynamodb-secondary-kms-key" {

  name = "${var.APP}-dynamodb-secondary-kms-key"
}

data "aws_secretsmanager_secret_version" "dynamodb-secondary-kms-key-version" {

  secret_id = data.aws_secretsmanager_secret.dynamodb-secondary-kms-key.id
}

module "dynamodb_table" {

  source   = "terraform-aws-modules/dynamodb-table/aws"

  name              = "${var.APP}-${var.COMPONENT}-dynamodb-store"
  hash_key          = "id"
  stream_enabled    = true
  stream_view_type  = "NEW_AND_OLD_IMAGES"
  server_side_encryption_enabled     = true
  server_side_encryption_kms_key_arn = data.aws_secretsmanager_secret_version.dynamodb-primary-kms-key-version.secret_string
  point_in_time_recovery_enabled = true
//  billing_mode  = "PROVISIONED"
//  read_capacity = 100
//  write_capacity = 100

  attributes = [
    {
      name = "id"
      type = "S"
    },
    {
      name = "timestamp"
      type = "N"
    },
    {
      name = "currentDate"
      type = "S"
    }
  ]

  global_secondary_indexes = [{
    name               = "currentDate"
    hash_key           = "currentDate"
    range_key          = "timestamp"
    projection_type    = "ALL"
    non_key_attributes = []
  }]

  replica_regions = [{
    region_name = var.AWS_SECONDARY_REGION
    kms_key_arn = data.aws_secretsmanager_secret_version.dynamodb-secondary-kms-key-version.secret_string
  }]

  tags = {
    Industry = "GFS"
    Program = "AppRotation"
    Application = var.APP
    Component   = var.COMPONENT
    Environment = var.ENV
  }
}

//resource "aws_ssm_parameter" "dynamodb_param" {
//  name  = "/approtation/${var.APP}/${var.COMPONENT}/dynamodb"
//  type  = "String"
//  value = "${var.APP}-${var.COMPONENT}-dynamodb-store"
//}

module "secret" {

  source                = "../secret"

  NAME                  = "${var.APP}-${var.COMPONENT}-dynamodb"
  VALUE                 = "${var.APP}-${var.COMPONENT}-dynamodb-store"
  AWS_BACKUP_REGION     = var.AWS_SECONDARY_REGION
}
