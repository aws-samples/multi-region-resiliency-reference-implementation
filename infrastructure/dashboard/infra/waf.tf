// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_wafv2_ip_set" "ip_whitelist" {

  name               = "ip-whitelist"
  description        = "ip-whitelist"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.ALLOWED_IP_CIDRS
}

resource "aws_wafv2_ip_set" "ip_whitelist_ipv6" {

  name               = "ip-whitelist-ipv6"
  description        = "ip-whitelist-ipv6"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV6"
  addresses          = var.ALLOWED_IPV6_CIDRS
}

resource "aws_wafv2_web_acl" "waf_acl" {

  name        = "dashboard"
  description = "dashboard"
  scope       = "CLOUDFRONT"

  default_action {
    block {}
  }

  rule {
    name     = "rule-1"
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.ip_whitelist.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "AllowlistIPs"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "rule-2"
    priority = 2

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.ip_whitelist_ipv6.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "AllowlistIPsV6"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "Blocked"
    sampled_requests_enabled   = false
  }

  #checkov:skip=CKV2_AWS_31: "Ensure WAF2 has a Logging Configuration"
  #checkov:skip=CKV_AWS_192: "Ensure WAF prevents message lookup in Log4j2. See CVE-2021-44228 aka log4jshell"

}
