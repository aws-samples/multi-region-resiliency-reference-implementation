// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }

    http = {
      source = "hashicorp/http"
    }
  }
}

resource "test_assertions" "test_cluster_instances" {

  component = "test_cluster_instances"

  check "cluster_arn" {
    description = "Verify valid cluster arn"
    condition   = (local.cluster_arn != "")
  }
}

