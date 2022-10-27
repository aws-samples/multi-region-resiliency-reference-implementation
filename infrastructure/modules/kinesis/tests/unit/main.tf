
provider "aws" {
  region = "us-east-1"
}

module "main" {
  source = "../.."
  APP                   = "test"
  COMPONENT             = "comp"
  ENV                   = "dev"
  SHARDS                = 2
}

locals {
  kinesis_id = module.main.stream_id
  kinesis_arn = module.main.stream_arn
  kinesis_name = module.main.stream_name
  shard_count = module.main.shard_count
}