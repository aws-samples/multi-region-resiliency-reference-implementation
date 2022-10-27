// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "cluster_arn" {

  description = "The ARN of the ecs cluster"
  value       = aws_ecs_cluster.ecs-cluster.arn
}

output "asg_arn" {

  description = "The ARN of the ecs cluster auto scaling group"
  value       = aws_autoscaling_group.auto-scaling-group.arn
}

//output "elb_arn" {
//
//  description = "The ARN of the ecs cluster elastic load balancer"
////  value = aws_elb.aws-elb.arn
//  value = "dummy"
//}
//
//output "elb_dns" {
//
//  description = "The DNS of the ecs cluster elastic load balancer"
////  value = aws_elb.aws-elb.dns_name
//  value = "dummy"
//}



