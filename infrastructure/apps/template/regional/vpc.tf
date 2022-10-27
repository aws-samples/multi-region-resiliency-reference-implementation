// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "approtation-vpc" {

  source            = "../../../modules/vpc"

  APP                   = var.APP
  ENV                   = var.ENV
  AWS_REGION            = var.AWS_REGION
  AWS_BACKUP_REGION     = var.AWS_BACKUP_REGION
  CIDR                  = var.CIDR
  PRIVATE_SUBNETS       = var.PRIVATE_SUBNETS
  PUBLIC_SUBNETS        = var.PUBLIC_SUBNETS
}

module "vpc-public-subnet-1-id-secret" {

  source                = "../../../modules/secret"

  NAME                  = "${var.APP}-${var.AWS_REGION}-public-subnet-1"
  VALUE                 = module.approtation-vpc.public_subnets[0]
  AWS_BACKUP_REGION     = var.AWS_BACKUP_REGION
}

module "vpc-public-subnet-2-id-secret" {

  source                = "../../../modules/secret"

  NAME                  = "${var.APP}-${var.AWS_REGION}-public-subnet-2"
  VALUE                 = module.approtation-vpc.public_subnets[1]
  AWS_BACKUP_REGION     = var.AWS_BACKUP_REGION
}

module "vpc-public-subnet-3-id-secret" {

  source                = "../../../modules/secret"

  NAME                  = "${var.APP}-${var.AWS_REGION}-public-subnet-3"
  VALUE                 = module.approtation-vpc.public_subnets[2]
  AWS_BACKUP_REGION     = var.AWS_BACKUP_REGION
}

module "vpc-private-subnet-1-id-secret" {

  source                = "../../../modules/secret"

  NAME                  = "${var.APP}-${var.AWS_REGION}-private-subnet-1"
  VALUE                 = module.approtation-vpc.private_subnets[0]
  AWS_BACKUP_REGION     = var.AWS_BACKUP_REGION
}

module "vpc-private-subnet-2-id-secret" {

  source                = "../../../modules/secret"

  NAME                  = "${var.APP}-${var.AWS_REGION}-private-subnet-2"
  VALUE                 = module.approtation-vpc.private_subnets[1]
  AWS_BACKUP_REGION     = var.AWS_BACKUP_REGION
}

module "vpc-private-subnet-3-id-secret" {

  source                = "../../../modules/secret"

  NAME                  = "${var.APP}-${var.AWS_REGION}-private-subnet-3"
  VALUE                 = module.approtation-vpc.private_subnets[2]
  AWS_BACKUP_REGION     = var.AWS_BACKUP_REGION
}

data "aws_route_table" "public-subnet-1-route-table" {

  subnet_id = module.approtation-vpc.public_subnets[0]
}

data "aws_route_table" "private-subnet-1-route-table" {

  subnet_id = module.approtation-vpc.private_subnets[0]
}

data "aws_route_table" "private-subnet-2-route-table" {

  subnet_id = module.approtation-vpc.private_subnets[1]
}

data "aws_route_table" "private-subnet-3-route-table" {

  subnet_id = module.approtation-vpc.private_subnets[2]
}

module "vpc-public-subnet-1-route-table-id-secret" {

  source                = "../../../modules/secret"

  NAME                  = "${var.APP}-${var.AWS_REGION}-public-subnet-1-route-table-id"
  VALUE                 = data.aws_route_table.public-subnet-1-route-table.id
  AWS_BACKUP_REGION     = var.AWS_BACKUP_REGION
}

module "vpc-private-subnet-1-route-table-id-secret" {

  source                = "../../../modules/secret"

  NAME                  = "${var.APP}-${var.AWS_REGION}-private-subnet-1-route-table-id"
  VALUE                 = data.aws_route_table.private-subnet-1-route-table.id
  AWS_BACKUP_REGION     = var.AWS_BACKUP_REGION
}

module "vpc-private-subnet-2-route-table-id-secret" {

  source                = "../../../modules/secret"

  NAME                  = "${var.APP}-${var.AWS_REGION}-private-subnet-2-route-table-id"
  VALUE                 = data.aws_route_table.private-subnet-2-route-table.id
  AWS_BACKUP_REGION     = var.AWS_BACKUP_REGION
}

module "vpc-private-subnet-3-route-table-id-secret" {

  source                = "../../../modules/secret"

  NAME                  = "${var.APP}-${var.AWS_REGION}-private-subnet-3-route-table-id"
  VALUE                 = data.aws_route_table.private-subnet-3-route-table.id
  AWS_BACKUP_REGION     = var.AWS_BACKUP_REGION
}
