// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_s3_bucket" "s3_bucket" {

  bucket = "${var.APP}-${var.LOCATION}-${var.ENV}-terraform-store"

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
    Name = "${var.APP}-${var.LOCATION}-${var.ENV}-terraform-store"
  }

  #checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
  #checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"
}

resource "aws_s3_bucket_public_access_block" "public_access_block_source" {

  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "dynamodb_terraform_state_lock" {

  name = "${var.APP}-${var.LOCATION}-${var.ENV}-terraform-store-lock"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name = "${var.APP}-${var.LOCATION}-${var.ENV}-terraform-store-lock"
  }

  #checkov:skip=CKV2_AWS_16: "Ensure that Auto Scaling is enabled on your DynamoDB tables"
  #checkov:skip=CKV_AWS_119: "Ensure DynamoDB Tables are encrypted using a KMS Customer Managed CMK"
}

//provider "aws" {
//  alias  = "backup"
//  region = var.AWS_BACKUP_REGION
//}
//
//resource "aws_iam_role" "replication" {
//
//  name = "team-${var.APP}-${var.LOCATION}-${var.ENV}-replication-role"
//  permissions_boundary = "arn:aws:iam::aws:policy/PowerUserAccess"
//
//  assume_role_policy = <<POLICY
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Action": "sts:AssumeRole",
//      "Principal": {
//        "Service": "s3.amazonaws.com"
//      },
//      "Effect": "Allow",
//      "Sid": ""
//    }
//  ]
//}
//POLICY
//}
//
//resource "aws_iam_policy" "replication" {
//  name = "${var.APP}-${var.LOCATION}-${var.ENV}-replication-policy"
//
//  policy = <<POLICY
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Action": [
//        "s3:GetReplicationConfiguration",
//        "s3:ListBucket"
//      ],
//      "Effect": "Allow",
//      "Resource": [
//        "${aws_s3_bucket.s3_bucket.arn}"
//      ]
//    },
//    {
//      "Action": [
//        "s3:GetObjectVersionForReplication",
//        "s3:GetObjectVersionAcl",
//         "s3:GetObjectVersionTagging"
//      ],
//      "Effect": "Allow",
//      "Resource": [
//        "${aws_s3_bucket.s3_bucket.arn}/*"
//      ]
//    },
//    {
//      "Action": [
//        "s3:ReplicateObject",
//        "s3:ReplicateDelete",
//        "s3:ReplicateTags"
//      ],
//      "Effect": "Allow",
//      "Resource": "${aws_s3_bucket.destination.arn}/*"
//    }
//  ]
//}
//POLICY
//}
//
//resource "aws_iam_role_policy_attachment" "replication" {
//  role       = aws_iam_role.replication.name
//  policy_arn = aws_iam_policy.replication.arn
//}
//
//resource "aws_s3_bucket" "destination" {
//
//  provider = aws.backup
//
//  bucket = "${var.APP}-${var.LOCATION}-${var.ENV}-terraform-store-replication"
//
//  versioning {
//    enabled = true
//  }
//
//  server_side_encryption_configuration {
//    rule {
//      apply_server_side_encryption_by_default {
//        kms_master_key_id = var.KEY_ARN
//        sse_algorithm     = "aws:kms"
//      }
//    }
//  }
//
//  #checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
//  #checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"
//}
//
//resource "aws_s3_bucket_public_access_block" "public_access_block_destination" {
//
//  provider = aws.backup
//
//  bucket = aws_s3_bucket.destination.arn
//
//  block_public_acls       = true
//  block_public_policy     = true
//  ignore_public_acls      = true
//  restrict_public_buckets = true
//}
//
//resource "aws_s3_bucket_replication_configuration" "replication" {
//
//  role   = aws_iam_role.replication.arn
//  bucket = aws_s3_bucket.s3_bucket.id
//
//  rule {
//    id = "foobar"
//
//    filter {
//      prefix = "foo"
//    }
//
//    status = "Enabled"
//
//    destination {
//      bucket        = aws_s3_bucket.destination.arn
//      storage_class = "STANDARD"
//    }
//  }
//}