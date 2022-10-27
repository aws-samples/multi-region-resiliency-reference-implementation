
provider "aws" {
  region = "us-east-1"
}

module "main" {
  source = "../.."
  APP                   = "test"
  COMPONENT             = "comp"
  ENV                   = "dev"
  AWS_PRIMARY_REGION    = "us-east-1"
  AWS_SECONDARY_REGION  = "us-east-2"
}

locals {
  dynamodb_table_id = module.main.dynamodb_table_id
  dynamodb_table_arn = module.main.dynamodb_table_arn
}