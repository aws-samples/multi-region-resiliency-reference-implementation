// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_kms_key" "key" {

  description         = "${var.APP}-${var.COMPONENT}-${var.AWS_REGION}-kinesis-kms-key"
  enable_key_rotation = true

  tags        = {
    Terraform   = "true"
    Environment = var.ENV
    Name = "${var.APP}-${var.COMPONENT}-${var.AWS_REGION}-kinesis-kms-key"
  }
}

resource "aws_kms_alias" "key_alias" {

  name          = "alias/${var.APP}-${var.COMPONENT}-${var.AWS_REGION}-kinesis-kms-key"
  target_key_id = aws_kms_key.key.key_id
}

resource "aws_kinesis_stream" "kinesis" {

  name             = "${var.APP}-${var.COMPONENT}-${var.AWS_REGION}-kinesis-stream"
  shard_count      = var.SHARDS
  retention_period = 24
  encryption_type = "KMS"
  kms_key_id = aws_kms_key.key.arn
  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  tags = {
    Industry = "GFS"
    Program = "AppRotation"
    Application = var.APP
    Component   = var.COMPONENT
    Environment = var.ENV
  }
}

resource "aws_ssm_parameter" "dynamodb_param" {

  name  = "/approtation/${var.APP}/${var.COMPONENT}/kinesis"
  type  = "SecureString"
  value = aws_kinesis_stream.kinesis.name
}
