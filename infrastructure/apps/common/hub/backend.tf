// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

terraform {

  backend "s3" {

    bucket = "common-hub-awsd1-terraform-store"
    key    = "terraform.tfstate"
    dynamodb_table = "common-hub-awsd1-terraform-store-lock"
    region = "us-east-1"
    encrypt = true
  }
}
