// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

provider "aws" {

  alias   = "target"
  region  = var.AWS_REGION
}

resource "aws_kms_key" "backup_key" {

  provider = aws.target

  description         = "${var.NAME}-backup-key"
  enable_key_rotation = true
}

resource "aws_backup_vault" "backup_vault" {

  provider = aws.target

  name        = "${var.NAME}-backup-vault"
  kms_key_arn = aws_kms_key.backup_key.arn
}

resource "aws_backup_plan" "backup_plan" {

  provider = aws.target

  name = "${var.NAME}-backup-plan"

  rule {
    rule_name         = "backup_rule"
    target_vault_name = "${var.NAME}-backup-vault"
    schedule          = "cron(0 12 * * ? *)"
  }

  depends_on = [
    aws_backup_vault.backup_vault
  ]
}

resource "aws_backup_selection" "backup_selection" {

  provider = aws.target

  name          = "${var.NAME}-backup-selection"
  iam_role_arn  = aws_iam_role.backup_iam.arn
  plan_id       = aws_backup_plan.backup_plan.id

  resources = [
    var.RESOURCE_ARN
  ]
}
