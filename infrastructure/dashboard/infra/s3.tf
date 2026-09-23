// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_s3_bucket" "bucket" {

  bucket = "${var.BUCKET_NAME}-${var.ENV}"

  force_destroy = true

  #checkov:skip=CKV_AWS_144:Ensure that S3 bucket has cross-region replication enabled
  #checkov:skip=CKV_AWS_18:Ensure the S3 bucket has access logging enabled
}

resource "aws_s3_bucket_versioning" "bucket" {

  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# SSE-KMS with a customer managed key: supported because the distribution
# reaches the bucket through an origin access control (SigV4), not a legacy
# origin access identity.
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {

  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.bucket_key.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {

  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket_policy_document.json
}

data "aws_caller_identity" "current" {}

# Only this account's CloudFront distribution may read the bucket
# (confused-deputy protection via AWS:SourceArn).
data "aws_iam_policy_document" "bucket_policy_document" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.www_s3_distribution.arn]
    }
  }
}

locals {
  mime_types = {
    "html"  = "text/html"
    "txt"   = "text/plain"
    "css"   = "text/css"
    "png"   = "image/png"
    "ico"   = "image/x-icon"
    "svg"   = "image/svg+xml"
    "js"    = "application/javascript"
    "json"  = "application/json"
    "map"   = "application/json"
  }
}

resource "aws_s3_object" "object" {

  for_each = fileset("../ui/build/", "**/*.*")
  bucket = aws_s3_bucket.bucket.id
  key = each.value
  source = "../ui/build/${each.value}"
  source_hash = filemd5("../ui/build/${each.value}")
  server_side_encryption = "aws:kms"
  kms_key_id             = aws_kms_key.bucket_key.arn
  content_type  =    lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
}
