// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "aws_region" {

  description = "AWS region for all resources."

  type    = string
  default = "us-east-1"
}

variable "ENV" {

  description = "The environment"

  type    = string
  default = "awsd1"
}

variable "RUNBOOK_REGIONS" {

  description = "Regions where the application rotation runbooks are deployed."

  type    = list(string)
  default = ["us-east-1", "us-west-2"]
}

variable "ALLOWED_IP_CIDRS" {

  description = "IPv4 CIDRs allowed to call the dashboard API through the WAF (e.g. [\"203.0.113.10/32\"]). Empty list blocks all IPv4 access."

  type    = list(string)
  default = []
}

variable "ALLOWED_IPV6_CIDRS" {

  description = "IPv6 CIDRs allowed to call the dashboard API through the WAF (e.g. [\"2001:db8:1234:5678::/64\"]). Empty list blocks all IPv6 access."

  type    = list(string)
  default = []
}