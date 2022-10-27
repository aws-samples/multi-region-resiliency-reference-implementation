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

resource "test_assertions" "test_broker_instances" {

  component = "test_broker_instances"

  equal "broker_instances_count" {
    description = "Verify number of broker instances"
    got         = length(local.broker_instances)
    want        = 3
  }
}

