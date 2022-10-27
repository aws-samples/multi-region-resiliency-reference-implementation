// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_iam_role" "app_rotation_ecs_ec2_role" {

  name = "team-app-rotation-ecs-ec2-role"
  permissions_boundary = "arn:aws:iam::aws:policy/PowerUserAccess"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "app_rotation_ecs_ec2_role_policy_attachment" {

  role       = aws_iam_role.app_rotation_ecs_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role" "app_rotation_ecs_task_execution_role" {

  name = "team-app-rotation-ecs-task-execution-role"
//  permissions_boundary = "arn:aws:iam::aws:policy/PowerUserAccess"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

//resource "aws_iam_role_policy" "app_rotation_ecs_task_execution_policy" {
//
//  name = "team-app-rotation-ecs-task-execution-policy"
//  role = aws_iam_role.app_rotation_ecs_task_execution_role.id
//
//  policy = jsonencode({
//    Version = "2012-10-17"
//    Statement = [
//      {
//        Effect   = "Allow"
//        Action = [
//          "cloudwatch:*",
//          "ecs:*",
//          "dynamodb:*",
//          "kinesis:*",
//          "iam:PassRole",
//          "kms:*",
//          "logs:*",
//          "mq:*",
//          "rds:*",
//          "secretsmanager:*",
//          "ssm:*",
//          "route53:*",
//          "route53-recovery-control-config:*",
//          "route53-recovery-cluster:*",
//          "s3:*"
//        ]
//        Resource = "*"
//      }
//    ]
//  })
//}

resource "aws_iam_policy" "app_rotation_ecs_task_execution_policy" {

  name        = "app-rotation-ecs-task-execution-policy"
  path        = "/"
  description = "app-rotation-ecs-task-execution-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action = [
          "cloudwatch:*",
          "ecs:*",
          "dynamodb:*",
          "iam:PassRole",
          "kinesis:*",
          "kms:*",
          "logs:*",
          "mq:*",
          "rds:*",
          "secretsmanager:*",
          "ssm:*",
          "route53:*",
          "route53-recovery-control-config:*",
          "route53-recovery-cluster:*",
          "s3:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app_rotation_ecs_task_execution_role_policy_attachment1" {

  role       = aws_iam_role.app_rotation_ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "app_rotation_ecs_task_execution_role_policy_attachment2" {

  role       = aws_iam_role.app_rotation_ecs_task_execution_role.name
  policy_arn = aws_iam_policy.app_rotation_ecs_task_execution_policy.arn
}


data "aws_caller_identity" "current" {}

resource "aws_iam_role" "app_rotation_automation_role" {

  name = "team-app-rotation-automation-role"
//  permissions_boundary = "arn:aws:iam::aws:policy/PowerUserAccess"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ssm.amazonaws.com"
        ]
      }
    }
  ]
}
EOF

}

//resource "aws_iam_role_policy" "app_rotation_automation_policy" {
//
//  name = "team-app-rotation-automation-policy"
//  role = aws_iam_role.app_rotation_automation_role.id
//
//  policy = jsonencode({
//    Version = "2012-10-17"
//    Statement = [
//      {
//        Effect   = "Allow"
//        Action = [
//          "cloudwatch:*",
//          "ecs:*",
//          "dynamodb:*",
//          "iam:PassRole",
//          "kms:*",
//          "rds:*",
//          "secretsmanager:*",
//          "ssm:*",
//          "route53:*",
//          "route53-recovery-control-config:*",
//          "route53-recovery-cluster:*"
//        ]
//        Resource = "*"
//      }
//    ]
//  })
//}

resource "aws_iam_policy" "app_rotation_automation_policy" {

  name        = "app-rotation-automation-policy"
  path        = "/"
  description = "app-rotation-automation-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action = [
          "cloudwatch:*",
          "ec2:*",
          "ecs:*",
          "dynamodb:*",
          "iam:PassRole",
          "kms:*",
          "rds:*",
          "secretsmanager:*",
          "ssm:*",
          "route53:*",
          "route53-recovery-control-config:*",
          "route53-recovery-cluster:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app_rotation_automation_role_policy_attachment1" {

  role       = aws_iam_role.app_rotation_automation_role.name
  policy_arn = aws_iam_policy.app_rotation_automation_policy.arn
}

