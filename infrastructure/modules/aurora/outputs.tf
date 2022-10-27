// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "cluster_arn" {

  description = "The ARN of the cluster"
  value       = aws_rds_global_cluster.global-cluster.arn
}

output "primary_cluster_arn" {

  description = "The ARN of the primary cluster"
  value       = aws_rds_cluster.primary.arn
}

output "secondary_cluster_arn" {

  description = "The ARN of the secondary cluster"
  value       = aws_rds_cluster.secondary.arn
}

output "primary_cluster_endpoint" {

  description = "The endpoint of primary cluster"
  value       = aws_rds_cluster.primary.endpoint
}

output "secondary_cluster_endpoint" {

  description = "The endpoint of secondary cluster"
  value       = aws_rds_cluster.secondary.endpoint
}