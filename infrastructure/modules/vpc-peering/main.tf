// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

provider "aws" {

  alias = "primary"
  region = var.REGION1
}

provider "aws" {

  alias  = "secondary"
  region = var.REGION2
}

data "aws_secretsmanager_secret" "app1-region1-vpc-secret" {

  provider = aws.primary
  name = "${var.APP1}-${var.REGION1}-vpc"
}

data "aws_secretsmanager_secret_version" "app1-region1-vpc-secret-version" {

  provider = aws.primary
  secret_id = data.aws_secretsmanager_secret.app1-region1-vpc-secret.id
}

data "aws_secretsmanager_secret" "app1-region1-public-subnet-1-route-table-id-secret" {

  provider = aws.primary
  name = "${var.APP1}-${var.REGION1}-public-subnet-1-route-table-id"
}

data "aws_secretsmanager_secret_version" "app1-region1-public-subnet-1-route-table-id-secret-version" {

  provider = aws.primary
  secret_id = data.aws_secretsmanager_secret.app1-region1-public-subnet-1-route-table-id-secret.id
}

data "aws_secretsmanager_secret" "app1-region1-private-subnet-1-route-table-id-secret" {

  provider = aws.primary
  name = "${var.APP1}-${var.REGION1}-private-subnet-1-route-table-id"
}

data "aws_secretsmanager_secret_version" "app1-region1-private-subnet-1-route-table-id-secret-version" {

  provider = aws.primary
  secret_id = data.aws_secretsmanager_secret.app1-region1-private-subnet-1-route-table-id-secret.id
}

data "aws_secretsmanager_secret" "app1-region1-private-subnet-2-route-table-id-secret" {

  provider = aws.primary
  name = "${var.APP1}-${var.REGION1}-private-subnet-2-route-table-id"
}

data "aws_secretsmanager_secret_version" "app1-region1-private-subnet-2-route-table-id-secret-version" {

  provider = aws.primary
  secret_id = data.aws_secretsmanager_secret.app1-region1-private-subnet-2-route-table-id-secret.id
}

data "aws_secretsmanager_secret" "app1-region1-private-subnet-3-route-table-id-secret" {

  provider = aws.primary
  name = "${var.APP1}-${var.REGION1}-private-subnet-3-route-table-id"
}

data "aws_secretsmanager_secret_version" "app1-region1-private-subnet-3-route-table-id-secret-version" {

  provider = aws.primary
  secret_id = data.aws_secretsmanager_secret.app1-region1-private-subnet-3-route-table-id-secret.id
}

data "aws_secretsmanager_secret" "app2-region2-vpc-secret" {

  provider = aws.secondary
  name = "${var.APP2}-${var.REGION2}-vpc"
}

data "aws_secretsmanager_secret_version" "app2-region2-vpc-secret-version" {

  provider = aws.secondary
  secret_id = data.aws_secretsmanager_secret.app2-region2-vpc-secret.id
}

data "aws_secretsmanager_secret" "app2-region2-public-subnet-1-route-table-id-secret" {

  provider = aws.secondary
  name = "${var.APP2}-${var.REGION2}-public-subnet-1-route-table-id"
}

data "aws_secretsmanager_secret_version" "app2-region2-public-subnet-1-route-table-id-secret-version" {

  provider = aws.secondary
  secret_id = data.aws_secretsmanager_secret.app2-region2-public-subnet-1-route-table-id-secret.id
}

data "aws_secretsmanager_secret" "app2-region2-private-subnet-1-route-table-id-secret" {

  provider = aws.secondary
  name = "${var.APP2}-${var.REGION2}-private-subnet-1-route-table-id"
}

data "aws_secretsmanager_secret_version" "app2-region2-private-subnet-1-route-table-id-secret-version" {

  provider = aws.secondary
  secret_id = data.aws_secretsmanager_secret.app2-region2-private-subnet-1-route-table-id-secret.id
}

data "aws_secretsmanager_secret" "app2-region2-private-subnet-2-route-table-id-secret" {

  provider = aws.secondary
  name = "${var.APP2}-${var.REGION2}-private-subnet-2-route-table-id"
}

data "aws_secretsmanager_secret_version" "app2-region2-private-subnet-2-route-table-id-secret-version" {

  provider = aws.secondary
  secret_id = data.aws_secretsmanager_secret.app2-region2-private-subnet-2-route-table-id-secret.id
}

data "aws_secretsmanager_secret" "app2-region2-private-subnet-3-route-table-id-secret" {

  provider = aws.secondary
  name = "${var.APP2}-${var.REGION2}-private-subnet-3-route-table-id"
}

data "aws_secretsmanager_secret_version" "app2-region2-private-subnet-3-route-table-id-secret-version" {

  provider = aws.secondary
  secret_id = data.aws_secretsmanager_secret.app2-region2-private-subnet-3-route-table-id-secret.id
}

resource "aws_vpc_peering_connection" "peering-connection" {

  provider = aws.primary

  peer_region   = var.REGION2
  vpc_id        = data.aws_secretsmanager_secret_version.app1-region1-vpc-secret-version.secret_string
  peer_vpc_id   = data.aws_secretsmanager_secret_version.app2-region2-vpc-secret-version.secret_string
  auto_accept   = false

  tags = {
    Name = "${var.APP1}-${var.REGION1}-to-${var.APP2}-${var.REGION2}"
  }
}

resource "aws_vpc_peering_connection_accepter" "connection-acceptor" {

  provider                  = aws.secondary

  vpc_peering_connection_id = aws_vpc_peering_connection.peering-connection.id
  auto_accept               = true

  tags = {
    Name = "${var.APP1}-${var.REGION1}-to-${var.APP2}-${var.REGION2}"
  }
}

resource "aws_vpc_peering_connection_options" "requester-options" {

  provider = aws.primary

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.connection-acceptor.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_vpc_peering_connection_options" "acceptor-options" {

  provider = aws.secondary

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.connection-acceptor.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}

data "aws_vpc" "app1-region1-vpc" {

  provider = aws.primary
  id = data.aws_secretsmanager_secret_version.app1-region1-vpc-secret-version.secret_string
}

data "aws_vpc" "app2-region2-vpc" {

  provider = aws.secondary
  id = data.aws_secretsmanager_secret_version.app2-region2-vpc-secret-version.secret_string
}

resource "aws_route" "app1-public-subnet-route" {

  provider = aws.primary
  route_table_id            = data.aws_secretsmanager_secret_version.app1-region1-public-subnet-1-route-table-id-secret-version.secret_string
  destination_cidr_block    = data.aws_vpc.app2-region2-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering-connection.id
}

resource "aws_route" "app1-private-subnet-1-route" {

  provider = aws.primary
  route_table_id            = data.aws_secretsmanager_secret_version.app1-region1-private-subnet-1-route-table-id-secret-version.secret_string
  destination_cidr_block    = data.aws_vpc.app2-region2-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering-connection.id
}

resource "aws_route" "app1-private-subnet-2-route" {

  provider = aws.primary
  route_table_id            = data.aws_secretsmanager_secret_version.app1-region1-private-subnet-2-route-table-id-secret-version.secret_string
  destination_cidr_block    = data.aws_vpc.app2-region2-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering-connection.id
}

resource "aws_route" "app1-private-subnet-3-route" {

  provider = aws.primary
  route_table_id            = data.aws_secretsmanager_secret_version.app1-region1-private-subnet-3-route-table-id-secret-version.secret_string
  destination_cidr_block    = data.aws_vpc.app2-region2-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering-connection.id
}

resource "aws_route" "app2-public-subnet-route" {

  provider = aws.secondary
  route_table_id            = data.aws_secretsmanager_secret_version.app2-region2-public-subnet-1-route-table-id-secret-version.secret_string
  destination_cidr_block    = data.aws_vpc.app1-region1-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering-connection.id
}

resource "aws_route" "app2-private-subnet-1-route" {

  provider = aws.secondary
  route_table_id            = data.aws_secretsmanager_secret_version.app2-region2-private-subnet-1-route-table-id-secret-version.secret_string
  destination_cidr_block    = data.aws_vpc.app1-region1-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering-connection.id
}

resource "aws_route" "app2-private-subnet-2-route" {

  provider = aws.secondary
  route_table_id            = data.aws_secretsmanager_secret_version.app2-region2-private-subnet-2-route-table-id-secret-version.secret_string
  destination_cidr_block    = data.aws_vpc.app1-region1-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering-connection.id
}

resource "aws_route" "app2-private-subnet-3-route" {

  provider = aws.secondary
  route_table_id            = data.aws_secretsmanager_secret_version.app2-region2-private-subnet-3-route-table-id-secret-version.secret_string
  destination_cidr_block    = data.aws_vpc.app1-region1-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering-connection.id
}
