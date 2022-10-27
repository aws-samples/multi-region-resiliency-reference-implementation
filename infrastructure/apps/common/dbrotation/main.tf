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

  region = var.AWS_REGION
}

//resource "aws_kms_key" "key" {
//
//  description = "approtation-database-rotation-lambda-key-${var.ENV}"
//  enable_key_rotation = true
//
//  tags = {
//    Name ="approtation-database-rotation-lambda-key-${var.ENV}"
//  }
//}
//
//resource "aws_kms_alias" "key_alias" {
//
//  name          = "alias/approtation-database-rotation-lambda-key-${var.ENV}"
//  target_key_id = aws_kms_key.key.key_id
//}

resource "aws_s3_bucket" "lambda_bucket" {

  bucket = "approtation-database-rotation-lambda-${var.ENV}"

  acl           = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
      }
    }
  }
  #checkov:skip=CKV_AWS_19: "Ensure all data stored in the S3 bucket is securely encrypted at rest"
  #checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
  #checkov:skip=CKV_AWS_18: CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"
  #checkov:skip=CKV_AWS_145: "Ensure that S3 buckets are encrypted with KMS by default"
  #checkov:skip=CKV_AWS_21: "Ensure all data stored in the S3 bucket have versioning enabled"
  #checkov:skip=CKV_AWS_186: "Ensure S3 bucket Object is encrypted by KMS using a customer managed Key (CMK)"
  #checkov:skip=CKV2_AWS_6: "Ensure that S3 bucket has a Public Access block"
  #checkov:skip=CKV_AWS_144:Ensure that S3 bucket has cross-region replication enabled
}

data "archive_file" "lambda_dbrotation" {

  type = "zip"

  source_dir  = "${path.module}/dbrotation"
  output_path = "${path.module}/dbrotation.zip"
}

resource "aws_s3_bucket_object" "lambda_dbrotation" {

  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "dbrotation.zip"
  source = data.archive_file.lambda_dbrotation.output_path

  etag = filemd5(data.archive_file.lambda_dbrotation.output_path)

  #checkov:skip=CKV_AWS_186: "Ensure S3 bucket Object is encrypted by KMS using a customer managed Key (CMK)"
}

resource "aws_lambda_function" "dbrotation" {

  function_name = "dbrotation"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_bucket_object.lambda_dbrotation.key

  runtime = "nodejs12.x"
  handler = "dbrotation.handler"

  source_code_hash = data.archive_file.lambda_dbrotation.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      DeploymentRegions = "[\"us-east-1\", \"us-west-2\"]"
      AuroraGlobalClusterId = "settlement-core-global-cluster"
      AuroraClusterArns = "{\"us-east-1\":\"arn:aws:rds:us-east-1:285719923712:cluster:settlement-core-primary-cluster\", \"us-west-2\":\"arn:aws:rds:us-west-2:285719923712:cluster:settlement-core-secondary-cluster\"}"
      RoutingControlArns = "{\"us-east-1\":\"arn:aws:route53-recovery-control::285719923712:controlpanel/c79886e1e5e84c4da2547dbbe027e0d6/routingcontrol/57fc1c681cc94581\",\"us-west-2\":\"arn:aws:route53-recovery-control::285719923712:controlpanel/378bc57b246d41e6bc26e5e020294e43/routingcontrol/d669b4e7caa64e33\"}"
      ClusterEndpoints = "{\"us-east-1\":\"https://60f985e7.route53-recovery-cluster.us-east-1.amazonaws.com/v1\",\"us-west-2\":\"https://9a60c72f.route53-recovery-cluster.us-west-2.amazonaws.com/v1\"}"
    }
  }

  #checkov:skip=CKV_AWS_50: "X-ray tracing is enabled for Lambda"
  #checkov:skip=CKV_AWS_117: "Ensure that AWS Lambda function is configured inside a VPC"
  #checkov:skip=CKV_AWS_116: "Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ)"
  #checkov:skip=CKV_AWS_173: "Check encryption settings for Lambda environmental variable"
  #checkov:skip=CKV_AWS_115: "Ensure that AWS Lambda function is configured for function-level concurrent execution limit"
}

resource "aws_cloudwatch_log_group" "dbrotation" {

  name = "/aws/lambda/${aws_lambda_function.dbrotation.function_name}"

  retention_in_days = 30
  #checkov:skip=CKV_AWS_158: "Ensure that CloudWatch Log Group is encrypted by KMS"
}

resource "aws_iam_role" "lambda_exec" {

  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_full_access_policy_attachment" {

  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {

  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
