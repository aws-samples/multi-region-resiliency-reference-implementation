// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "dynamodb_table_arn" {

  description = "The arn of the dynamodb table"
  value       = module.dynamodb_table.dynamodb_table_arn
}

output "dynamodb_table_id" {

  description = "The id of the dynamodb table"
  value       = module.dynamodb_table.dynamodb_table_id
}

