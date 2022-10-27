// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "stream_id" {

  description = "The id of the kinesis stream"
  value       = aws_kinesis_stream.kinesis.id
}

output "stream_arn" {

  description = "The arn of the kinesis stream"
  value       = aws_kinesis_stream.kinesis.arn
}

output "stream_name" {

  description = "The name of the kinesis stream"
  value       = aws_kinesis_stream.kinesis.name
}

output "shard_count" {

  description = "The number of shards in the kinesis stream"
  value       = aws_kinesis_stream.kinesis.shard_count
}
