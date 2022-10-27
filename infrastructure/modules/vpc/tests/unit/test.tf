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

resource "test_assertions" "test_vpc" {

  component = "test_vpc"

  equal "vpc_name" {
    description = "Verify number of subnets"
    got         = local.vpc_name
    want        = "test-vpc-dev"
  }
}

resource "test_assertions" "test_public_subnets" {

  component = "test_public_subnets"

  equal "subnet_count" {
    description = "Verify number of subnets"
    got         = length(local.public_subnets)
    want        = 3
  }

  equal "subnet_cidr_block_0" {
    description = "Verify subnet cidr block 1"
    got         = local.public_subnet_cidr_blocks[0]
    want        = "10.10.101.0/24"
  }

  equal "subnet_cidr_block_1" {
    description = "Verify subnet cidr block 1"
    got         = local.public_subnet_cidr_blocks[1]
    want        = "10.10.102.0/24"
  }

    equal "subnet_cidr_block_2" {
    description = "Verify subnet cidr block 1"
    got         = local.public_subnet_cidr_blocks[2]
    want        = "10.10.103.0/24"
  }
}

resource "test_assertions" "test_private_subnets" {

  component = "test_private_subnets"

  equal "subnet_count" {
    description = "Verify number of subnets"
    got         = length(local.public_subnets)
    want        = 3
  }

  equal "subnet_cidr_block_0" {
    description = "Verify subnet cidr block 1"
    got         = local.private_subnet_cidr_blocks[0]
    want        = "10.10.1.0/24"
  }

  equal "subnet_cidr_block_1" {
    description = "Verify subnet cidr block 1"
    got         = local.private_subnet_cidr_blocks[1]
    want        = "10.10.2.0/24"
  }

    equal "subnet_cidr_block_2" {
    description = "Verify subnet cidr block 1"
    got         = local.private_subnet_cidr_blocks[2]
    want        = "10.10.3.0/24"
  }
}