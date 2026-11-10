// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_wafv2_ip_set" "api_allowed_ipv4" {

  name               = "dashboard-api-allowed-ipv4"
  description        = "IPv4 CIDRs allowed to call the dashboard API"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.ALLOWED_IP_CIDRS
}

resource "aws_wafv2_ip_set" "api_allowed_ipv6" {

  name               = "dashboard-api-allowed-ipv6"
  description        = "IPv6 CIDRs allowed to call the dashboard API"
  scope              = "REGIONAL"
  ip_address_version = "IPV6"
  addresses          = var.ALLOWED_IPV6_CIDRS
}

resource "aws_wafv2_web_acl" "api" {

  name        = "dashboard-api"
  description = "dashboard-api"
  scope       = "REGIONAL"

  default_action {
    block {}
  }

  rule {
    name     = "rate-limit"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 900
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "DashboardApiRateLimit"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "allow-ipv4"
    priority = 2

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.api_allowed_ipv4.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "DashboardApiAllowIpv4"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "allow-ipv6"
    priority = 3

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.api_allowed_ipv6.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "DashboardApiAllowIpv6"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "DashboardApiBlocked"
    sampled_requests_enabled   = true
  }
}
