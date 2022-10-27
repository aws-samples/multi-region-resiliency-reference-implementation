// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_db_subnet_group" "default" {

  name       = "${var.APP}-${var.AWS_REGION}-db-subnet-group"
  subnet_ids = module.approtation-vpc.private_subnets

  tags = {
    Name = "${var.APP}-${var.AWS_REGION}-db-subnet-group"
  }
}
