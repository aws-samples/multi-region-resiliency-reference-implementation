// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "random_string" "suffix" {

  length           = 8
  upper            = false
  lower            = true
  number           = false
  special          = false
  override_special = ""
}

resource "aws_s3_bucket" "s3-bucket" {

//  bucket = "approtation-${var.APP}-${var.LOCATION}-terraform-store"
  bucket = "approtation-${var.APP}-${var.LOCATION}-terraform-store-${random_string.suffix.result}"

  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.KEY_ARN
        sse_algorithm     = "aws:kms"
      }
    }
  }
  tags = {
    Name = "approtation-${var.APP}-${var.LOCATION}-terraform-store"
  }

  #checkov:skip=CKV_AWS_144:Ensure that S3 bucket has cross-region replication enabled
  #checkov:skip=CKV_AWS_18:Ensure the S3 bucket has access logging enabled
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {

  bucket = aws_s3_bucket.s3-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock-devops4solutions" {

  name = "approtation-${var.APP}-${var.LOCATION}-terraform-store-lock"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "approtation-${var.APP}-${var.LOCATION}-terraform-store-lock"
  }

  point_in_time_recovery {
    enabled = true
  }

  #checkov:skip=CKV2_AWS_16:Ensure that Auto Scaling is enabled on your DynamoDB tables
  #checkov:skip=CKV_AWS_119:Ensure DynamoDB Tables are encrypted using a KMS Customer Managed CMK
}

