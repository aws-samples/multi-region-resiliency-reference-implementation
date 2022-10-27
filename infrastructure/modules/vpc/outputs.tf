// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "name" {

  description = "The ID of the VPC"
  value       = module.approtation-vpc.name
}

output "vpc_id" {

  description = "The ID of the VPC"
  value       = module.approtation-vpc.vpc_id
}

output "private_subnets" {

  description = "List of IDs of private subnets"
  value       = module.approtation-vpc.private_subnets
}

output "private_subnets_cidr_blocks" {

  description = "List of private subnets cyber blocks"
  value       = module.approtation-vpc.private_subnets_cidr_blocks
}

output "public_subnets" {

  description = "List of IDs of public subnets"
  value       = module.approtation-vpc.public_subnets
}

output "public_subnets_cidr_blocks" {

  description = "List of public subnets cyber blocks"
  value       = module.approtation-vpc.public_subnets_cidr_blocks
}
