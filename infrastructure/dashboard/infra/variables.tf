// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "AWS_REGION" {

  type    = string
  default = "us-east-1"
}

variable "BUCKET_NAME" {

  type    = string
  default = "app-rotation-dashboard-portal"
}

variable "ENV" {

  type    = string
  default = "awsd1"
}
variable "ALLOWED_IP_CIDRS" {

  description = "IPv4 CIDRs allowed to reach the dashboard through the WAF (e.g. [\"203.0.113.10/32\"]). Empty list blocks all access."

  type    = list(string)
  default = []
}

variable "ALLOWED_IPV6_CIDRS" {

  description = "IPv6 CIDRs allowed to reach the dashboard through the WAF (e.g. [\"2001:db8:1234:5678::/64\"]). Empty list blocks all IPv6 access."

  type    = list(string)
  default = []
}
