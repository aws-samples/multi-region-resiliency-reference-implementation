// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "bucket_name" {

  description = "Name of the S3 bucket used to store function code."
  value = aws_s3_bucket.automation_bucket.id
}

output "bucket_arn" {

  description = "Arn of the S3 bucket used to store function code."
  value = aws_s3_bucket.automation_bucket.arn
}
