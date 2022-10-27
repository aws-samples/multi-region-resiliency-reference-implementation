// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "param_arn" {

  description = "The ARN of the Parameter"
  value       = aws_ssm_parameter.parameter.arn
}

