// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "amazon_mq_arn" {

  description = "The amazon arn"
  value       = module.amazon-mq.broker_arn
}

output "ecs_cluster_arn" {

  description = "The ecs cluster arn"
  value       = module.ecs.cluster_arn
}

output "ecs_asg_arn" {

  description = "The ecs asg arn"
  value       = module.ecs.asg_arn
}
//
//output "ecs_elb_arn" {
//
//  description = "The ecs elb arn"
//  value       = module.ecs.elb_arn
//}

