// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

locals {
  s3_origin_id = "s3-www.${var.BUCKET_NAME}"
}

resource "aws_cloudfront_origin_access_identity" "dashboard" {
  comment = "Dashboard"
}

resource "aws_cloudfront_distribution" "www_s3_distribution" {

  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.dashboard.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

//  custom_error_response {
//    error_caching_min_ttl = 0
//    error_code            = 404
//    response_code         = 200
//    response_page_path    = "/404.html"
//  }

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

    viewer_protocol_policy = "allow-all"
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

  #checkov:skip=CKV_AWS_34: "Ensure cloudfront distribution ViewerProtocolPolicy is set to HTTPS"
  #checkov:skip=CKV_AWS_86: "Ensure Cloudfront distribution has Access Logging enabled"
  #checkov:skip=CKV_AWS_174: "Verify CloudFront Distribution Viewer Certificate is using TLS v1.2"
  #checkov:skip=CKV2_AWS_32: "Ensure CloudFront distribution has a strict security headers policy attached"
}