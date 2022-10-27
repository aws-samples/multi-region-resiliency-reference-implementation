// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_kms_key" "primary-key" {

  provider = aws.primary

  description         = "${var.APP}-dynamodb-primary-kms-key"
  enable_key_rotation = true

  tags        = {
    Name = "${var.APP}-dynamodb-primary-kms-key"
  }
}

resource "aws_kms_alias" "primary-key-alias" {

  provider = aws.primary
  name          = "alias/${var.APP}-dynamodb-primary-kms-key"
  target_key_id = aws_kms_key.primary-key.key_id
}

module "primary-key-secret" {

  source                = "../../../modules/secret"

  NAME                  = "${var.APP}-dynamodb-primary-kms-key"
  VALUE                 = aws_kms_key.primary-key.arn
  AWS_BACKUP_REGION     = var.AWS_SECONDARY_REGION
}

resource "aws_kms_key" "secondary-key" {

  provider = aws.secondary

  description         = "${var.APP}-dynamodb-secondary-kms-key"
  enable_key_rotation = true

  tags        = {
    Name = "${var.APP}-dynamodb-secondary-kms-key"
  }
}

resource "aws_kms_alias" "secondary-key-alias" {

  provider = aws.secondary
  name          = "alias/${var.APP}-dynamodb-secondary-kms-key"
  target_key_id = aws_kms_key.secondary-key.key_id
}

module "secondary-key-secret" {

  source                = "../../../modules/secret"

  NAME                  = "${var.APP}-dynamodb-secondary-kms-key"
  VALUE                 = aws_kms_key.secondary-key.arn
  AWS_BACKUP_REGION     = var.AWS_SECONDARY_REGION
}
