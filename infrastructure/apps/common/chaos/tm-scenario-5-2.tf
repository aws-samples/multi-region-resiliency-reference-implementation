// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "tm_stop_dynamodb_access" {

  source        = "./template5"

  NAME          = "tm-stop-dynamodb-access"
  REGION        = "us-east-1"
  APP           = "trade-matching"
  SERVICE       = "dynamodb"
  STOP          = "tm-in-gateway-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

