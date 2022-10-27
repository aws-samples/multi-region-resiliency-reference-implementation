// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "tm_stop_kinesis_access" {

  source        = "./template5"

  NAME          = "tm-stop-kinesis-access"
  REGION        = "us-east-1"
  APP           = "trade-matching"
  SERVICE       = "kinesis-streams"
  STOP          = "tm-in-gateway-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

