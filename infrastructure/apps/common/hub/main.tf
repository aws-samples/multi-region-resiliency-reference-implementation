// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

provider "aws" {

  alias = "primary"
  region = var.AWS_PRIMARY_REGION
}

provider "aws" {

  alias  = "secondary"
  region = var.AWS_SECONDARY_REGION
}

resource "aws_resourcegroups_group" "trade_matching_primary" {

  provider = aws.primary

  name = "TradeMatching"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [ "AWS::RDS::DBCluster", "AWS::RDS::DBInstance", "AWS::DynamoDB::Table", "AWS::AmazonMQ::Broker", "AWS::ECS::Service", "AWS::Kinesis::Stream", "AWS::ECS::Cluster", "AWS::ECR::Repository", "AWS::ECS::TaskDefinition", "AWS::ElasticLoadBalancingV2::LoadBalancer"],
  "TagFilters": [
    {
      "Key": "Application",
      "Values": ["trade-matching"]
    }
  ]
}
JSON
  }
}

resource "aws_resourcegroups_group" "trade_matching_secondary" {

  provider = aws.secondary

  name = "TradeMatching"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [ "AWS::RDS::DBCluster", "AWS::RDS::DBInstance", "AWS::DynamoDB::Table", "AWS::AmazonMQ::Broker", "AWS::ECS::Service", "AWS::Kinesis::Stream", "AWS::ECS::Cluster", "AWS::ECR::Repository", "AWS::ECS::TaskDefinition", "AWS::ElasticLoadBalancingV2::LoadBalancer"],
  "TagFilters": [
    {
      "Key": "Application",
      "Values": ["trade-matching"]
    }
  ]
}
JSON
  }
}

resource "aws_resourcegroups_group" "settlement_primary" {

  provider = aws.primary

  name = "Settlement"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [ "AWS::RDS::DBCluster", "AWS::RDS::DBInstance", "AWS::DynamoDB::Table", "AWS::AmazonMQ::Broker", "AWS::ECS::Service", "AWS::Kinesis::Stream", "AWS::ECS::Cluster", "AWS::ECR::Repository", "AWS::ECS::TaskDefinition", "AWS::ElasticLoadBalancingV2::LoadBalancer"],
  "TagFilters": [
    {
      "Key": "Application",
      "Values": ["settlement"]
    }
  ]
}
JSON
  }
}

resource "aws_resourcegroups_group" "settlement_secondary" {

  provider = aws.secondary

  name = "Settlement"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [ "AWS::RDS::DBCluster", "AWS::RDS::DBInstance", "AWS::DynamoDB::Table", "AWS::AmazonMQ::Broker", "AWS::ECS::Service", "AWS::Kinesis::Stream", "AWS::ECS::Cluster", "AWS::ECR::Repository", "AWS::ECS::TaskDefinition", "AWS::ElasticLoadBalancingV2::LoadBalancer"],
  "TagFilters": [
    {
      "Key": "Application",
      "Values": ["settlement"]
    }
  ]
}
JSON
  }
}