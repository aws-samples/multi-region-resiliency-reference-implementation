// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

locals {
  s3_origin_id = "s3-www.${var.BUCKET_NAME}"
}

# Origin Access Control (successor to origin access identities): CloudFront
# signs origin requests with SigV4, which allows SSE-KMS encrypted objects
# and lets the bucket policy pin access to this exact distribution.
resource "aws_cloudfront_origin_access_control" "dashboard" {
  name                              = "dashboard-${var.ENV}"
  description                       = "Dashboard website bucket access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Customer managed key for the website bucket. The key policy grants
# cloudfront.amazonaws.com decrypt access only when the request originates
# from this distribution (defined after the distribution to avoid a cycle:
# the distribution does not reference the key).
resource "aws_kms_key" "bucket_key" {
  description         = "dashboard-website-bucket-key"
  enable_key_rotation = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableIAMUserPermissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = ["kms:Decrypt", "kms:Encrypt", "kms:GenerateDataKey*"]
        Resource  = "*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.www_s3_distribution.arn
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "bucket_key_alias" {
  name          = "alias/dashboard-website-bucket-key"
  target_key_id = aws_kms_key.bucket_key.key_id
}

resource "aws_cloudfront_distribution" "www_s3_distribution" {

  origin {
    domain_name              = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.dashboard.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  web_acl_id = aws_wafv2_web_acl.waf_acl.arn

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  #checkov:skip=CKV_AWS_86: "Ensure Cloudfront distribution has Access Logging enabled"
  #checkov:skip=CKV_AWS_174: "Verify CloudFront Distribution Viewer Certificate is using TLS v1.2"
  #checkov:skip=CKV2_AWS_32: "Ensure CloudFront distribution has a strict security headers policy attached"
}
