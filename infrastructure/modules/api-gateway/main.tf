// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_lambda_function" "function" {

  function_name = var.FUNCTION_NAME

  s3_bucket = var.S3_BUCKET
  s3_key    = var.S3_KEY

  runtime = "python3.8"
  handler = var.LAMBDA_HANDLER
  timeout = 300
  publish = true

  source_code_hash = var.SOURCE_CODE_HASH

  // role = aws_iam_role.lambda_exec.arn
  role = var.LAMBDA_IAM_ROLE

  vpc_config {
    subnet_ids = var.SUBNET_IDS
    security_group_ids = var.SECURITY_GROUP_IDS
  }

  tracing_config {
    mode = "Active"
  }

//  reserved_concurrent_executions = 3

  #checkov:skip=CKV_AWS_115: "Ensure that AWS Lambda function is configured for function-level concurrent execution limit"
  #checkov:skip=CKV_AWS_116:Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ)
}

resource "aws_lambda_provisioned_concurrency_config" "function_concurrency" {

  function_name                     = aws_lambda_function.function.function_name
  provisioned_concurrent_executions = 3
  qualifier                         = aws_lambda_function.function.version
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_kms_key" "key" {

  description = "app-rotation-${var.FUNCTION_NAME}-log-key"
  enable_key_rotation = true

  tags = {
    Name ="app-rotation-${var.FUNCTION_NAME}-log-key"
  }

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "logs.${data.aws_region.current.name}.amazonaws.com"
            },
            "Action": [
                "kms:Encrypt*",
                "kms:Decrypt*",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:Describe*"
            ],
            "Resource": "*",
            "Condition": {
                "ArnLike": {
                    "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_kms_alias" "key_alias" {

  name          = "alias/app-rotation-${var.FUNCTION_NAME}-log-key"
  target_key_id = aws_kms_key.key.key_id
}

resource "aws_cloudwatch_log_group" "function_log_group" {

  name = "/aws/lambda/${aws_lambda_function.function.function_name}"
  kms_key_id = aws_kms_key.key.arn

  retention_in_days = 30
}

resource "aws_lambda_function" "options" {

  function_name = "${var.FUNCTION_NAME}_options"

  s3_bucket = var.S3_BUCKET
  s3_key    = var.S3_KEY

  runtime = "python3.8"
  handler = var.LAMBDA_OPTIONS_HANDLER
  timeout = 300
  publish = true

  source_code_hash = var.SOURCE_CODE_HASH

  // role = aws_iam_role.lambda_exec.arn
  role = var.LAMBDA_IAM_ROLE

  vpc_config {
    subnet_ids = var.SUBNET_IDS
    security_group_ids = var.SECURITY_GROUP_IDS
  }

  tracing_config {
    mode = "Active"
  }

//  reserved_concurrent_executions = 3

  #checkov:skip=CKV_AWS_115: "Ensure that AWS Lambda function is configured for function-level concurrent execution limit"
  #checkov:skip=CKV_AWS_116:Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ)
}

resource "aws_lambda_provisioned_concurrency_config" "options_concurrency" {

  function_name                     = aws_lambda_function.options.function_name
  provisioned_concurrent_executions = 3
  qualifier                         = aws_lambda_function.options.version
}

resource "aws_cloudwatch_log_group" "options_log_group" {

  name = "/aws/lambda/${aws_lambda_function.options.function_name}"
  kms_key_id = aws_kms_key.key.arn

  retention_in_days = 30
}

resource "aws_api_gateway_rest_api" "api" {

  name        = var.API_NAME
  description = var.API_NAME

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "resource" {

  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = var.RESOURCE_NAME
}

resource "aws_api_gateway_method" "method" {

  rest_api_id       = aws_api_gateway_rest_api.api.id
  resource_id       = aws_api_gateway_resource.resource.id
  api_key_required  = true
  http_method       = var.METHOD_NAME
  authorization     = "NONE"
}

resource "aws_api_gateway_method" "options" {

  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "method_integration" {

  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.function.invoke_arn
  credentials             = var.API_IAM_ROLE
}

resource "aws_api_gateway_integration" "options_integration" {

  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.options.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.options.invoke_arn
  credentials             = var.API_IAM_ROLE
}

resource "aws_api_gateway_deployment" "deployment" {

  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.resource.id,
      aws_api_gateway_method.method.id,
      aws_api_gateway_integration.method_integration.id,
      aws_api_gateway_method.options.id,
      aws_api_gateway_integration.options_integration.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
        aws_api_gateway_resource.resource,
        aws_api_gateway_method.method,
        aws_api_gateway_integration.method_integration,
        aws_api_gateway_method.options,
        aws_api_gateway_integration.options_integration
      ]
}

resource "random_string" "suffix" {

  length           = 6
  upper            = false
  lower            = true
  number           = false
  special          = false
  override_special = ""
}

data "aws_elb_service_account" "main" {}

resource "aws_api_gateway_account" "demo" {
  cloudwatch_role_arn = var.CLOUDWATCH_IAM_ROLE
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "app-rotation-api-gateay-${var.FUNCTION_NAME}"
  kms_key_id = aws_kms_key.key.arn
  retention_in_days = 90
}

resource "aws_api_gateway_stage" "stage" {

  deployment_id           = aws_api_gateway_deployment.deployment.id
  rest_api_id             = aws_api_gateway_rest_api.api.id
  stage_name              = var.STAGE
//  cache_cluster_enabled   = true
//  cache_cluster_size      = 1.6
  xray_tracing_enabled    = true

  access_log_settings {
   destination_arn = aws_cloudwatch_log_group.log_group.arn
   format          = "$context.requestId"
  }

  #checkov:skip=CKV_AWS_120: "Ensure API Gateway caching is enabled"
  #checkov:skip=CKV2_AWS_29:Ensure public API gateway are protected by WAF
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "ERROR"
//    caching_enabled = true
  }

  #checkov:skip=CKV_AWS_225:Ensure API Gateway method setting caching is enabled
}

resource "aws_lambda_permission" "method_permission" {

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.arn
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_deployment.deployment.execution_arn}/*/*"
}

resource "aws_lambda_permission" "options_permission" {

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.options.arn
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_deployment.deployment.execution_arn}/*/*"
}

resource "aws_api_gateway_api_key" "key" {

  name = var.API_NAME
}

resource "aws_api_gateway_usage_plan" "usage_plan" {

  name = var.API_NAME

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.stage.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {

  key_id        = aws_api_gateway_api_key.key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}

