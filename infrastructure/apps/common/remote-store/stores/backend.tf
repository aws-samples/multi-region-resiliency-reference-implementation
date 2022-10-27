// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

terraform {

  backend "s3" {

    bucket = "app-rotation-common-terraform-store-awsd1"
    key    = "terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
