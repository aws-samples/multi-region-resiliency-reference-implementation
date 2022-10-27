// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_kms_key" "primary-key" {

  provider            = aws.primary-provider
  enable_key_rotation = true

  description = "recon-dynamodb-primary-kms-key"
  tags        = {
    Name = "recon-dynamodb-primary-kms-key"
  }
}

resource "aws_kms_alias" "primary-key-alias" {

  provider = aws.primary-provider

  name          = "alias/recon-dynamodb-primary-kms-key"
  target_key_id = aws_kms_key.primary-key.key_id
}

module "primary-key-secret" {

  source                = "../../../modules/secret"

  NAME                  = "recon-dynamodb-primary-kms-key"
  VALUE                 = aws_kms_key.primary-key.arn
  AWS_BACKUP_REGION     = var.AWS_SECONDARY_REGION
  depends_on = [
    aws_kms_key.sm-primary-key, aws_kms_key.sm-secondary-key, aws_kms_alias.primary-key-alias, aws_kms_alias.secondary-key-alias
  ]
}

resource "aws_kms_key" "secondary-key" {

  provider            = aws.secondary-provider
  enable_key_rotation = true

  description = "recon-dynamodb-secondary-kms-key"
  tags        = {
    Name = "recon-dynamodb-secondary-kms-key"
  }
}

resource "aws_kms_alias" "secondary-key-alias" {

  provider = aws.secondary-provider

  name          = "alias/recon-dynamodb-secondary-kms-key"
  target_key_id = aws_kms_key.secondary-key.key_id
}

module "secondary-key-secret" {

  source                = "../../../modules/secret"

  NAME                  = "recon-dynamodb-secondary-kms-key"
  VALUE                 = aws_kms_key.secondary-key.arn
  AWS_BACKUP_REGION     = var.AWS_SECONDARY_REGION
  depends_on = [
    aws_kms_key.sm-primary-key, aws_kms_key.sm-secondary-key, aws_kms_alias.primary-key-alias, aws_kms_alias.secondary-key-alias
  ]
}

module "dynamodb-recon-audit" {

  source                = "../../../modules/dynamodb"

  APP                   = "recon"
  COMPONENT             = "audit"
  ENV                   = "dev"
  AWS_PRIMARY_REGION    = var.AWS_PRIMARY_REGION
  AWS_SECONDARY_REGION  = var.AWS_SECONDARY_REGION

  depends_on = [aws_kms_key.primary-key, aws_kms_alias.primary-key-alias, aws_kms_key.secondary-key, aws_kms_alias.secondary-key-alias, module.primary-key-secret, module.secondary-key-secret]
}



