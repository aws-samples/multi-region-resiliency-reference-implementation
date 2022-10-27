// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_cloudwatch_dashboard" "alarms_dashboard" {
  dashboard_name = "Trade-Matching-Alarms-Dashboard"

  dashboard_body = <<EOF
{
    "widgets": [
        {
            "x": 0,
            "y": 0,
            "width": 24,
            "height": 1,
            "type": "text",
            "properties": {
                "markdown": "# Kinesis Data Streams - Milis Behind Latest\n"
            }
        },
        {
            "x": 0,
            "y": 1,
            "width": 6,
            "height": 2,
            "type": "alarm",
            "properties": {
                "alarms": [
                    "arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alarm:tm-ingress-trade-mbl"
                ],
                "title": "TM Ingress Trade - Milis Behind Latest"
            }
        },
        {
            "x": 6,
            "y": 1,
            "width": 6,
            "height": 2,
            "type": "alarm",
            "properties": {
                "alarms": [
                    "arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alarm:tm-ingress-settlement-mbl"
                ],
                "title": "TM Ingress Settlement - Milis Behind Latest"
            }
        },
        {
            "x": 12,
            "y": 3,
            "width": 6,
            "height": 2,
            "type": "alarm",
            "properties": {
                "alarms": [
                    "arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alarm:tm-core-trade-mbl"
                ],
                "title": "TM Core Trade - Milis Behind Latest"
            }
        },
        {
            "x": 18,
            "y": 3,
            "width": 6,
            "height": 2,
            "type": "alarm",
            "properties": {
                "alarms": [
                    "arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alarm:tm-core-settlement-mbl"
                ],
                "title": "TM Core Settlement - Milis Behind Latest"
            }
        },
        {
            "x": 0,
            "y": 3,
            "width": 6,
            "height": 2,
            "type": "alarm",
            "properties": {
                "alarms": [
                    "arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alarm:tm-egress-trade-mbl"
                ],
                "title": "TM Egress Trade - Milis Behind Latest"
            }
        },
        {
            "x": 6,
            "y": 3,
            "width": 6,
            "height": 2,
            "type": "alarm",
            "properties": {
                "alarms": [
                    "arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alarm:tm-egress-settlement-mbl"
                ],
                "title": "TM Egress Settlement - Milis Behind Latest"
            }
        },
        {
            "x": 12,
            "y": 3,
            "width": 6,
            "height": 2,
            "type": "alarm",
            "properties": {
                "alarms": [
                    "arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alarm:tm-out-gateway-trade-mbl"
                ],
                "title": "TM Egress Trade - Milis Behind Latest"
            }
        },
        {
            "x": 18,
            "y": 3,
            "width": 6,
            "height": 2,
            "type": "alarm",
            "properties": {
                "alarms": [
                    "arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alarm:tm-out-gateway-settlement-mbl"
                ],
                "title": "TM Egress Settlement - Milis Behind Latest"
            }
        }
    ]
}
EOF
}
