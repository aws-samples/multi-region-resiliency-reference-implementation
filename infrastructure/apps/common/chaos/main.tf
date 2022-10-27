// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

data "archive_file" "automation-archive" {

  type = "zip"

  source_dir  = "${path.module}/src"
  output_path = "${path.module}/chaos.zip"
}

resource "aws_s3_bucket" "automation_bucket" {

  bucket = "approtation-chaos-${var.ENV}"

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
    policy_sha1 = sha256(filebase64("${path.module}/chaos.zip"))
  }

  provisioner "local-exec" {
    command = "shasum -a 256 chaos.zip | cut -d' ' -f1 > checksum.txt"
  }

  depends_on = [
    data.archive_file.automation-archive
  ]
}

resource "aws_s3_bucket_object" "automation-object" {

  bucket = aws_s3_bucket.automation_bucket.id

  key    = "chaos.zip"
  source = data.archive_file.automation-archive.output_path

  //etag = "${sha1(filebase64("${path.module}/rotation.zip"))}"
  etag = file("${path.module}/checksum.txt")
  //etag = filemd5("${path.module}/checksum.txt")

  depends_on = [
    null_resource.checksum
  ]

  #checkov:skip=CKV_AWS_186: "Ensure S3 bucket Object is encrypted by KMS using a customer managed Key (CMK)"
}

resource "aws_ssm_document" "Disable-VPC-Endpoint" {

  name            = "Disable-VPC-Endpoint"
  document_type   = "Automation"
  document_format = "YAML"

  depends_on = [
    aws_s3_bucket_object.automation-object
  ]

  attachments_source {
    key    = "S3FileUrl"
    values = [ "https://approtation-chaos-${var.ENV}.s3.amazonaws.com/chaos.zip"]
    name   = "chaos.py"
  }

  content = replace(file("${path.module}/disable_vpc_endpoint.yaml"), "<checksum>", file("${path.module}/checksum.txt"))
  //content = replace(file("${path.module}/managed_failover.yaml"), "<checksum>", "${sha1(filebase64("${path.module}/rotation.zip"))}")
}

resource "aws_ssm_document" "Enable-VPC-Endpoint" {

  name            = "Enable-VPC-Endpoint"
  document_type   = "Automation"
  document_format = "YAML"

  depends_on = [
    aws_s3_bucket_object.automation-object
  ]

  attachments_source {
    key    = "S3FileUrl"
    values = [ "https://approtation-chaos-${var.ENV}.s3.amazonaws.com/chaos.zip"]
    name   = "chaos.py"
  }

  content = replace(file("${path.module}/enable_vpc_endpoint.yaml"), "<checksum>", file("${path.module}/checksum.txt"))
  //content = replace(file("${path.module}/managed_failover.yaml"), "<checksum>", "${sha1(filebase64("${path.module}/rotation.zip"))}")
}

