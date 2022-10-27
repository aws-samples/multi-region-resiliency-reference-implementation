// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_kms_key" "key" {

  description = var.DESCRIPTION
  enable_key_rotation = true

  tags = {
    Name = var.NAME
  }
}

resource "aws_kms_alias" "key_alias" {

  name          = "alias/${var.NAME}"
  target_key_id = aws_kms_key.key.key_id
}