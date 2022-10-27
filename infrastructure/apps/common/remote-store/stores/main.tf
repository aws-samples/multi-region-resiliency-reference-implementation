// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_kms_key" "bucket-key" {

  description         = "terraform-stores-bucket-key"
  enable_key_rotation = true
}

resource "aws_kms_alias" "bucket-key-alias" {

  name          = "alias/terraform-stores-bucket-key"
  target_key_id = aws_kms_key.bucket-key.key_id
}

module "trade-matching-initialization" {

  source                    = "../template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "trade-matching"
  LOCATION                  = "initialization"
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "trade-matching-global" {

  source                    = "../template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "trade-matching"
  LOCATION                  = "global"
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "trade-matching-primary" {

  source                    = "../template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "trade-matching"
  LOCATION                  = "primary"
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "trade-matching-secondary" {

  source                    = "../template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "trade-matching"
  LOCATION                  = "secondary"
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "settlement-initialization" {

  source                    = "../template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "settlement"
  LOCATION                  = "initialization"
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "settlement-global" {

  source                    = "../template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "settlement"
  LOCATION                  = "global"
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "settlement-primary" {

  source                    = "../template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "settlement"
  LOCATION                  = "primary"
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "settlement-secondary" {

  source                    = "../template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "settlement"
  LOCATION                  = "secondary"
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "common-arc" {

  source                    = "../template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "arc"
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "common-arc-cluster" {

  source                    = "../template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "arc-cluster"
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "common-db-rotation" {

  source                    = "../template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "db-rotation"
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "ecs-role" {

  source                    = "../template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "ecs-role"
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "get-app-state" {

  source                    = "../template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "get-app-state"
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "lambda-layer" {

  source                    = "../template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "lambda-layer"
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "common-mqdns" {

  source                    = "../template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "mqdns"
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "common-mq-replication" {

  source                    = "../template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "mq-replication"
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "common-rotation" {

  source                    = "../template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "rotation"
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "common-vpc-peeting" {

  source                    = "../template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "vpc-peering"
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "common-recon" {

  source                    = "../template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "recon"
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "common-initialization" {

  source                    = "../template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "initialization"
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "common-test" {

  source                    = "../template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "test"
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

# NEW MODULES

module "trade_matching_initialization_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "trade-matching"
  LOCATION                  = "initialization"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "trade_matching_global_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "trade-matching"
  LOCATION                  = "global"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "trade_matching_primary_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "trade-matching"
  LOCATION                  = "primary"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "trade_matching_secondary_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "trade-matching"
  LOCATION                  = "secondary"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "settlement_initialization_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "settlement"
  LOCATION                  = "initialization"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "settlement_global_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "settlement"
  LOCATION                  = "global"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "settlement_primary_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "settlement"
  LOCATION                  = "primary"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "settlement_secondary_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "settlement"
  LOCATION                  = "secondary"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "common_arc_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "arc"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "common_arc_cluster_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "arc-cluster"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "common_db_rotation_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "db-rotation"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "ecs_role_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "ecs-role"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "get_app_state_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "get-app-state"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "dashboard_api_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "dashboard"
  LOCATION                  = "api"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "dashboard_infra_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "dashboard"
  LOCATION                  = "infra"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "lambda_layer_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "lambda-layer"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "common_mqdns_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "mqdns"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "common_mq_replication_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "mq-replication"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "common_rotation_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "rotation"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "common_vpc_peering_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "vpc-peering"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "common_recon_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "recon"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "common_initialization_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "initialization"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "common_test_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "test"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "common_hub_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "hub"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}

module "common_chaos_store" {

  source                    = "./template"

  AWS_REGION                = var.AWS_REGION
  APP                       = "common"
  LOCATION                  = "chaos"
  ENV                       = var.ENV
  KEY_ARN                   = aws_kms_key.bucket-key.arn
}