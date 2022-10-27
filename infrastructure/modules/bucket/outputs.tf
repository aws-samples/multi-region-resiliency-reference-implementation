// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "arn" {

  description = "The arn of the bucket"
  value       = module.s3_bucket.s3_bucket_arn
}

