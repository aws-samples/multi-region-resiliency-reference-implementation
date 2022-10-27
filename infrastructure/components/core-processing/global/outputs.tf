// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "database_cluster_arn" {

  description = "The arn of database cluster"
  value       = module.aurora.cluster_arn
}

output "database_primary_cluster_arn" {

  description = "The arn of database primary cluster"
  value       = module.aurora.primary_cluster_arn
}

output "database_secondary_cluster_arn" {

  description = "The arn of database secondary cluster"
  value       = module.aurora.secondary_cluster_arn
}
