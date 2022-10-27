// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "key_id" {

  description = "The ID of the Key"
  value       = aws_kms_key.key.id
}

output "key_arn" {

  description = "The ARN of the Key"
  value       = aws_kms_key.key.arn
}
