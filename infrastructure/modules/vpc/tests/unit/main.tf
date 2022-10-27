// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

provider "aws" {
  region = "us-east-1"
}

module "main" {
  source = "../.."
  APP               = "test"
  ENV               = "dev"
  AWS_REGION        = "us-east-1"
  CIDR              = "10.10.0.0/16"
  PRIVATE_SUBNETS   = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  PUBLIC_SUBNETS    = ["10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24"]
}

locals {
  vpc_name = module.main.name
  public_subnets = module.main.public_subnets
  public_subnet_cidr_blocks = module.main.public_subnets_cidr_blocks
  private_subnets = module.main.private_subnets
  private_subnet_cidr_blocks = module.main.private_subnets_cidr_blocks
}