

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

resource "test_assertions" "test_dynamodb" {

  component = "test_dynamodb"

  check "dynamodb_table_arn" {
    description = "Verify dynamodb table arn"
    condition   = (regex("test-comp-store$", local.dynamodb_table_arn) != "")
  }
}

