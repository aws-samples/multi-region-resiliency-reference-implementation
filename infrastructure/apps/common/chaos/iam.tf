// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_iam_role" "fis_exec" {

  name = "team-fis-role"
//  permissions_boundary = "arn:aws:iam::aws:policy/PowerUserAccess"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "fis.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_policy" "fis_exec_policy" {

  name        = "team-fis-role-policy"
  path        = "/"
  description = "team-fis-role-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action = [
          "fis:*",
          "ec2:*",
          "ecs:*",
          "ssm:*",
          "iam:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy_attachment" {

  role       = aws_iam_role.fis_exec.name
  policy_arn = aws_iam_policy.fis_exec_policy.arn
}