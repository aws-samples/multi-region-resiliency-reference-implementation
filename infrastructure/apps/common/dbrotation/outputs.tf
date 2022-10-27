// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "lambda_bucket_name" {

  description = "Name of the S3 bucket used to store function code."

  value = aws_s3_bucket.lambda_bucket.id
}

output "function_name" {

  description = "Name of the Lambda function."

  value = aws_lambda_function.dbrotation.function_name
}
