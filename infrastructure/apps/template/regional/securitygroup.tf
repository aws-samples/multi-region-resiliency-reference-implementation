// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_security_group" "vpc-endpoint-sg" {

  name        = "${var.APP}-${var.AWS_REGION}-vpc-endpoint-sg"
  description = "${var.APP}-${var.AWS_REGION}-vpc-endpoint-sg"
  vpc_id      = module.approtation-vpc.vpc_id

  ingress {
    description      = "Connect endpoints from VPC resources"
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = [var.CIDR]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.APP}-${var.AWS_REGION}-vpc-endpoint-sg"
  }

  #checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource"
  #checkov:skip=CKV_AWS_23: "Ensure every security groups rule has a description"
}

resource "aws_security_group" "elb-sg" {

  name        = "${var.APP}-${var.AWS_REGION}-elb-sg"
  description = "${var.APP}-${var.AWS_REGION}-elb-sg"
  vpc_id      = module.approtation-vpc.vpc_id

  ingress {
    description       = "HTTP Port from VPC"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = [var.CIDR]
  }

  ingress {
    description       = "HTTP Port from AWS Corp"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    prefix_list_ids   = (var.AWS_REGION == "us-east-1")?["pl-4e2ece27"]:["pl-5aa44133"]
  }

  ingress {
    description       = "HTTPS Port from VPC"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = [var.CIDR]
  }

  ingress {
    description       = "HTTPS Port from AWS Corp"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    prefix_list_ids   = (var.AWS_REGION == "us-east-1")?["pl-4e2ece27"]:["pl-5aa44133"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.APP}-${var.AWS_REGION}-elb-sg"
  }

  #checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource"
  #checkov:skip=CKV_AWS_23: "Ensure every security groups rule has a description"
}

resource "aws_security_group" "ecs-sg" {

  name        = "${var.APP}-ecs-sg"
  description = "${var.APP}-ecs-sg"
  vpc_id      = module.approtation-vpc.vpc_id

  ingress {
    description       = "SSH Port from VPC"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = [var.CIDR]
  }

  ingress {
    description       = "SSH Port from AWS Corp"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    prefix_list_ids   = (var.AWS_REGION == "us-east-1")?["pl-4e2ece27"]:["pl-5aa44133"]
  }

  ingress {
    description       = "HTTP Port from VPC"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = [var.CIDR]
  }

  ingress {
    description       = "HTTP Port from AWS Corp"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    prefix_list_ids   = (var.AWS_REGION == "us-east-1")?["pl-4e2ece27"]:["pl-5aa44133"]
  }

  ingress {
    description       = "HTTPS Port from VPC"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = [var.CIDR]
  }

  ingress {
    description       = "HTTPS Port from AWS Corp"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    prefix_list_ids   = (var.AWS_REGION == "us-east-1")?["pl-4e2ece27"]:["pl-5aa44133"]
  }

  ingress {
    description       = "All ports from ELB"
    from_port         = 0
    to_port           = 65535
    protocol          = "tcp"
    security_groups   = [aws_security_group.elb-sg.id]
  }

  egress {
    description       = "Egress Ports"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.APP}-${var.AWS_REGION}-ecs-sg"
  }

  #checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource"
  #checkov:skip=CKV_AWS_23: "Ensure every security groups rule has a description"
}

resource "aws_security_group" "dashboard-lambda-sg" {

  name        = "${var.APP}-${var.AWS_REGION}-db-lambda-sg"
  description = "${var.APP}-${var.AWS_REGION}-db-lambda-sg"
  vpc_id      = module.approtation-vpc.vpc_id

  ingress {
    description       = "SSH Port from VPC"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = [var.CIDR]
  }

  ingress {
    description       = "SSH Port from AWS Corp"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    prefix_list_ids   = (var.AWS_REGION == "us-east-1")?["pl-4e2ece27"]:["pl-5aa44133"]
  }

  ingress {
    description       = "HTTP Port from VPC"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = [var.CIDR]
  }

  ingress {
    description       = "HTTP Port from AWS Corp"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    prefix_list_ids   = (var.AWS_REGION == "us-east-1")?["pl-4e2ece27"]:["pl-5aa44133"]
  }

  ingress {
    description       = "HTTPS Port from VPC"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = [var.CIDR]
  }

  ingress {
    description       = "HTTPS Port from AWS Corp"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    prefix_list_ids   = (var.AWS_REGION == "us-east-1")?["pl-4e2ece27"]:["pl-5aa44133"]
  }

  ingress {
    description       = "All ports from ELB"
    from_port         = 0
    to_port           = 65535
    protocol          = "tcp"
    security_groups   = [aws_security_group.elb-sg.id]
  }

  egress {
    description       = "Egress Ports"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.APP}-${var.AWS_REGION}-db-lambda-sg"
  }

  #checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource"
  #checkov:skip=CKV_AWS_23: "Ensure every security groups rule has a description"
}

module "dashboard-lambda-security-group-secret" {

  source              = "../../../modules/secret"
  NAME                = "${var.APP}-${var.AWS_REGION}-db-lambda-sg"
  VALUE               = aws_security_group.dashboard-lambda-sg.id
  AWS_BACKUP_REGION   = var.AWS_BACKUP_REGION
}

resource "aws_security_group" "aurora-sg" {

  name        = "${var.APP}-${var.AWS_REGION}-aurora-sg"
  description = "${var.APP}-${var.AWS_REGION}-aurora-sg"
  vpc_id      = module.approtation-vpc.vpc_id

  ingress {
    description      = "Aurora Port from VPC"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = [var.CIDR]
  }

  ingress {
    description      = "Aurora Port from Peer VPCs"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = var.PEER_CIDR
  }

  ingress {
    description      = "Aurora Port from AWS Corp"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    prefix_list_ids  = (var.AWS_REGION == "us-east-1")?["pl-4e2ece27"]:["pl-5aa44133"]
  }

  ingress {
    description      = "Aurora Port from ECS"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = [aws_security_group.ecs-sg.id]
  }

  ingress {
    description      = "Aurora Port from Dashbhoard Lambda"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = [aws_security_group.dashboard-lambda-sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.APP}-${var.AWS_REGION}-aurora-sg"
  }

  #checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource"
  #checkov:skip=CKV_AWS_23: "Ensure every security groups rule has a description"
}

module "aurora-security-group-secret" {

  source              = "../../../modules/secret"
  NAME                = "${var.APP}-${var.AWS_REGION}-aurora-sg"
  VALUE               = aws_security_group.aurora-sg.id
  AWS_BACKUP_REGION   = var.AWS_BACKUP_REGION
}

resource "aws_security_group" "mq_sg" {

  name        = "${var.APP}-${var.AWS_REGION}-mq-sg"
  description = "${var.APP}-${var.AWS_REGION}-mq-sg"
  vpc_id      = module.approtation-vpc.vpc_id

  ingress {
    description      = "Console Port from VPC"
    from_port        = 8162
    to_port          = 8162
    protocol         = "tcp"
    cidr_blocks      = [var.CIDR]
  }

  ingress {
    description      = "Console Port from Peer VPCs"
    from_port        = 8162
    to_port          = 8162
    protocol         = "tcp"
    cidr_blocks      = var.PEER_CIDR
  }

  ingress {
    description      = "Console Port from AWS Corp"
    from_port        = 8162
    to_port          = 8162
    protocol         = "tcp"
    prefix_list_ids  = (var.AWS_REGION == "us-east-1")?["pl-4e2ece27"]:["pl-5aa44133"]
  }

  ingress {
    description      = "Open Wire Port from VPC"
    from_port        = 61617
    to_port          = 61617
    protocol         = "tcp"
    cidr_blocks      = [var.CIDR]
  }

  ingress {
    description      = "Open Wire Port from Peer VPCs"
    from_port        = 61617
    to_port          = 61617
    protocol         = "tcp"
    cidr_blocks      = var.PEER_CIDR
  }

  ingress {
    description      = "Open Wire Port from Corp"
    from_port        = 61617
    to_port          = 61617
    protocol         = "tcp"
    prefix_list_ids  = (var.AWS_REGION == "us-east-1")?["pl-4e2ece27"]:["pl-5aa44133"]
  }

  ingress {
    description      = "Open Wire Port from ECS"
    from_port        = 61617
    to_port          = 61617
    protocol         = "tcp"
    security_groups  = [aws_security_group.ecs-sg.id]
  }

  ingress {
    description      = "Stomp Port from VPC"
    from_port        = 61614
    to_port          = 61614
    protocol         = "tcp"
    cidr_blocks      = [var.CIDR]
  }

  ingress {
    description      = "Stomp Port from Peer VPCs"
    from_port        = 61614
    to_port          = 61614
    protocol         = "tcp"
    cidr_blocks      = var.PEER_CIDR
  }

  ingress {
    description      = "Stomp Port from Corp"
    from_port        = 61614
    to_port          = 61614
    protocol         = "tcp"
    prefix_list_ids  = (var.AWS_REGION == "us-east-1")?["pl-4e2ece27"]:["pl-5aa44133"]
  }

  ingress {
    description      = "Stomp Port from ECS"
    from_port        = 61614
    to_port          = 61614
    protocol         = "tcp"
    security_groups  = [aws_security_group.ecs-sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.APP}-${var.AWS_REGION}-mq-sg"
  }

  #checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource"
  #checkov:skip=CKV_AWS_23: "Ensure every security groups rule has a description"
}



