// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.48.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "approtation-get-app-state-${var.ENV}"

  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
      }
    }
  }

  #checkov:skip=CKV_AWS_144:Ensure that S3 bucket has cross-region replication enabled
  #checkov:skip=CKV_AWS_18:Ensure the S3 bucket has access logging enabled
  #checkov:skip=CKV_AWS_186: "Ensure S3 bucket Object is encrypted by KMS using a customer managed Key (CMK)"
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {

  bucket = aws_s3_bucket.lambda_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "archive_file" "lambda_get_app_state" {
  type = "zip"

  source_dir  = "${path.module}/src"
  output_path = "${path.module}/get_app_state.zip"
}

resource "aws_s3_bucket_object" "lambda_get_app_state" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "get_app_state.zip"
  source = data.archive_file.lambda_get_app_state.output_path

  etag = filemd5(data.archive_file.lambda_get_app_state.output_path)

  #checkov:skip=CKV_AWS_186: "Ensure S3 bucket Object is encrypted by KMS using a customer managed Key (CMK)"
}

data "aws_secretsmanager_secret" "trade-matching-primary-vpc-subnet1-secret" {
  name = "trade-matching-us-east-1-private-subnet-1"
}

data "aws_secretsmanager_secret_version" "trade-matching-primary-vpc-subnet1-secret-version" {
  secret_id = data.aws_secretsmanager_secret.trade-matching-primary-vpc-subnet1-secret.id
}

data "aws_secretsmanager_secret" "trade-matching-primary-vpc-subnet2-secret" {
  name = "trade-matching-us-east-1-private-subnet-2"
}

data "aws_secretsmanager_secret_version" "trade-matching-primary-vpc-subnet2-secret-version" {
  secret_id = data.aws_secretsmanager_secret.trade-matching-primary-vpc-subnet2-secret.id
}

data "aws_secretsmanager_secret" "trade-matching-primary-vpc-subnet3-secret" {
  name = "trade-matching-us-east-1-private-subnet-3"
}

data "aws_secretsmanager_secret_version" "trade-matching-primary-vpc-subnet3-secret-version" {
  secret_id = data.aws_secretsmanager_secret.trade-matching-primary-vpc-subnet3-secret.id
}

locals {
  private_subnet_ids = [data.aws_secretsmanager_secret_version.trade-matching-primary-vpc-subnet1-secret-version.secret_string,
                       data.aws_secretsmanager_secret_version.trade-matching-primary-vpc-subnet2-secret-version.secret_string,
                       data.aws_secretsmanager_secret_version.trade-matching-primary-vpc-subnet3-secret-version.secret_string]
}

data "aws_secretsmanager_secret" "dashboard_lambda_sg_secret" {
  name = "trade-matching-us-east-1-db-lambda-sg"
}

data "aws_secretsmanager_secret_version" "dashboard_lambda_sg_secret_version" {
  secret_id = data.aws_secretsmanager_secret.dashboard_lambda_sg_secret.id
}

data "aws_security_group" "security_group" {
  name = "trade-matching-ecs-sg"
}

module "app_state" {
  source                    = "../../modules/api-gateway"

  FUNCTION_NAME             = "get_app_state"
  S3_BUCKET                 = aws_s3_bucket.lambda_bucket.id
  S3_KEY                    = aws_s3_bucket_object.lambda_get_app_state.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_get_app_state.output_base64sha256
  LAMBDA_HANDLER            = "api.get_app_state"
  LAMBDA_OPTIONS_HANDLER    = "api.options"
  LAMBDA_IAM_ROLE           = aws_iam_role.lambda_exec.arn
  API_IAM_ROLE              = aws_iam_role.api_exec.arn
  CLOUDWATCH_IAM_ROLE       = aws_iam_role.api_cloudwatch.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_secretsmanager_secret_version.dashboard_lambda_sg_secret_version.secret_string]
  API_NAME                  = "app_state"
  RESOURCE_NAME             = "app_state"
  METHOD_NAME               = "GET"
  STAGE                     = "dev"
}

module "app_states" {
  source                    = "../../modules/api-gateway"

  FUNCTION_NAME             = "get_app_states"
  S3_BUCKET                 = aws_s3_bucket.lambda_bucket.id
  S3_KEY                    = aws_s3_bucket_object.lambda_get_app_state.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_get_app_state.output_base64sha256
  LAMBDA_HANDLER            = "api.get_app_states"
  LAMBDA_OPTIONS_HANDLER    = "api.options"
  LAMBDA_IAM_ROLE           = aws_iam_role.lambda_exec.arn
  API_IAM_ROLE              = aws_iam_role.api_exec.arn
  CLOUDWATCH_IAM_ROLE       = aws_iam_role.api_cloudwatch.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_secretsmanager_secret_version.dashboard_lambda_sg_secret_version.secret_string]
  API_NAME                  = "app_states"
  RESOURCE_NAME             = "app_states"
  METHOD_NAME               = "GET"
  STAGE                     = "dev"
}

module "app_controls" {
  source                    = "../../modules/api-gateway"

  FUNCTION_NAME             = "get_app_controls"
  S3_BUCKET                 = aws_s3_bucket.lambda_bucket.id
  S3_KEY                    = aws_s3_bucket_object.lambda_get_app_state.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_get_app_state.output_base64sha256
  LAMBDA_HANDLER            = "api.get_app_controls"
  LAMBDA_OPTIONS_HANDLER    = "api.options"
  LAMBDA_IAM_ROLE           = aws_iam_role.lambda_exec.arn
  API_IAM_ROLE              = aws_iam_role.api_exec.arn
  CLOUDWATCH_IAM_ROLE       = aws_iam_role.api_cloudwatch.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_secretsmanager_secret_version.dashboard_lambda_sg_secret_version.secret_string]
  API_NAME                  = "app_controls"
  RESOURCE_NAME             = "app_controls"
  METHOD_NAME               = "GET"
  STAGE                     = "dev"
}

module "arc_control" {
  source                    = "../../modules/api-gateway"

  FUNCTION_NAME             = "update_arc_control"
  S3_BUCKET                 = aws_s3_bucket.lambda_bucket.id
  S3_KEY                    = aws_s3_bucket_object.lambda_get_app_state.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_get_app_state.output_base64sha256
  LAMBDA_HANDLER            = "api.update_arc_control"
  LAMBDA_OPTIONS_HANDLER    = "api.options"
  LAMBDA_IAM_ROLE           = aws_iam_role.lambda_exec.arn
  API_IAM_ROLE              = aws_iam_role.api_exec.arn
  CLOUDWATCH_IAM_ROLE       = aws_iam_role.api_cloudwatch.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_secretsmanager_secret_version.dashboard_lambda_sg_secret_version.secret_string]
  API_NAME                  = "arc_control"
  RESOURCE_NAME             = "arc_control"
  METHOD_NAME               = "POST"
  STAGE                     = "dev"
}

module "execute_run_book" {
  source                    = "../../modules/api-gateway"

  FUNCTION_NAME             = "execute_run_book"
  S3_BUCKET                 = aws_s3_bucket.lambda_bucket.id
  S3_KEY                    = aws_s3_bucket_object.lambda_get_app_state.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_get_app_state.output_base64sha256
  LAMBDA_HANDLER            = "api.execute_run_book"
  LAMBDA_OPTIONS_HANDLER    = "api.options"
  LAMBDA_IAM_ROLE           = aws_iam_role.lambda_exec.arn
  API_IAM_ROLE              = aws_iam_role.api_exec.arn
  CLOUDWATCH_IAM_ROLE       = aws_iam_role.api_cloudwatch.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_secretsmanager_secret_version.dashboard_lambda_sg_secret_version.secret_string]
  API_NAME                  = "runbook"
  RESOURCE_NAME             = "runbook"
  METHOD_NAME               = "POST"
  STAGE                     = "dev"
}

module "app_recons" {
  source                    = "../../modules/api-gateway"

  FUNCTION_NAME             = "get_app_recons"
  S3_BUCKET                 = aws_s3_bucket.lambda_bucket.id
  S3_KEY                    = aws_s3_bucket_object.lambda_get_app_state.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_get_app_state.output_base64sha256
  LAMBDA_HANDLER            = "api.get_app_recons"
  LAMBDA_OPTIONS_HANDLER    = "api.options"
  LAMBDA_IAM_ROLE           = aws_iam_role.lambda_exec.arn
  API_IAM_ROLE              = aws_iam_role.api_exec.arn
  CLOUDWATCH_IAM_ROLE       = aws_iam_role.api_cloudwatch.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_secretsmanager_secret_version.dashboard_lambda_sg_secret_version.secret_string]
  API_NAME                  = "app_recons"
  RESOURCE_NAME             = "app_recons"
  METHOD_NAME               = "GET"
  STAGE                     = "dev"
}

module "app_recon_step" {
  source                    = "../../modules/api-gateway"

  FUNCTION_NAME             = "get_app_recon_step"
  S3_BUCKET                 = aws_s3_bucket.lambda_bucket.id
  S3_KEY                    = aws_s3_bucket_object.lambda_get_app_state.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_get_app_state.output_base64sha256
  LAMBDA_HANDLER            = "api.get_app_recon_step"
  LAMBDA_OPTIONS_HANDLER    = "api.options"
  LAMBDA_IAM_ROLE           = aws_iam_role.lambda_exec.arn
  API_IAM_ROLE              = aws_iam_role.api_exec.arn
  CLOUDWATCH_IAM_ROLE       = aws_iam_role.api_cloudwatch.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_secretsmanager_secret_version.dashboard_lambda_sg_secret_version.secret_string]
  API_NAME                  = "app_recon_step"
  RESOURCE_NAME             = "app_recon_step"
  METHOD_NAME               = "GET"
  STAGE                     = "dev"
}

module "app_ready" {
  source                    = "../../modules/api-gateway"

  FUNCTION_NAME             = "get_app_ready"
  S3_BUCKET                 = aws_s3_bucket.lambda_bucket.id
  S3_KEY                    = aws_s3_bucket_object.lambda_get_app_state.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_get_app_state.output_base64sha256
  LAMBDA_HANDLER            = "api.get_app_ready"
  LAMBDA_OPTIONS_HANDLER    = "api.options"
  LAMBDA_IAM_ROLE           = aws_iam_role.lambda_exec.arn
  API_IAM_ROLE              = aws_iam_role.api_exec.arn
  CLOUDWATCH_IAM_ROLE       = aws_iam_role.api_cloudwatch.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_secretsmanager_secret_version.dashboard_lambda_sg_secret_version.secret_string]
  API_NAME                  = "app_ready"
  RESOURCE_NAME             = "app_ready"
  METHOD_NAME               = "GET"
  STAGE                     = "dev"
}

module "app_health" {
  source                    = "../../modules/api-gateway"

  FUNCTION_NAME             = "get_app_health"
  S3_BUCKET                 = aws_s3_bucket.lambda_bucket.id
  S3_KEY                    = aws_s3_bucket_object.lambda_get_app_state.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_get_app_state.output_base64sha256
  LAMBDA_HANDLER            = "api.get_app_health"
  LAMBDA_OPTIONS_HANDLER    = "api.options"
  LAMBDA_IAM_ROLE           = aws_iam_role.lambda_exec.arn
  API_IAM_ROLE              = aws_iam_role.api_exec.arn
  CLOUDWATCH_IAM_ROLE       = aws_iam_role.api_cloudwatch.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_secretsmanager_secret_version.dashboard_lambda_sg_secret_version.secret_string]
  API_NAME                  = "app_health"
  RESOURCE_NAME             = "app_health"
  METHOD_NAME               = "GET"
  STAGE                     = "dev"
}

module "app_replication" {
  source                    = "../../modules/api-gateway"

  FUNCTION_NAME             = "get_replication_latency"
  S3_BUCKET                 = aws_s3_bucket.lambda_bucket.id
  S3_KEY                    = aws_s3_bucket_object.lambda_get_app_state.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_get_app_state.output_base64sha256
  LAMBDA_HANDLER            = "api.get_replication_latency"
  LAMBDA_OPTIONS_HANDLER    = "api.options"
  LAMBDA_IAM_ROLE           = aws_iam_role.lambda_exec.arn
  API_IAM_ROLE              = aws_iam_role.api_exec.arn
  CLOUDWATCH_IAM_ROLE       = aws_iam_role.api_cloudwatch.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_secretsmanager_secret_version.dashboard_lambda_sg_secret_version.secret_string]
  API_NAME                  = "app_replication"
  RESOURCE_NAME             = "app_replication"
  METHOD_NAME               = "GET"
  STAGE                     = "dev"
}

module "start_app" {
  source                    = "../../modules/api-gateway"

  FUNCTION_NAME             = "start_tasks_for_app"
  S3_BUCKET                 = aws_s3_bucket.lambda_bucket.id
  S3_KEY                    = aws_s3_bucket_object.lambda_get_app_state.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_get_app_state.output_base64sha256
  LAMBDA_HANDLER            = "api.start_tasks_for_app"
  LAMBDA_OPTIONS_HANDLER    = "api.options"
  LAMBDA_IAM_ROLE           = aws_iam_role.lambda_exec.arn
  API_IAM_ROLE              = aws_iam_role.api_exec.arn
  CLOUDWATCH_IAM_ROLE       = aws_iam_role.api_cloudwatch.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_secretsmanager_secret_version.dashboard_lambda_sg_secret_version.secret_string]
  API_NAME                  = "start_app"
  RESOURCE_NAME             = "start_app"
  METHOD_NAME               = "POST"
  STAGE                     = "dev"
}

module "stop_apps" {
  source                    = "../../modules/api-gateway"

  FUNCTION_NAME             = "stop_all_tasks_in_region"
  S3_BUCKET                 = aws_s3_bucket.lambda_bucket.id
  S3_KEY                    = aws_s3_bucket_object.lambda_get_app_state.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_get_app_state.output_base64sha256
  LAMBDA_HANDLER            = "api.stop_all_tasks_in_region"
  LAMBDA_OPTIONS_HANDLER    = "api.options"
  LAMBDA_IAM_ROLE           = aws_iam_role.lambda_exec.arn
  API_IAM_ROLE              = aws_iam_role.api_exec.arn
  CLOUDWATCH_IAM_ROLE       = aws_iam_role.api_cloudwatch.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_secretsmanager_secret_version.dashboard_lambda_sg_secret_version.secret_string]
  API_NAME                  = "stop_apps"
  RESOURCE_NAME             = "stop_apps"
  METHOD_NAME               = "POST"
  STAGE                     = "dev"
}

module "clean_databases" {
  source                    = "../../modules/api-gateway"

  FUNCTION_NAME             = "clean_databases"
  S3_BUCKET                 = aws_s3_bucket.lambda_bucket.id
  S3_KEY                    = aws_s3_bucket_object.lambda_get_app_state.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_get_app_state.output_base64sha256
  LAMBDA_HANDLER            = "api.clean_databases"
  LAMBDA_OPTIONS_HANDLER    = "api.options"
  LAMBDA_IAM_ROLE           = aws_iam_role.lambda_exec.arn
  API_IAM_ROLE              = aws_iam_role.api_exec.arn
  CLOUDWATCH_IAM_ROLE       = aws_iam_role.api_cloudwatch.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_secretsmanager_secret_version.dashboard_lambda_sg_secret_version.secret_string]
  API_NAME                  = "clean_databases"
  RESOURCE_NAME             = "clean_databases"
  METHOD_NAME               = "POST"
  STAGE                     = "dev"
}

module "executions" {
  source                    = "../../modules/api-gateway"

  FUNCTION_NAME             = "get_executions"
  S3_BUCKET                 = aws_s3_bucket.lambda_bucket.id
  S3_KEY                    = aws_s3_bucket_object.lambda_get_app_state.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_get_app_state.output_base64sha256
  LAMBDA_HANDLER            = "api.get_executions"
  LAMBDA_OPTIONS_HANDLER    = "api.options"
  LAMBDA_IAM_ROLE           = aws_iam_role.lambda_exec.arn
  API_IAM_ROLE              = aws_iam_role.api_exec.arn
  CLOUDWATCH_IAM_ROLE       = aws_iam_role.api_cloudwatch.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_secretsmanager_secret_version.dashboard_lambda_sg_secret_version.secret_string]
  API_NAME                  = "executions"
  RESOURCE_NAME             = "executions"
  METHOD_NAME               = "GET"
  STAGE                     = "dev"
}

module "execution_detail" {
  source                    = "../../modules/api-gateway"

  FUNCTION_NAME             = "get_execution_detail"
  S3_BUCKET                 = aws_s3_bucket.lambda_bucket.id
  S3_KEY                    = aws_s3_bucket_object.lambda_get_app_state.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_get_app_state.output_base64sha256
  LAMBDA_HANDLER            = "api.get_execution_detail"
  LAMBDA_OPTIONS_HANDLER    = "api.options"
  LAMBDA_IAM_ROLE           = aws_iam_role.lambda_exec.arn
  API_IAM_ROLE              = aws_iam_role.api_exec.arn
  CLOUDWATCH_IAM_ROLE       = aws_iam_role.api_cloudwatch.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_secretsmanager_secret_version.dashboard_lambda_sg_secret_version.secret_string]
  API_NAME                  = "execution_detail"
  RESOURCE_NAME             = "execution_detail"
  METHOD_NAME               = "GET"
  STAGE                     = "dev"
}

module "experiment" {
  source                    = "../../modules/api-gateway"

  FUNCTION_NAME             = "run_experiment"
  S3_BUCKET                 = aws_s3_bucket.lambda_bucket.id
  S3_KEY                    = aws_s3_bucket_object.lambda_get_app_state.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_get_app_state.output_base64sha256
  LAMBDA_HANDLER            = "api.run_experiment"
  LAMBDA_OPTIONS_HANDLER    = "api.options"
  LAMBDA_IAM_ROLE           = aws_iam_role.lambda_exec.arn
  API_IAM_ROLE              = aws_iam_role.api_exec.arn
  CLOUDWATCH_IAM_ROLE       = aws_iam_role.api_cloudwatch.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_secretsmanager_secret_version.dashboard_lambda_sg_secret_version.secret_string]
  API_NAME                  = "experiment"
  RESOURCE_NAME             = "experiment"
  METHOD_NAME               = "POST"
  STAGE                     = "dev"
}

module "start_app_component" {
  source                    = "../../modules/api-gateway"

  FUNCTION_NAME             = "start_tasks_for_app_component"
  S3_BUCKET                 = aws_s3_bucket.lambda_bucket.id
  S3_KEY                    = aws_s3_bucket_object.lambda_get_app_state.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_get_app_state.output_base64sha256
  LAMBDA_HANDLER            = "api.start_tasks_for_app_component"
  LAMBDA_OPTIONS_HANDLER    = "api.options"
  LAMBDA_IAM_ROLE           = aws_iam_role.lambda_exec.arn
  API_IAM_ROLE              = aws_iam_role.api_exec.arn
  CLOUDWATCH_IAM_ROLE       = aws_iam_role.api_cloudwatch.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_secretsmanager_secret_version.dashboard_lambda_sg_secret_version.secret_string]
  API_NAME                  = "start_app_component"
  RESOURCE_NAME             = "start_app_component"
  METHOD_NAME               = "POST"
  STAGE                     = "dev"
}

module "enable_vpc_endpoint" {
  source                    = "../../modules/api-gateway"

  FUNCTION_NAME             = "enable_vpc_endpoint"
  S3_BUCKET                 = aws_s3_bucket.lambda_bucket.id
  S3_KEY                    = aws_s3_bucket_object.lambda_get_app_state.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_get_app_state.output_base64sha256
  LAMBDA_HANDLER            = "api.enable_vpc_endpoint"
  LAMBDA_OPTIONS_HANDLER    = "api.options"
  LAMBDA_IAM_ROLE           = aws_iam_role.lambda_exec.arn
  API_IAM_ROLE              = aws_iam_role.api_exec.arn
  CLOUDWATCH_IAM_ROLE       = aws_iam_role.api_cloudwatch.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_secretsmanager_secret_version.dashboard_lambda_sg_secret_version.secret_string]
  API_NAME                  = "enable_vpc_endpoint"
  RESOURCE_NAME             = "enable_vpc_endpoint"
  METHOD_NAME               = "POST"
  STAGE                     = "dev"
}