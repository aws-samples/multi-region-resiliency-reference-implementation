// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "vault_arn" {

  description = "The ARN of the vault"
  value       = aws_backup_vault.backup_vault.arn
}
