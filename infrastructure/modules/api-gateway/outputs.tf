// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "lambda_function_arn" {

  description = "The ARN of the lambda function"
  value       = aws_api_gateway_rest_api.api.arn
}

output "api_gateway_arn" {

  description = "The ARN of the api gateway"
  value       =aws_lambda_function.function.arn
}


