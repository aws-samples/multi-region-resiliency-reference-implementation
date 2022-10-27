// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

data "aws_secretsmanager_secret" "trade-matching-global-secret" {

  name = "trade-matching-global-arc"
}

data "aws_secretsmanager_secret_version" "trade-matching-global-secret-version" {

  secret_id = data.aws_secretsmanager_secret.trade-matching-global-secret.id
}

data "aws_secretsmanager_secret" "trade-matching-primary-secret" {

  name = "trade-matching-${var.AWS_PRIMARY_REGION}-arc"
}

data "aws_secretsmanager_secret_version" "trade-matching-primary-secret-version" {

  secret_id = data.aws_secretsmanager_secret.trade-matching-primary-secret.id
}

data "aws_secretsmanager_secret" "trade-matching-secondary-secret" {

  name = "trade-matching-${var.AWS_SECONDARY_REGION}-arc"
}

data "aws_secretsmanager_secret_version" "trade-matching-secondary-secret-version" {

  secret_id = data.aws_secretsmanager_secret.trade-matching-secondary-secret.id
}

resource "aws_route53recoveryreadiness_recovery_group" "trade-matching-group" {

  recovery_group_name = "trade-matching"
  cells = [data.aws_secretsmanager_secret_version.trade-matching-global-secret-version.secret_string, data.aws_secretsmanager_secret_version.trade-matching-primary-secret-version.secret_string, data.aws_secretsmanager_secret_version.trade-matching-secondary-secret-version.secret_string]
}

data "aws_secretsmanager_secret" "settlement-global-secret" {

  name = "settlement-global-arc"
}

data "aws_secretsmanager_secret_version" "settlement-global-secret-version" {

  secret_id = data.aws_secretsmanager_secret.settlement-global-secret.id
}

data "aws_secretsmanager_secret" "settlement-primary-secret" {

  name = "settlement-${var.AWS_PRIMARY_REGION}-arc"
}

data "aws_secretsmanager_secret_version" "settlement-primary-secret-version" {

  secret_id = data.aws_secretsmanager_secret.settlement-primary-secret.id
}

data "aws_secretsmanager_secret" "settlement-secondary-secret" {

  name = "settlement-${var.AWS_SECONDARY_REGION}-arc"
}

data "aws_secretsmanager_secret_version" "settlement-secondary-secret-version" {

  secret_id = data.aws_secretsmanager_secret.settlement-secondary-secret.id
}

resource "aws_route53recoveryreadiness_recovery_group" "settlement-group" {

  recovery_group_name = "settlement"
  cells = [data.aws_secretsmanager_secret_version.settlement-global-secret-version.secret_string, data.aws_secretsmanager_secret_version.settlement-primary-secret-version.secret_string, data.aws_secretsmanager_secret_version.settlement-secondary-secret-version.secret_string]
}

