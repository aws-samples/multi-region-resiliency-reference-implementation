// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

data "aws_iam_role" "ecs_task_execution_role" {

  name = "team-app-rotation-ecs-task-execution-role"
}

resource "aws_ecs_cluster" "ecs-cluster" {

  name = "${var.APP}-${var.COMPONENT}-ecs-cluster"

  setting {
   name  = "containerInsights"
   value = "enabled"
  }

  tags = {
    Industry = "GFS"
    Program = "AppRotation"
    Application = var.APP
    Component = var.COMPONENT
    Environment = var.ENV
  }
}

resource "aws_iam_instance_profile" "ecs-ec2-role" {

  name = "team-${var.APP}-${var.COMPONENT}-${var.AWS_REGION}-ecs-ec2-role"
  role = "team-app-rotation-ecs-ec2-role"
}

resource "aws_launch_configuration" "launch-config" {

  name_prefix          = "${var.APP}-${var.COMPONENT}-launch-config"
  image_id             = var.ECS_AMIS[var.AWS_REGION]
  instance_type        = var.ECS_INSTANCE_TYPE
  iam_instance_profile = aws_iam_instance_profile.ecs-ec2-role.id
  security_groups      = [var.ECS_SECURITY_GROUP_ID]
  user_data            = "#!/bin/bash\necho 'ECS_CLUSTER=${var.APP}-${var.COMPONENT}-ecs-cluster' > /etc/ecs/ecs.config\nstart ecs"
  lifecycle {
    create_before_destroy = true
  }
  root_block_device {
    encrypted = true
  }

  #checkov:skip=CKV_AWS_79:Ensure Instance Metadata Service Version 1 is not enabled
}

resource "aws_autoscaling_group" "auto-scaling-group" {

  name                      = "${var.APP}-${var.COMPONENT}-asg"
  vpc_zone_identifier       = var.SUBNET_IDS
  launch_configuration      = aws_launch_configuration.launch-config.name
  min_size                  = var.CONTAINER_COUNT
  max_size                  = 10
  health_check_grace_period = 300
  health_check_type         = "ELB"

  tag {
    key   = "Name"
    value   = "${var.APP}-${var.COMPONENT}-container"
    propagate_at_launch = true
  }

  tag {
    key     = "Industry"
    value   = "GFS"
    propagate_at_launch = true
  }

  tag {
    key     = "Program"
    value   = "AppRotation"
    propagate_at_launch = true
  }

  tag {
    key     = "Application"
    value   = var.APP
    propagate_at_launch = true
  }

  tag {
    key     = "Component"
    value   = var.COMPONENT
    propagate_at_launch = true
  }

  tag {
    key     = "Environment"
    value   = var.ENV
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "autoscaling_policy" {

  name = "${var.APP}-${var.COMPONENT}-asg-policy"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.auto-scaling-group.name}"
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {

  alarm_name = "${var.APP}-${var.COMPONENT}-asg-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "60"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.auto-scaling-group.name}"
  }
}

resource "aws_kms_key" "ecr_key" {

  description = "${var.APP}-${var.COMPONENT}-ecr-kms-key"
  enable_key_rotation = true

  tags = {
    Environment = var.ENV
    Name = "${var.APP}-${var.COMPONENT}-ecr-kms-key"
  }
}

resource "aws_kms_alias" "ecr_key_alias" {

  name          = "alias/${var.APP}-${var.COMPONENT}-ecr-kms-key"
  target_key_id = aws_kms_key.ecr_key.key_id
}

resource "aws_ecr_repository" "approtation" {

  name = "${var.APP}-${var.COMPONENT}-ecr"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
    kms_key = aws_kms_key.ecr_key.arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name          = "${var.APP}-${var.COMPONENT}-ecr"
    Industry      = "GFS"
    Program       = "AppRotation"
    Application   = var.APP
    Component     = var.COMPONENT
    Environment   = var.ENV
  }

  #checkov:skip=CKV_AWS_51:Ensure ECR Image Tags are immutable
}

locals {
  REPOSITORY = replace(aws_ecr_repository.approtation.repository_url, "https://", "")
}

resource "aws_ecs_task_definition" "task-definition" {

  family                   = "${var.APP}-${var.COMPONENT}"
  container_definitions    = <<TASK_DEFINITION
  [
    {
        "image": "${local.REPOSITORY}:latest",
        "cpu": 2048,
        "memory": 4096,
        "name": "${var.APP}-${var.COMPONENT}",
        "portMappings": [
          {
            "containerPort": 8080,
            "hostPort": 8080
          }
        ],
        "environment" : [{"name": "GENERATE_FILES", "value": "\"false\""},
                         {"name": "GENERATE_QUEUE", "value": "\"true\""},
                         {"name": "NUM_OF_TRADES", "value": "100"},
                         {"name": "OUTPUT_DIR", "value": "\"output\""},
                         {"name": "AWS_REGION", "value": "${var.AWS_REGION}"}],
        "logConfiguration" : {
            "logDriver" : "awslogs",
            "options" : {
              "awslogs-group" : "/ecs/${var.APP}-${var.COMPONENT}",
              "awslogs-region" : "${var.AWS_REGION}",
              "awslogs-create-group": "true",
              "awslogs-stream-prefix" : "ecs"
            }
        }
    }
  ]
TASK_DEFINITION
  task_role_arn         = data.aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn    = data.aws_iam_role.ecs_task_execution_role.arn

  tags = {
    Industry      = "GFS"
    Program       = "AppRotation"
    Application   = var.APP
    Component     = var.COMPONENT
    Environment   = var.ENV
  }
}

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket" "log_bucket" {

  bucket = "${var.APP_SHORT}-${var.COMPONENT_SHORT}-${var.AWS_REGION}-ecs-elb-log-bucket-${var.ENV}"

  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
      }
    }
  }

//  logging {
//      target_bucket = "${var.APP == "trade-matching" ? "tm" : "sm"}-${var.COMPONENT == "in-gateway" ? "in" : "out"}-${var.AWS_REGION}-ecs-elb-log-bucket-${var.ENV}-log"
//      target_prefix = "log/${var.APP == "trade-matching" ? "tm" : "sm"}-${var.COMPONENT == "in-gateway" ? "in" : "out"}-${var.AWS_REGION}-ecs-elb-log-bucket-${var.ENV}"
//  }

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.APP_SHORT}-${var.COMPONENT_SHORT}-${var.AWS_REGION}-ecs-elb-log-bucket-${var.ENV}/AWSLogs/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY

  #checkov:skip=CKV_AWS_144:Ensure that S3 bucket has cross-region replication enabled
  #checkov:skip=CKV_AWS_18:Ensure the S3 bucket has access logging enabled
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {

  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

//resource "aws_elb" "aws-elb" {
//
//  name = "${(var.APP == "trade-matching" || var.APP == "trade")? "tm" : "sm"}-${var.COMPONENT}-elb"
////  name = "${var.APP_SHORT}-${var.COMPONENT}-elb"
//
//  listener {
//    instance_port     = 8080
//    instance_protocol = "http"
//    lb_port           = 80
//    lb_protocol       = "http"
//  }
//
//  health_check {
//    healthy_threshold   = 2
//    unhealthy_threshold = 2
//    timeout             = 30
//    target              = "HTTP:8080/"
//    interval            = 60
//  }
//
//  cross_zone_load_balancing   = true
//  idle_timeout                = 400
//  connection_draining         = true
//  connection_draining_timeout = 400
//
//  subnets         = var.SUBNET_IDS
//  security_groups = [var.ELB_SECURITY_GROUP_ID]
//
//  access_logs {
//    bucket  = "${var.APP_SHORT}-${var.COMPONENT_SHORT}-${var.AWS_REGION}-ecs-elb-log-bucket-${var.ENV}"
//    enabled = true
//  }
//
//  tags = {
//    Name = "${(var.APP == "trade-matching" || var.APP == "trade") ? "tm" : "sm"}-${var.COMPONENT}-elb"
////    Name = "${var.APP_SHORT}-${var.COMPONENT}-elb"
//    Industry      = "GFS"
//    Program       = "AppRotation"
//    Application   = var.APP
//    Component     = var.COMPONENT
//    Environment   = var.ENV
//  }
//
//  depends_on = [
//    aws_s3_bucket.log_bucket
//  ]
//  #checkov:skip=CKV_AWS_127:Ensure that Elastic Load Balancer(s) uses SSL certificates provided by AWS Certificate Manager
//}
//
//resource "aws_autoscaling_attachment" "asg_attachment" {
//
//  autoscaling_group_name = aws_autoscaling_group.auto-scaling-group.id
//  elb                    = aws_elb.aws-elb.id
//}

//data "aws_iam_role" "ecs_role" {
//  name = "approtation-ecs-task-execution-role"
//}

resource "aws_ecs_service" "ecs-service" {

  name                  = "${var.APP}-${var.COMPONENT}-service"
  cluster               = aws_ecs_cluster.ecs-cluster.id
  task_definition       = aws_ecs_task_definition.task-definition.arn
  desired_count         = var.TASK_COUNT
  propagate_tags        = "TASK_DEFINITION"
//  iam_role              = aws_iam_role.ecs-service-role.arn
//  depends_on            = [aws_iam_policy_attachment.ecs-service-attach1]

//  load_balancer {
//    elb_name       = aws_elb.aws-elb.name
//    container_name = "${var.APP}-${var.COMPONENT}"
//    container_port = 8080
//  }

  tags = {
    Industry = "GFS"
    Program = "AppRotation"
    Application = var.APP
    Component   = var.COMPONENT
    Environment = var.ENV
  }
}

//module "ecs_param_alb" {
//
//  source    = "../parameter-store"
//
//  NAME      = "/approtation/${var.APP}/${var.COMPONENT}/ecs/alb"
//  TYPE      = "SecureString"
//  VALUE     = aws_elb.aws-elb.dns_name
//}

//resource "aws_ssm_parameter" "ecs_param_alb" {
//
//  name  = "/approtation/${var.APP}/${var.COMPONENT}/ecs/alb"
//  type  = "SecureString"
//  value = aws_elb.aws-elb.dns_name
//  overwrite = true
//}


//module "ecs_param_ecr" {
//
//  source    = "../parameter-store"
//
//  NAME      = "/approtation/${var.APP}/${var.COMPONENT}/ecs/ecr"
//  TYPE      = "SecureString"
//  VALUE     = aws_ecr_repository.approtation.repository_url
//}

resource "aws_ssm_parameter" "ecs_param_ecr" {

  name  = "/approtation/${var.APP}/${var.COMPONENT}/ecs/ecr"
  type  = "SecureString"
  value = aws_ecr_repository.approtation.repository_url
  overwrite = true
}

resource "aws_cloudwatch_metric_alarm" "ecs_task_count" {

  alarm_name                = "${var.APP_SHORT}-${var.COMPONENT}-ecs-task-count"
  actions_enabled           = "true"
  ok_actions                = []
  alarm_actions             = []
  insufficient_data_actions = []
  evaluation_periods        = "1"
  datapoints_to_alarm       = "1"
  comparison_operator       = "LessThanOrEqualToThreshold"
  treat_missing_data        = "breaching"
  threshold                 = "0"
  alarm_description         = "This alarm monitors ecs task count"

  metric_query {
    id            = "m1"
    return_data   = "true"
    metric {
      namespace   = "ECS/ContainerInsights"
      metric_name = "CpuUtilized"
      dimensions  = {
        ClusterName  = "${var.APP}-${var.COMPONENT}-ecs-cluster"
      }
      period      = "60"
      stat        = "SampleCount"
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_ec2_cpu_stress" {

  alarm_name                = "${var.APP_SHORT}-${var.COMPONENT}-ecs-ec2-cpu-stress"
  actions_enabled           = "true"
  ok_actions                = []
  alarm_actions             = []
  insufficient_data_actions = []
  evaluation_periods        = "1"
  datapoints_to_alarm       = "1"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  treat_missing_data        = "breaching"
  threshold                 = "70"
  alarm_description         = "This alarm monitors ECS EC2 CPU stress"

  metric_query {
    id            = "m1"
    return_data   = "true"
    metric {
      namespace   = "AWS/EC2"
      metric_name = "CPUUtilization"
      dimensions  = {
        AutoScalingGroupName  = "${var.APP}-${var.COMPONENT}-asg"
      }
      period      = "60"
      stat        = "Average"
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_ec2_cpu_stop" {

  alarm_name                = "${var.APP_SHORT}-${var.COMPONENT}-ecs-ec2-cpu-stop"
  actions_enabled           = "true"
  ok_actions                = []
  alarm_actions             = []
  insufficient_data_actions = []
  evaluation_periods        = "1"
  datapoints_to_alarm       = "1"
  comparison_operator       = "LessThanThreshold"
  treat_missing_data        = "breaching"
  threshold                 = "1"
  alarm_description         = "This alarm monitors ECS EC2 CPU stop"

  metric_query {
    id            = "m1"
    return_data   = "true"
    metric {
      namespace   = "AWS/EC2"
      metric_name = "CPUUtilization"
      dimensions  = {
        AutoScalingGroupName  = "${var.APP}-${var.COMPONENT}-asg"
      }
      period      = "60"
      stat        = "SampleCount"
    }
  }
}