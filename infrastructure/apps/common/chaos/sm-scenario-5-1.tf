// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

module "sm_stop_kinesis_access" {

  source        = "./template5"

  NAME          = "sm-stop-kinesis-access"
  REGION        = "us-east-1"
  APP           = "settlement"
  SERVICE       = "kinesis-streams"
  STOP          = "sm-in-gateway-ecs-ec2-cpu-stop"
  ROLE          = "team-fis-role"
}

