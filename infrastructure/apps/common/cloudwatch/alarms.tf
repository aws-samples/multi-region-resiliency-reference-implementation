// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# creating alarms for API gateway
//resource "aws_cloudwatch_metric_alarm" "tm_in_gateway_ecs_task_count" {
//  alarm_name                = "tm-in-gateway-ecs-task-count"
//  actions_enabled           = "true"
//  ok_actions                = []
//  alarm_actions             = []
//  insufficient_data_actions = []
//  evaluation_periods        = "1"
//  datapoints_to_alarm       = "1"
//  comparison_operator       = "LessThanOrEqualToThreshold"
//  treat_missing_data        = "breaching"
//  threshold                 = "0"
//  alarm_description         = "This alarm monitors ecs task count"
//
//  metric_query {
//    id            = "e1"
//    label         = "Task Count"
//    expression    = "m1"
//    return_data   = "true"
//  }
//  metric_query {
//    id            = "m1"
//    metric {
//      metric_name = "CPUUtilization"
//      namespace   = "AWS/ECS"
//      dimensions  = {
//        ClusterName  = "trade-matching-in-gateway-ecs-cluster"
//      }
//      period      = "60"
//      stat        = "SampleCount"
//    }
//  }
//}

//resource "aws_cloudwatch_metric_alarm" "tm_ingress_ecs_task_count" {
//  alarm_name                = "tm-ingress-ecs-task-count"
//  actions_enabled           = "true"
//  ok_actions                = []
//  alarm_actions             = []
//  insufficient_data_actions = []
//  evaluation_periods        = "1"
//  datapoints_to_alarm       = "1"
//  comparison_operator       = "LessThanOrEqualToThreshold"
//  treat_missing_data        = "breaching"
//  threshold                 = "0"
//  alarm_description         = "This alarm monitors ecs task count"
//
//  metric_query {
//    id            = "e1"
//    label         = "Task Count"
//    expression    = "m1"
//    return_data   = "true"
//  }
//  metric_query {
//    id            = "m1"
//    metric {
//      metric_name = "CPUUtilization"
//      namespace   = "AWS/ECS"
//      dimensions  = {
//        ClusterName  = "trade-matching-ingress-ecs-cluster"
//      }
//      period      = "60"
//      stat        = "SampleCount"
//    }
//  }
//}

resource "aws_cloudwatch_metric_alarm" "trade-matching-ingress-trade-kinesis" {
  alarm_name                = "tm-ingress-trade-mbl"
  actions_enabled           = "true"
  ok_actions                = []
  alarm_actions             = []
  insufficient_data_actions = []
  evaluation_periods        = "3"
  datapoints_to_alarm       = "3"
  comparison_operator       = "GreaterThanUpperThreshold"
  treat_missing_data        = "notBreaching"
  threshold_metric_id       = "ad1"
  alarm_description         = "This alarm monitors how long it is behind the latest"

  metric_query {
    id            = "m1"
    return_data   = "true"
    metric {
      metric_name = "MillisBehindLatest"
      namespace   = "AWS/Kinesis"
      dimensions  = {
        StreamName  = "trade-matching-ingress-trade-us-east-1-kinesis-stream"
      }
      period      = "60"
      stat        = "Average"
    }
  }
  metric_query {
    id            = "ad1"
    label         = "MillisBehindLatest"
    return_data   = "true"
    expression    = "ANOMALY_DETECTION_BAND(m1, 0.5)"
  }
}

resource "aws_cloudwatch_metric_alarm" "trade-matching-ingress-settlement-kinesis" {
  alarm_name                = "tm-ingress-settlement-mbl"
  actions_enabled           = "true"
  ok_actions                = []
  alarm_actions             = []
  insufficient_data_actions = []
  evaluation_periods        = "3"
  datapoints_to_alarm       = "3"
  comparison_operator       = "GreaterThanUpperThreshold"
  treat_missing_data        = "notBreaching"
  threshold_metric_id       = "ad1"
  alarm_description         = "This alarm monitors how long it is behind the latest"

  metric_query {
    id            = "m1"
    return_data   = "true"
    metric {
      metric_name = "MillisBehindLatest"
      namespace   = "AWS/Kinesis"
      dimensions  = {
        StreamName  = "trade-matching-ingress-settlement-us-east-1-kinesis-stream"
      }
      period      = "60"
      stat        = "Average"
    }
  }
  metric_query {
    id            = "ad1"
    label         = "MillisBehindLatest"
    return_data   = "true"
    expression    = "ANOMALY_DETECTION_BAND(m1, 0.5)"
  }
}

//resource "aws_cloudwatch_metric_alarm" "tm_core_ingestion_ecs_task_count" {
//  alarm_name                = "tm-core-ingestion-ecs-task-count"
//  actions_enabled           = "true"
//  ok_actions                = []
//  alarm_actions             = []
//  insufficient_data_actions = []
//  evaluation_periods        = "1"
//  datapoints_to_alarm       = "1"
//  comparison_operator       = "LessThanOrEqualToThreshold"
//  treat_missing_data        = "breaching"
//  threshold                 = "0"
//  alarm_description         = "This alarm monitors ecs task count"
//
//  metric_query {
//    id            = "e1"
//    label         = "Task Count"
//    expression    = "m1"
//    return_data   = "true"
//  }
//  metric_query {
//    id            = "m1"
//    metric {
//      metric_name = "CPUUtilization"
//      namespace   = "AWS/ECS"
//      dimensions  = {
//        ClusterName  = "trade-matching-core-ingestion-ecs-cluster"
//      }
//      period      = "60"
//      stat        = "SampleCount"
//    }
//  }
//}

//resource "aws_cloudwatch_metric_alarm" "tm_core_matching_ecs_task_count" {
//  alarm_name                = "tm-core-matching-ecs-task-count"
//  actions_enabled           = "true"
//  ok_actions                = []
//  alarm_actions             = []
//  insufficient_data_actions = []
//  evaluation_periods        = "1"
//  datapoints_to_alarm       = "1"
//  comparison_operator       = "LessThanOrEqualToThreshold"
//  treat_missing_data        = "breaching"
//  threshold                 = "0"
//  alarm_description         = "This alarm monitors ecs task count"
//
//  metric_query {
//    id            = "e1"
//    label         = "Task Count"
//    expression    = "m1"
//    return_data   = "true"
//  }
//  metric_query {
//    id            = "m1"
//    metric {
//      metric_name = "CPUUtilization"
//      namespace   = "AWS/ECS"
//      dimensions  = {
//        ClusterName  = "trade-matching-core-matching-ecs-cluster"
//      }
//      period      = "60"
//      stat        = "SampleCount"
//    }
//  }
//}

resource "aws_cloudwatch_metric_alarm" "trade-matching-core-trade-kinesis" {
  alarm_name                = "tm-core-trade-mbl"
  actions_enabled           = "true"
  ok_actions                = []
  alarm_actions             = []
  insufficient_data_actions = []
  evaluation_periods        = "3"
  datapoints_to_alarm       = "3"
  comparison_operator       = "GreaterThanUpperThreshold"
  treat_missing_data        = "notBreaching"
  threshold_metric_id       = "ad1"
  alarm_description         = "This alarm monitors how long it is behind the latest"

  metric_query {
    id            = "m1"
    return_data   = "true"
    metric {
      metric_name = "MillisBehindLatest"
      namespace   = "AWS/Kinesis"
      dimensions  = {
        StreamName  = "trade-matching-core-trade-us-east-1-kinesis-stream"
      }
      period      = "60"
      stat        = "Average"
    }
  }
  metric_query {
    id            = "ad1"
    label         = "MillisBehindLatest"
    return_data   = "true"
    expression    = "ANOMALY_DETECTION_BAND(m1, 0.5)"
  }
}

resource "aws_cloudwatch_metric_alarm" "trade-matching-core-settlement-kinesis" {
  alarm_name                = "tm-core-settlement-mbl"
  actions_enabled           = "true"
  ok_actions                = []
  alarm_actions             = []
  insufficient_data_actions = []
  evaluation_periods        = "3"
  datapoints_to_alarm       = "3"
  comparison_operator       = "GreaterThanUpperThreshold"
  treat_missing_data        = "notBreaching"
  threshold_metric_id       = "ad1"
  alarm_description         = "This alarm monitors how long it is behind the latest"

  metric_query {
    id            = "m1"
    return_data   = "true"
    metric {
      metric_name = "MillisBehindLatest"
      namespace   = "AWS/Kinesis"
      dimensions  = {
        StreamName  = "trade-matching-core-settlement-us-east-1-kinesis-stream"
      }
      period      = "60"
      stat        = "Average"
    }
  }
  metric_query {
    id            = "ad1"
    label         = "MillisBehindLatest"
    return_data   = "true"
    expression    = "ANOMALY_DETECTION_BAND(m1, 0.5)"
  }
}

//resource "aws_cloudwatch_metric_alarm" "tm_egress_ecs_task_count" {
//  alarm_name                = "tm-egress-ecs-task-count"
//  actions_enabled           = "true"
//  ok_actions                = []
//  alarm_actions             = []
//  insufficient_data_actions = []
//  evaluation_periods        = "1"
//  datapoints_to_alarm       = "1"
//  comparison_operator       = "LessThanOrEqualToThreshold"
//  treat_missing_data        = "breaching"
//  threshold                 = "0"
//  alarm_description         = "This alarm monitors ecs task count"
//
//  metric_query {
//    id            = "e1"
//    label         = "Task Count"
//    expression    = "m1"
//    return_data   = "true"
//  }
//  metric_query {
//    id            = "m1"
//    metric {
//      metric_name = "CPUUtilization"
//      namespace   = "AWS/ECS"
//      dimensions  = {
//        ClusterName  = "trade-matching-egress-ecs-cluster"
//      }
//      period      = "60"
//      stat        = "SampleCount"
//    }
//  }
//}

# creating alarms for API gateway
resource "aws_cloudwatch_metric_alarm" "trade-matching-egress-trade-kinesis" {
  alarm_name                = "tm-egress-trade-mbl"
  actions_enabled           = "true"
  ok_actions                = []
  alarm_actions             = []
  insufficient_data_actions = []
  evaluation_periods        = "3"
  datapoints_to_alarm       = "3"
  comparison_operator       = "GreaterThanUpperThreshold"
  treat_missing_data        = "notBreaching"
  threshold_metric_id       = "ad1"
  alarm_description         = "This alarm monitors how long it is behind the latest"

  metric_query {
    id            = "m1"
    return_data   = "true"
    metric {
      metric_name = "MillisBehindLatest"
      namespace   = "AWS/Kinesis"
      dimensions  = {
        StreamName  = "trade-matching-egress-trade-us-east-1-kinesis-stream"
      }
      period      = "60"
      stat        = "Average"
    }
  }
  metric_query {
    id            = "ad1"
    label         = "MillisBehindLatest"
    return_data   = "true"
    expression    = "ANOMALY_DETECTION_BAND(m1, 0.5)"
  }
}

resource "aws_cloudwatch_metric_alarm" "trade-matching-egress-settlement-kinesis" {
  alarm_name                = "tm-egress-settlement-mbl"
  actions_enabled           = "true"
  ok_actions                = []
  alarm_actions             = []
  insufficient_data_actions = []
  evaluation_periods        = "3"
  datapoints_to_alarm       = "3"
  comparison_operator       = "GreaterThanUpperThreshold"
  treat_missing_data        = "notBreaching"
  threshold_metric_id       = "ad1"
  alarm_description         = "This alarm monitors how long it is behind the latest"

  metric_query {
    id            = "m1"
    return_data   = "true"
    metric {
      metric_name = "MillisBehindLatest"
      namespace   = "AWS/Kinesis"
      dimensions  = {
        StreamName  = "trade-matching-egress-settlement-us-east-1-kinesis-stream"
      }
      period      = "60"
      stat        = "Average"
    }
  }
  metric_query {
    id            = "ad1"
    label         = "MillisBehindLatest"
    return_data   = "true"
    expression    = "ANOMALY_DETECTION_BAND(m1, 0.5)"
  }
}

//resource "aws_cloudwatch_metric_alarm" "tm_out_gateway_ecs_task_count" {
//  alarm_name                = "tm-out-gateway-ecs-task-count"
//  actions_enabled           = "true"
//  ok_actions                = []
//  alarm_actions             = []
//  insufficient_data_actions = []
//  evaluation_periods        = "1"
//  datapoints_to_alarm       = "1"
//  comparison_operator       = "LessThanOrEqualToThreshold"
//  treat_missing_data        = "breaching"
//  threshold                 = "0"
//  alarm_description         = "This alarm monitors ecs task count"
//
//  metric_query {
//    id            = "e1"
//    label         = "Task Count"
//    expression    = "m1"
//    return_data   = "true"
//  }
//  metric_query {
//    id            = "m1"
//    metric {
//      metric_name = "CPUUtilization"
//      namespace   = "AWS/ECS"
//      dimensions  = {
//        ClusterName  = "trade-matching-out-gateway-ecs-cluster"
//      }
//      period      = "60"
//      stat        = "SampleCount"
//    }
//  }
//}

# creating alarms for API gateway
resource "aws_cloudwatch_metric_alarm" "trade-matching-out-gateway-trade-kinesis" {
  alarm_name                = "tm-out-gateway-trade-mbl"
  actions_enabled           = "true"
  ok_actions                = []
  alarm_actions             = []
  insufficient_data_actions = []
  evaluation_periods        = "3"
  datapoints_to_alarm       = "3"
  comparison_operator       = "GreaterThanUpperThreshold"
  treat_missing_data        = "notBreaching"
  threshold_metric_id       = "ad1"
  alarm_description         = "This alarm monitors how long it is behind the latest"

  metric_query {
    id            = "m1"
    return_data   = "true"
    metric {
      metric_name = "MillisBehindLatest"
      namespace   = "AWS/Kinesis"
      dimensions  = {
        StreamName  = "trade-matching-out-gateway-trade-us-east-1-kinesis-stream"
      }
      period      = "60"
      stat        = "Average"
    }
  }
  metric_query {
    id            = "ad1"
    label         = "MillisBehindLatest"
    return_data   = "true"
    expression    = "ANOMALY_DETECTION_BAND(m1, 0.5)"
  }
}

resource "aws_cloudwatch_metric_alarm" "trade-matching-out-gateway-settlement-kinesis" {
  alarm_name                = "tm-out-gateway-settlement-mbl"
  actions_enabled           = "true"
  ok_actions                = []
  alarm_actions             = []
  insufficient_data_actions = []
  evaluation_periods        = "3"
  datapoints_to_alarm       = "3"
  comparison_operator       = "GreaterThanUpperThreshold"
  treat_missing_data        = "notBreaching"
  threshold_metric_id       = "ad1"
  alarm_description         = "This alarm monitors how long it is behind the latest"

  metric_query {
    id            = "m1"
    return_data   = "true"
    metric {
      metric_name = "MillisBehindLatest"
      namespace   = "AWS/Kinesis"
      dimensions  = {
        StreamName  = "trade-matching-out-gateway-settlement-us-east-1-kinesis-stream"
      }
      period      = "60"
      stat        = "Average"
    }
  }
  metric_query {
    id            = "ad1"
    label         = "MillisBehindLatest"
    return_data   = "true"
    expression    = "ANOMALY_DETECTION_BAND(m1, 0.5)"
  }
}

resource "aws_cloudwatch_metric_alarm" "trade-matching-ingress-trade-dynamo" {
  alarm_name                = "tm-ingress-trade-rl"
  actions_enabled           = "true"
  ok_actions                = []
  alarm_actions             = []
  insufficient_data_actions = []
  evaluation_periods        = "3"
  datapoints_to_alarm       = "3"
  comparison_operator       = "GreaterThanUpperThreshold"
  treat_missing_data        = "notBreaching"
  threshold_metric_id       = "ad1"
  alarm_description         = "This alarm monitors replication latency for dynamo db"

  metric_query {
    id            = "m1"
    return_data   = "true"
    metric {
      metric_name = "ReplicationLatency"
      namespace   = "AWS/DynamoDB"
      dimensions  = {
        TableName  = "trade-matching-ingress-trade-us-east-1-kinesis-stream"
      }
      period      = "60"
      stat        = "Average"
    }
  }
  metric_query {
    id            = "ad1"
    label         = "MillisBehindLatest"
    return_data   = "true"
    expression    = "ANOMALY_DETECTION_BAND(m1, 0.5)"
  }
}