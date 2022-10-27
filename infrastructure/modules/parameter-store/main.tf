// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

data "aws_kms_key" "parameter-store-secret-key" {

  key_id = "alias/parameter-store-secret-key"
}

resource "aws_ssm_parameter" "parameter" {

  name  = var.NAME
  type  = "SecureString"
  value = var.VALUE

  key_id = data.aws_kms_key.parameter-store-secret-key.key_id
}