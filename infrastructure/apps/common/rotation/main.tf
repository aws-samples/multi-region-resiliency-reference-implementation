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

data "archive_file" "automation-archive" {

  type = "zip"

  source_dir  = "${path.module}/src"
  output_path = "${path.module}/rotation.zip"
}

resource "aws_s3_bucket" "automation_bucket" {

  bucket = "approtation-rotation-${var.ENV}"

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

  #checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
  #checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {

  bucket = aws_s3_bucket.automation_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "null_resource" "checksum" {

  triggers = {
    policy_sha1 = sha256(filebase64("${path.module}/rotation.zip"))
  }

  provisioner "local-exec" {
    command = "shasum -a 256 rotation.zip | cut -d' ' -f1 > checksum.txt"
  }

  depends_on = [
    data.archive_file.automation-archive
  ]
}

resource "aws_s3_bucket_object" "automation-object" {

  bucket = aws_s3_bucket.automation_bucket.id

  key    = "rotation.zip"
  source = data.archive_file.automation-archive.output_path

  //etag = "${sha1(filebase64("${path.module}/rotation.zip"))}"
  etag = file("${path.module}/checksum.txt")
  //etag = filemd5("${path.module}/checksum.txt")

  depends_on = [
    null_resource.checksum
  ]

  #checkov:skip=CKV_AWS_186: "Ensure S3 bucket Object is encrypted by KMS using a customer managed Key (CMK)"
}

resource "aws_ssm_document" "approtation-Runbook-Managed-Failover-Primary" {

  provider = aws.primary
  name            = "approtation-Runbook-Managed-Failover"
  document_type   = "Automation"
  document_format = "YAML"

  depends_on = [
    aws_s3_bucket_object.automation-object
  ]

  attachments_source {
    key    = "S3FileUrl"
    values = [ "https://approtation-rotation-proto.s3.amazonaws.com/rotation.zip"]
    name   = "rotation.py"
  }

  content = replace(file("${path.module}/managed_failover.yaml"), "<checksum>", file("${path.module}/checksum.txt"))
  //content = replace(file("${path.module}/managed_failover.yaml"), "<checksum>", "${sha1(filebase64("${path.module}/rotation.zip"))}")
}

resource "aws_ssm_document" "approtation-Runbook-Detach-And-Promote-Primary" {

  provider = aws.primary
  name            = "approtation-Runbook-Detach-And-Promote"
  document_type   = "Automation"
  document_format = "YAML"

  depends_on = [
    aws_s3_bucket_object.automation-object
  ]

  attachments_source {
    key    = "S3FileUrl"
    values = [ "https://approtation-rotation-proto.s3.amazonaws.com/rotation.zip"]
    name   = "rotation.py"
  }

  content = replace(file("${path.module}/detach_and_promote.yaml"), "<checksum>", file("${path.module}/checksum.txt"))
  //content = replace(file("${path.module}/detach_and_promote.yaml"), "<checksum>", "${sha1(filebase64("${path.module}/rotation.zip"))}")
  //"${sha1(file("${path.module}/rotation.zip"))}"
}

resource "aws_ssm_document" "approtation-Runbook-Managed-Failover-Secondary" {

  provider = aws.secondary
  name            = "approtation-Runbook-Managed-Failover"
  document_type   = "Automation"
  document_format = "YAML"

  depends_on = [
    aws_s3_bucket_object.automation-object
  ]

  attachments_source {
    key    = "S3FileUrl"
    values = [ "https://approtation-rotation-proto.s3.amazonaws.com/rotation.zip"]
    name   = "rotation.py"
  }

  content = replace(file("${path.module}/managed_failover.yaml"), "<checksum>", file("${path.module}/checksum.txt"))
  //content = replace(file("${path.module}/managed_failover.yaml"), "<checksum>", "${sha1(filebase64("${path.module}/rotation.zip"))}")
}

resource "aws_ssm_document" "approtation-Runbook-Detach-And-Promote-Secondary" {

  provider = aws.secondary
  name            = "approtation-Runbook-Detach-And-Promote"
  document_type   = "Automation"
  document_format = "YAML"

  depends_on = [
    aws_s3_bucket_object.automation-object
  ]

  attachments_source {
    key    = "S3FileUrl"
    values = [ "https://approtation-rotation-proto.s3.amazonaws.com/rotation.zip"]
    name   = "rotation.py"
  }

  content = replace(file("${path.module}/detach_and_promote.yaml"), "<checksum>", file("${path.module}/checksum.txt"))
  //content = replace(file("${path.module}/detach_and_promote.yaml"), "<checksum>", "${sha1(filebase64("${path.module}/rotation.zip"))}")
  //"${sha1(file("${path.module}/rotation.zip"))}"
}

resource "aws_ssm_document" "SC-001-Primary" {

  provider = aws.primary
  name            = "SC-001"
  document_type   = "Automation"
  document_format = "YAML"

  depends_on = [
    aws_s3_bucket_object.automation-object
  ]

  attachments_source {
    key    = "S3FileUrl"
    values = [ "https://approtation-rotation-proto.s3.amazonaws.com/rotation.zip"]
    name   = "rotation.py"
  }

  content = replace(file("${path.module}/sc_001.yaml"), "<checksum>", file("${path.module}/checksum.txt"))
}

resource "aws_ssm_document" "SC-001-Secondary" {

  provider = aws.secondary
  name            = "SC-001"
  document_type   = "Automation"
  document_format = "YAML"

  depends_on = [
    aws_s3_bucket_object.automation-object
  ]

  attachments_source {
    key    = "S3FileUrl"
    values = [ "https://approtation-rotation-proto.s3.amazonaws.com/rotation.zip"]
    name   = "rotation.py"
  }

  content = replace(file("${path.module}/sc_001.yaml"), "<checksum>", file("${path.module}/checksum.txt"))
}

resource "aws_ssm_document" "Scenario-001-Primary" {

  provider = aws.primary
  name            = "Scenario-001"
  document_type   = "Automation"
  document_format = "YAML"

  depends_on = [
    aws_s3_bucket_object.automation-object
  ]

  attachments_source {
    key    = "S3FileUrl"
    values = [ "https://approtation-rotation-proto.s3.amazonaws.com/rotation.zip"]
    name   = "rotation.py"
  }

  content = replace(file("${path.module}/scenario_001.yaml"), "<checksum>", file("${path.module}/checksum.txt"))
}

resource "aws_ssm_document" "Scenario-001-Secondary" {

  provider = aws.secondary
  name            = "Scenario-001"
  document_type   = "Automation"
  document_format = "YAML"

  depends_on = [
    aws_s3_bucket_object.automation-object
  ]

  attachments_source {
    key    = "S3FileUrl"
    values = [ "https://approtation-rotation-proto.s3.amazonaws.com/rotation.zip"]
    name   = "rotation.py"
  }

  content = replace(file("${path.module}/scenario_001.yaml"), "<checksum>", file("${path.module}/checksum.txt"))
}
