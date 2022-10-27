// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "approtation-vpc" {

  source = "terraform-aws-modules/vpc/aws"

  name = "${var.APP}-${var.AWS_REGION}-vpc"
  cidr = var.CIDR

  azs             = ["${var.AWS_REGION}a", "${var.AWS_REGION}b", "${var.AWS_REGION}c"]
  private_subnets = var.PRIVATE_SUBNETS
  public_subnets  = var.PUBLIC_SUBNETS

  create_igw = true
  enable_nat_gateway = true

  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = {
    Terraform   = "true"
    Environment = var.ENV
  }
}

module "secret" {
  source                = "../secret"

  NAME                  = "${var.APP}-${var.AWS_REGION}-vpc"
  VALUE                 = module.approtation-vpc.vpc_id
  AWS_BACKUP_REGION     = var.AWS_BACKUP_REGION
}



