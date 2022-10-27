// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_kms_key" "sm-primary-key" {

  provider            = aws.primary-provider
  enable_key_rotation = true

  description = "secret-manager-secret-key"
  tags        = {
    Name = "secret-manager-secret-key"
  }
}

resource "aws_kms_alias" "sm-primary-key-alias" {

  provider = aws.primary-provider

  name          = "alias/secret-manager-secret-key"
  target_key_id = aws_kms_key.sm-primary-key.key_id
}

resource "aws_kms_key" "sm-secondary-key" {

  provider            = aws.secondary-provider
  enable_key_rotation = true

  description = "secret-manager-secret-key"
  tags        = {
    Name = "secret-manager-secret-key"
  }
}

resource "aws_kms_alias" "sm-secondary-key-alias" {

  provider = aws.secondary-provider

  name          = "alias/secret-manager-secret-key"
  target_key_id = aws_kms_key.sm-secondary-key.key_id
}




resource "aws_kms_key" "ps-primary-key" {

  provider            = aws.primary-provider
  enable_key_rotation = true

  description = "parameter-store-secret-key"
  tags        = {
    Name = "parameter-store-secret-key"
  }
}

resource "aws_kms_alias" "ps-primary-key-alias" {

  provider = aws.primary-provider

  name          = "alias/parameter-store-secret-key"
  target_key_id = aws_kms_key.ps-primary-key.key_id
}

resource "aws_kms_key" "ps-secondary-key" {

  provider            = aws.secondary-provider
  enable_key_rotation = true

  description = "parameter-store-secret-key"
  tags        = {
    Name = "parameter-store-secret-key"
  }
}

resource "aws_kms_alias" "ps-secondary-key-alias" {

  provider = aws.secondary-provider

  name          = "alias/parameter-store-secret-key"
  target_key_id = aws_kms_key.ps-secondary-key.key_id
}




