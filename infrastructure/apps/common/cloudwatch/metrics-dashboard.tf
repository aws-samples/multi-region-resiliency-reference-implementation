// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# Kinesis
//data "aws_ssm_parameter" "kinesis" {
//  name = "/approtation/trade-matching/ingress-trade/kinesis"
//}

data "aws_kinesis_stream" "ingress_trade" {
  name = "trade-matching-ingress-trade-us-east-1-kinesis-stream"
}

# DDB
data "aws_dynamodb_table" "ingress_trade" {
  name = "trade-matching-ingress-trade-dynamodb-store"
}

resource "aws_cloudwatch_dashboard" "metrics_dashboard" {
  dashboard_name = "Trade-Matching-Metrics-Dashboard"

  dashboard_body = <<EOF
{
    "widgets": [
        {
            "height": 1,
            "width": 24,
            "y": 0,
            "x": 0,
            "type": "text",
            "properties": {
                "markdown": "# Kinesis Data Streams\n"
            }
        },
        {
            "height": 6,
            "width": 8,
            "y": 30,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/Kinesis", "GetRecords.IteratorAgeMilliseconds", "StreamName", "trade-matching-ingress-trade-us-east-1-kinesis-stream", { "stat": "Average" } ]
                ],
                "legend": {
                    "position": "bottom"
                },
                "region": "${var.AWS_REGION}",
                "liveData": false,
                "title": "IteratorAgeMilliseconds - GetRecord",
                "view": "timeSeries",
                "stacked": false,
                "period": 60
            }
        },
        {
            "height": 6,
            "width": 8,
            "y": 30,
            "x": 8,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/Kinesis", "GetRecords.Latency", "StreamName", "trade-matching-ingress-trade-us-east-1-kinesis-stream", { "stat": "Average" } ]
                ],
                "legend": {
                    "position": "bottom"
                },
                "region": "${var.AWS_REGION}",
                "liveData": false,
                "title": "Latency - GetRecords",
                "view": "timeSeries",
                "stacked": false,
                "period": 60
            }
        },
        {
            "height": 5,
            "width": 8,
            "y": 36,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/Kinesis", "IteratorAgeMilliseconds", "ShardId", "${tolist(data.aws_kinesis_stream.ingress_trade.open_shards)[0]}", "StreamName", "trade-matching-ingress-trade-us-east-1-kinesis-stream" ]
                ],
                "_comment": "change shardId generated by terraform output file in above line or at console directly",
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.AWS_REGION}",
                "title": "IteratorAgeMilliseconds - ShardLevel",
                "period": 60,
                "stat": "Average"
            }
        },
        {
            "height": 1,
            "width": 24,
            "y": 41,
            "x": 0,
            "type": "text",
            "properties": {
                "markdown": "# DynamoDB\n"
            }
        },
        {
            "height": 6,
            "width": 12,
            "y": 42,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/DynamoDB", "ReplicationLatency", "TableName", "trade-matching-ingress-trade-dynamodb-store", "ReceivingRegion", "${var.AWS_SECONDARY_REGION}" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.AWS_REGION}",
                "period": 60,
                "stat": "Average"
            }
        },
        {
            "height": 6,
            "width": 8,
            "y": 30,
            "x": 16,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/Kinesis", "PutRecord.Latency", "StreamName", "trade-matching-ingress-trade-us-east-1-kinesis-stream" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.AWS_REGION}",
                "period": 60,
                "stat": "Average",
                "title": "Latency - PutRecord"
            }
        },
        {
            "height": 5,
            "width": 16,
            "y": 36,
            "x": 8,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/Kinesis", "ReadProvisionedThroughputExceeded", "StreamName", "trade-matching-ingress-trade-us-east-1-kinesis-stream" ],
                    [ ".", "WriteProvisionedThroughputExceeded", ".", "." ]
                ],
                "sparkline": true,
                "view": "singleValue",
                "region": "${var.AWS_REGION}",
                "period": 60,
                "stat": "Sum",
                "title": "ProvisionedThroughputExceeded"
            }
        },
        {
            "height": 6,
            "width": 12,
            "y": 42,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/DynamoDB", "UserErrors" ],
                    [ ".", "SystemErrors", "Operation", "GetRecords" ]
                ],
                "sparkline": true,
                "view": "singleValue",
                "region": "${var.AWS_REGION}",
                "stat": "Sum",
                "period": 60,
                "title": "Errors"
            }
        },
        {
            "height": 7,
            "width": 24,
            "y": 48,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/DynamoDB", "SuccessfulRequestLatency", "TableName", "trade-matching-ingress-trade-dynamodb-store", "StreamLabel", "${data.aws_dynamodb_table.ingress_trade.stream_label}", "Operation", "GetRecords", { "visible": false } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.AWS_REGION}",
                "stat": "Average",
                "period": 60,
                "title": "SuccessfulRequestLatency - GetRecords"
            }
        },
        {
            "height": 6,
            "width": 8,
            "y": 55,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/DynamoDB", "SuccessfulRequestLatency", "TableName", "trade-matching-ingress-trade-dynamodb-store", "Operation", "GetItem" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.AWS_REGION}",
                "stat": "Average",
                "period": 60,
                "title": "SuccessfulRequestLatency - GetItem"
            }
        },
        {
            "height": 6,
            "width": 8,
            "y": 55,
            "x": 8,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/DynamoDB", "SuccessfulRequestLatency", "TableName", "trade-matching-ingress-trade-dynamodb-store", "Operation", "PutItem" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.AWS_REGION}",
                "stat": "Average",
                "period": 60,
                "title": "SuccessfulRequestLatency - PuItem"
            }
        },
        {
            "height": 6,
            "width": 8,
            "y": 55,
            "x": 16,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/DynamoDB", "SuccessfulRequestLatency", "TableName", "trade-matching-ingress-trade-dynamodb-store", "Operation", "UpdateItem", { "id": "m1" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.AWS_REGION}",
                "stat": "Average",
                "period": 60,
                "title": "SuccessfulRequestLatency - UpdateItem"
            }
        }
    ]
}
EOF
}


