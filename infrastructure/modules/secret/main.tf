// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

data "aws_kms_key" "secret-manager-secret-key" {

  key_id = "alias/secret-manager-secret-key"
}

data "aws_caller_identity" "current" {}

resource "aws_secretsmanager_secret" "secret" {

  name = var.NAME
  kms_key_id = data.aws_kms_key.secret-manager-secret-key.key_id
  replica {
    region = var.AWS_BACKUP_REGION
  }
  recovery_window_in_days = 0
  force_overwrite_replica_secret = true

//  policy = <<POLICY
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Effect": "Allow",
//      "Principal": {
//        "AWS": ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/app-rotation-ecs-task-execution-role",
//                "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/app-rotation-automation-role"]
//      },
//      "Action": "secretsmanager:GetSecretValue",
//      "Resource": "*"
//    }
//  ]
//}
//POLICY
}

resource "aws_secretsmanager_secret_version" "secret-version" {

  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = var.VALUE
}
