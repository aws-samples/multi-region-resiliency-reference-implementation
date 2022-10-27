// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "broker_arn" {

  description = "The ARN of the broker"
  value       = aws_mq_broker.mq_broker.arn
}

output "broker_instances" {

  description = "The instances of the broker"
  value       = aws_mq_broker.mq_broker.instances
}

output "broker_endpoints" {

  description = "The endpoints of the broker"
  value       = aws_mq_broker.mq_broker.instances[0].endpoints
}
