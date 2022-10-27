// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

provider "aws" {

  alias = "primary"
  region = var.AWS_PRIMARY_REGION
}

provider "aws" {

  alias  = "secondary"
  region = var.AWS_SECONDARY_REGION
}

resource "random_string" "username" {

  length           = 8
  upper            = true
  lower            = true
  number           = false
  special          = false
  override_special = ""
}

resource "random_password" "password" {

  length           = 12
  upper            = true
  lower            = true
  number           = true
  special          = false
  override_special = "!@#$%&*()-_=+[]{}<>:?"
}

locals {
  dbname = replace("${var.APP}${var.COMPONENT}", "-", "")
  username_value = random_string.username.result
  password_value = random_password.password.result
}

data "aws_secretsmanager_secret" "aurora_primary-sg-secret" {

  name = "${var.APP}-${var.AWS_PRIMARY_REGION}-aurora-sg"
}

data "aws_secretsmanager_secret_version" "aurora_primary-sg-secret-version" {

  secret_id = data.aws_secretsmanager_secret.aurora_primary-sg-secret.id
}

data "aws_secretsmanager_secret" "aurora_secondary-sg-secret" {

  name = "${var.APP}-${var.AWS_SECONDARY_REGION}-aurora-sg"
}

data "aws_secretsmanager_secret_version" "aurora_secondary-sg-secret-version" {

  secret_id = data.aws_secretsmanager_secret.aurora_secondary-sg-secret.id
}

resource "aws_kms_key" "primary_key" {

  provider            = aws.primary
  enable_key_rotation = true

  description = "${var.APP}-${var.COMPONENT}-primary-rds-cluster-kms-key"
}

resource "aws_kms_alias" "primary_key_alias" {

  provider = aws.primary

  name          = "alias/${var.APP}-${var.COMPONENT}-primary-rds-cluster-kms-key"
  target_key_id = aws_kms_key.primary_key.key_id
}

resource "aws_kms_key" "secondary_key" {

  provider            = aws.secondary
  enable_key_rotation = true

  description = "${var.APP}-${var.COMPONENT}-secondary-rds-cluster-kms-key"
}

resource "aws_kms_alias" "secondary_key_alias" {

  provider = aws.secondary

  name          = "alias/${var.APP}-${var.COMPONENT}-secondary-rds-cluster-kms-key"
  target_key_id = aws_kms_key.secondary_key.key_id
}

resource "aws_rds_cluster_parameter_group" "primary_parameter_group" {

  provider = aws.primary

  name = "${var.APP}-${var.COMPONENT}-primary-rds-parameter-group"
  family      = "aurora-postgresql11"
  description = "${var.APP}-${var.COMPONENT}-primary-rds-parameter-group"

  parameter {
    name="log_statement"
    value="all"
  }

  parameter {
    name="log_min_duration_statement"
    value="1"
  }
}

resource "aws_rds_cluster_parameter_group" "secondary_parameter_group" {

  provider = aws.secondary

  name = "${var.APP}-${var.COMPONENT}-secondary-rds-parameter-group"
  family      = "aurora-postgresql11"
  description = "${var.APP}-${var.COMPONENT}-secondary-rds-parameter-group"

  parameter {
    name="log_statement"
    value="all"
  }

  parameter {
    name="log_min_duration_statement"
    value="1"
  }
}

resource "aws_rds_global_cluster" "global-cluster" {

  global_cluster_identifier = "${var.APP}-${var.COMPONENT}-global-cluster"
  engine                    = var.DB_ENGINE
  engine_version            = var.DB_ENGINE_VERSION
  database_name             = local.dbname
  storage_encrypted         = true
  force_destroy             = true
}

resource "aws_rds_cluster" "primary" {

  provider                  = aws.primary
  engine                    = aws_rds_global_cluster.global-cluster.engine
  engine_version            = aws_rds_global_cluster.global-cluster.engine_version
  cluster_identifier        = "${var.APP}-${var.COMPONENT}-primary-cluster"
  master_username           = local.username_value
  master_password           = local.password_value
  database_name             = local.dbname
  global_cluster_identifier = aws_rds_global_cluster.global-cluster.id
  db_subnet_group_name      = "${var.APP}-${var.AWS_PRIMARY_REGION}-db-subnet-group"
  storage_encrypted         = true
  kms_key_id                = aws_kms_key.primary_key.arn
  skip_final_snapshot       = true
  vpc_security_group_ids    = [data.aws_secretsmanager_secret_version.aurora_primary-sg-secret-version.secret_string]
  iam_database_authentication_enabled = true
  deletion_protection       = true
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.primary_parameter_group.name

  depends_on = [aws_rds_cluster_parameter_group.primary_parameter_group]
  #checkov:skip=CKV2_AWS_8: "Ensure RDS clusters have an AWS Backup backup plan"

  tags = {
    Industry = "GFS"
    Program = "AppRotation"
    Application = var.APP
    Component   = var.COMPONENT
    Environment = var.ENV
  }
}

resource "aws_rds_cluster_instance" "primary" {

  provider                    = aws.primary
  engine                      = aws_rds_global_cluster.global-cluster.engine
  engine_version              = aws_rds_global_cluster.global-cluster.engine_version
  identifier                  = "${var.APP}-${var.COMPONENT}-primary-cluster-instance"
  cluster_identifier          = aws_rds_cluster.primary.id
  instance_class              = var.DB_INSTANCE_CLASS
  db_subnet_group_name        = "${var.APP}-${var.AWS_PRIMARY_REGION}-db-subnet-group"
  publicly_accessible         = false
  auto_minor_version_upgrade  = true
  monitoring_interval         = 5
  monitoring_role_arn         = aws_iam_role.monitoring_iam.arn

  tags = {
    Industry = "GFS"
    Program = "AppRotation"
    Application = var.APP
    Component   = var.COMPONENT
    Environment = var.ENV
  }
}

resource "aws_rds_cluster" "secondary" {

  provider                  = aws.secondary
  engine                    = aws_rds_global_cluster.global-cluster.engine
  engine_version            = aws_rds_global_cluster.global-cluster.engine_version
  cluster_identifier        = "${var.APP}-${var.COMPONENT}-secondary-cluster"
  global_cluster_identifier = aws_rds_global_cluster.global-cluster.id
  db_subnet_group_name      = "${var.APP}-${var.AWS_SECONDARY_REGION}-db-subnet-group"
  storage_encrypted         = true
  kms_key_id                = aws_kms_key.secondary_key.arn
  skip_final_snapshot       = true
  vpc_security_group_ids    = [data.aws_secretsmanager_secret_version.aurora_secondary-sg-secret-version.secret_string]
  iam_database_authentication_enabled = true
  deletion_protection = true
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.secondary_parameter_group.name

  depends_on = [
    aws_rds_cluster_instance.primary,
    aws_rds_cluster_parameter_group.secondary_parameter_group
  ]
  #checkov:skip=CKV2_AWS_8: "Ensure RDS clusters have an AWS Backup backup plan"

  tags = {
    Industry = "GFS"
    Program = "AppRotation"
    Application = var.APP
    Component   = var.COMPONENT
    Environment = var.ENV
  }
}

resource "aws_rds_cluster_instance" "secondary" {

  provider                    = aws.secondary
  engine                      = aws_rds_global_cluster.global-cluster.engine
  engine_version              = aws_rds_global_cluster.global-cluster.engine_version
  identifier                  = "${var.APP}-${var.COMPONENT}-secondary-cluster-instance"
  cluster_identifier          = aws_rds_cluster.secondary.id
  instance_class              = var.DB_INSTANCE_CLASS
  db_subnet_group_name        = "${var.APP}-${var.AWS_SECONDARY_REGION}-db-subnet-group"
  publicly_accessible         = false
  auto_minor_version_upgrade  = true
  monitoring_interval         = 5
  monitoring_role_arn         = aws_iam_role.monitoring_iam.arn

  tags = {
    Industry = "GFS"
    Program = "AppRotation"
    Application = var.APP
    Component   = var.COMPONENT
    Environment = var.ENV
  }
}

locals  {
  DatabaseCredentials = {
    username  = local.username_value
    password  = local.password_value
    engine    = var.DB_ENGINE
    host      = aws_rds_cluster.primary.endpoint
    port      = 5432
    dbname    = local.dbname
    dbClusterIdentifier = aws_rds_cluster.primary.id
  }
}

module "secret" {

  source                = "../secret"

  NAME                  = "${var.APP}-${var.COMPONENT}-database"
  VALUE                 = jsonencode(local.DatabaseCredentials)
  AWS_BACKUP_REGION     = var.AWS_SECONDARY_REGION
}

module "database-cluster-secret" {

  source                = "../secret"

  NAME                  = "${var.APP}-${var.COMPONENT}-database-cluster"
  VALUE                 = aws_rds_global_cluster.global-cluster.id
  AWS_BACKUP_REGION     = var.AWS_SECONDARY_REGION
}

module "primary-database-backup" {

  source                = "../backup"

  AWS_REGION            = var.AWS_PRIMARY_REGION

  NAME                  = "${var.APP}-${var.COMPONENT}-p-db"
  RESOURCE_ARN          = aws_rds_cluster.primary.arn
}

module "secondary-database-backup" {

  source                = "../backup"

  AWS_REGION            = var.AWS_SECONDARY_REGION
  NAME                  = "${var.APP}-${var.COMPONENT}-s-db"
  RESOURCE_ARN          = aws_rds_cluster.secondary.arn
}

