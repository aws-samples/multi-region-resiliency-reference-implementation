// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "dynamodb_trade_arn" {

  description = "The arn of dynamodb trade table"
  value       = length(module.dynamodb-trade) > 0 ? module.dynamodb-trade[0].dynamodb_table_arn : ""
}

output "dynamodb_settlement_arn" {

  description = "The arn of dynamodb settlement table"
  value       = length(module.dynamodb-settlement) > 0 ? module.dynamodb-settlement[0].dynamodb_table_arn : ""
}



