// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "vpc_id" {

  description = "The vpc id"
  value       = module.approtation-vpc.vpc_id
}

output "public_subnets" {

  description = "The public subnet ids"
  value       = module.approtation-vpc.public_subnets
}

output "private_subnets" {

  description = "The private subnet ids"
  value       = module.approtation-vpc.private_subnets
}

output "elb_security_group_id" {

  description = "The ELB security grouop ids"
  value       = aws_security_group.elb-sg.id
}

output "ecs_security_group_id" {

  description = "The ECS security grouop ids"
  value       = aws_security_group.ecs-sg.id
}
