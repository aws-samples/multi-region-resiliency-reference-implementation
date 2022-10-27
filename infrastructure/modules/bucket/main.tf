// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

provider "aws" {

  alias = "primary"
  region = var.AWS_PRIMARY_REGION

  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

provider "aws" {

  alias = "secondary"
  region = var.AWS_SECONDARY_REGION

  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

locals {
  bucket_name             = "${var.NAME}-${var.SUFFIX}"
  destination_bucket_name = "replica-${var.NAME}-${var.SUFFIX}"
  origin_region           = var.AWS_PRIMARY_REGION
  replica_region          = var.AWS_SECONDARY_REGION
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "key" {

  provider = aws.primary

  description             = "S3 bucket KMS key"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_key" "replica-key" {

  provider = aws.secondary

  enable_key_rotation     = true
  description             = "S3 bucket replication KMS key"
  deletion_window_in_days = 7
}

module "replica_bucket" {


  providers = {
    aws = aws.secondary
  }

  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.destination_bucket_name
  acl    = "private"

  versioning = {
    enabled = true
  }
}

module "s3_bucket" {

  providers = {
    aws = aws.primary
  }

  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.bucket_name
  acl    = "private"

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    kms_master_key_id = aws_kms_key.key.arn
    sse_algorithm     = "aws:kms"
  }

//  replication_configuration = {
//    role = aws_iam_role.replication.arn
//
//    rules = [
//      {
//        id       = "something-with-kms-and-filter"
//        status   = "Enabled"
//        priority = 10
//
//        source_selection_criteria = {
//          sse_kms_encrypted_objects = {
//            enabled = true
//          }
//        }
//
//        filter = {
//          prefix = "one"
//          tags = {
//            ReplicateMe = "Yes"
//          }
//        }
//
//        destination = {
//          bucket             = "arn:aws:s3:::${local.destination_bucket_name}"
//          storage_class      = "STANDARD"
//          replica_kms_key_id = aws_kms_key.replica-key.arn
//          account_id         = data.aws_caller_identity.current.account_id
//          access_control_translation = {
//            owner = "Destination"
//          }
//          replication_time = {
//            status  = "Enabled"
//            minutes = 15
//          }
//          metrics = {
//            status  = "Enabled"
//            minutes = 15
//          }
//        }
//      },
//      {
//        id       = "something-with-filter"
//        status   = "Enabled"
//        priority = 20
//
//        filter = {
//          prefix = "two"
//          tags = {
//            ReplicateMe = "Yes"
//          }
//        }
//
//        destination = {
//          bucket        = "arn:aws:s3:::${local.destination_bucket_name}"
//          storage_class = "STANDARD"
//        }
//      },
//      {
//        id       = "everything-with-filter"
//        status   = "Enabled"
//        priority = 30
//
//        filter = {
//          prefix = ""
//        }
//
//        destination = {
//          bucket        = "arn:aws:s3:::${local.destination_bucket_name}"
//          storage_class = "STANDARD"
//        }
//      },
//      {
//        id     = "everything-without-filters"
//        status = "Enabled"
//
//        destination = {
//          bucket        = "arn:aws:s3:::${local.destination_bucket_name}"
//          storage_class = "STANDARD"
//        }
//      },
//    ]
//  }
}
