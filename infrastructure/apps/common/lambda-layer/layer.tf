// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_lambda_layer_version" "lambda_layer" {

  filename   = "psycopg2.zip"
  layer_name = "psycopg2"

  compatible_runtimes = ["python3.8"]
}
