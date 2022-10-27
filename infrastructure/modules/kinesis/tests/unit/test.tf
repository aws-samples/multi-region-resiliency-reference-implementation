
terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }

    http = {
      source = "hashicorp/http"
    }
  }
}

resource "test_assertions" "test_kinesis" {

  component = "test_kinesis"

  check "kinesis_arn" {
    description = "Verify kinesis arn"
    condition   = (regex("test-comp-kinesis-stream$", local.kinesis_arn) != "")
  }

  equal "shard_count" {
    description = "Verify number of shards"
    got         = local.shard_count
    want        = 2
  }
}

