// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_iam_role" "lambda_exec" {

  name = "team-dashboard-lambda-role"
//  permissions_boundary = "arn:aws:iam::aws:policy/PowerUserAccess"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_exec_policy" {

  name        = "team-dashboard-lambda-policy"
  path        = "/"
  description = "team-dashboard-lambda-policy"

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
          "health:*",
          "iam:PassRole",
          "iam:CreateServiceLinkedRole",
          "kms:*",
          "lambda:*",
          "logs:*",
          "rds:*",
          "secretsmanager:*",
          "ssm:*",
          "route53:*",
          "route53-recovery-control-config:*",
          "route53-recovery-cluster:*",
          "route53-recovery-readiness:*",
          "fis:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy_attachment" {

  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
}

resource "aws_iam_role" "api_exec" {

  name = "team-dashboard-api-role"
  permissions_boundary = "arn:aws:iam::aws:policy/PowerUserAccess"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_exec_policy_attachment_1" {

  role       = aws_iam_role.api_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}

resource "aws_iam_role_policy_attachment" "api_exec_policy_attachment_2" {

  role       = aws_iam_role.api_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

resource "aws_iam_role" "api_cloudwatch" {

  name = "team-dashboard-cloudwatch-role"
  permissions_boundary = "arn:aws:iam::aws:policy/PowerUserAccess"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": ["apigateway.amazonaws.com","lambda.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "api_cloudwatch_policy" {

  name = "team-dashboard-cloudwatch-policy"
  role = aws_iam_role.api_cloudwatch.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}