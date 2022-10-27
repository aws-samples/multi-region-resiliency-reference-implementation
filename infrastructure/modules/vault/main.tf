// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

data "aws_caller_identity" "current" {}

data "aws_elb_service_account" "main" {}

resource "aws_glacier_vault" "vault" {

  name = var.NAME

  access_policy = <<EOF
{
    "Version":"2012-10-17",
    "Statement":[
       {
          "Sid": "add-read-only-perm",
          "Principal": "${data.aws_elb_service_account.main.arn}",
          "Effect": "Allow",
          "Action": [
             "glacier:InitiateJob",
             "glacier:GetJobOutput"
          ],
          "Resource": "arn:aws:glacier:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:vaults/${var.NAME}"
       }
    ]
}
EOF

  tags = {
    Name = var.NAME
  }
}
