// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "arn" {

  description = "The arn of the vault"
  value       = aws_glacier_vault.vault.arn
}

