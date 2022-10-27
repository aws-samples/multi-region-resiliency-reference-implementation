// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "ecs_cluster_2_arn" {

  description = "The ecs cluster arn"
  value       = module.ecs2.cluster_arn
}

output "ecs_asg_2_arn" {

  description = "The ecs asg arn"
  value       = module.ecs2.asg_arn
}
//
//output "ecs_elb_2_arn" {
//
//  description = "The ecs elb arn"
//  value       = module.ecs2.elb_arn
//}
