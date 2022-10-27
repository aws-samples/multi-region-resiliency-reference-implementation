// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

data "aws_secretsmanager_secret" "mq-secret" {

  name = "${var.APP}-${var.COMPONENT}-mq"
}

data "aws_secretsmanager_secret_version" "mq-secret-version" {

  secret_id = data.aws_secretsmanager_secret.mq-secret.id
}

resource "aws_kms_key" "mq_key" {

  description = "${var.APP}-${var.COMPONENT}-${var.AWS_REGION}-mq-kms_key"
  enable_key_rotation = true
  tags = {
    Terraform   = "true"
    Environment = var.ENV
    Name = "${var.APP}-${var.COMPONENT}-${var.AWS_REGION}-mq-kms_key"
  }
}

resource "aws_mq_broker" "mq_broker" {

  broker_name                 = "${var.APP}-${var.COMPONENT}-${var.AWS_REGION}-mq-broker"
  engine_type                 = var.ENGINE_TYPE
  engine_version              = var.ENGINE_VERSION
  host_instance_type          = var.MQ_INSTANCE_TYPE
  subnet_ids                  = var.SUBNET_IDS
  deployment_mode             = "ACTIVE_STANDBY_MULTI_AZ"
  storage_type                = "efs"
  security_groups             = [var.MQ_SECURITY_GROUP_ID]
  apply_immediately           = true
  auto_minor_version_upgrade  = true

  encryption_options {
    kms_key_id = aws_kms_key.mq_key.arn
    use_aws_owned_key = false
  }

  user {
    username = "mqadmin"
    password = data.aws_secretsmanager_secret_version.mq-secret-version.secret_string
    console_access = true
  }

  logs {
    audit = true
    general = true
  }

  tags = {
    Industry = "GFS"
    Program = "AppRotation"
    Application = var.APP
    Component   = var.COMPONENT
    Environment = var.ENV
  }
}

locals  {
  MQCredentials = {

    username = "mqadmin"
    password = data.aws_secretsmanager_secret_version.mq-secret-version.secret_string
    endpoint = "failover:${aws_mq_broker.mq_broker.instances[0].endpoints[0]},${aws_mq_broker.mq_broker.instances[1].endpoints[0]}"
    arn = aws_mq_broker.mq_broker.arn
    id = aws_mq_broker.mq_broker.id
  }
}

module "secret-mq" {

  source                = "../secret"

  NAME                  = "${var.APP}-${var.COMPONENT}-${var.AWS_REGION}-mq"
  VALUE                 = jsonencode(local.MQCredentials)
  AWS_BACKUP_REGION     = var.AWS_BACKUP_REGION
}

resource "aws_lb_target_group" "mq-target-group-1" {

  name        = "${var.APP == "trade-matching" ? "tm" : "sm"}-${var.COMPONENT == "in-gateway" ? "in" : "out"}-${var.AWS_REGION}-mq-1-tg"
//  name        = "${var.APP_SHORT}-${var.COMPONENT_SHORT}-${var.AWS_REGION}-mq-1-tg"
  port        = 61617
  protocol    = "TLS"
  target_type = "ip"
  vpc_id      = var.VPC_ID

  health_check {
    port      = 8162
    protocol  = "TCP"
  }
}

resource "aws_lb_target_group_attachment" "mq-target-group-1-attachment-active" {

  target_group_arn = aws_lb_target_group.mq-target-group-1.arn
  target_id        = aws_mq_broker.mq_broker.instances[0].ip_address
  port             = 61617
}

resource "aws_lb_target_group_attachment" "mq-target-group-1-attachment-standby" {

  target_group_arn = aws_lb_target_group.mq-target-group-1.arn
  target_id        = aws_mq_broker.mq_broker.instances[1].ip_address
  port             = 61617
}

resource "aws_lb_target_group" "mq-target-group-2" {

  name        = "${var.APP == "trade-matching" ? "tm" : "sm"}-${var.COMPONENT == "in-gateway" ? "in" : "out"}-${var.AWS_REGION}-mq-2-tg"
//  name        = "${var.APP_SHORT}-${var.COMPONENT_SHORT}-${var.AWS_REGION}-mq-2-tg"
  port        = 61614
  protocol    = "TLS"
  target_type = "ip"
  vpc_id      = var.VPC_ID

  health_check {
    port      = 8162
    protocol  = "TCP"
  }
}

resource "aws_lb_target_group_attachment" "mq-target-group-2-attachment-active" {

  target_group_arn = aws_lb_target_group.mq-target-group-2.arn
  target_id        = aws_mq_broker.mq_broker.instances[0].ip_address
  port             = 61614
}

resource "aws_lb_target_group_attachment" "mq-target-group-2-attachment-standby" {

  target_group_arn = aws_lb_target_group.mq-target-group-2.arn
  target_id        = aws_mq_broker.mq_broker.instances[1].ip_address
  port             = 61614
}

//module "log-bucket" {
//  source                    = "../bucket"
//
//  AWS_REGION                = var.AWS_REGION
//  AWS_PRIMARY_REGION        = var.AWS_REGION
//  AWS_SECONDARY_REGION      = var.AWS_BACKUP_REGION
//  NAME                      = "${var.APP == "trade-matching" ? "tm" : "sm"}-${var.COMPONENT == "in-gateway" ? "in" : "out"}-${var.AWS_REGION}-mq-nlb-log-bucket"
//  SUFFIX                    = var.ENV
//}

data "aws_elb_service_account" "main" {}
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "log_bucket" {

  bucket = "${var.APP_SHORT}-${var.COMPONENT_SHORT}-${var.AWS_REGION}-mq-nlb-log-bucket-${var.ENV}"

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
//      target_bucket = "${var.APP == "trade-matching" ? "tm" : "sm"}-${var.COMPONENT == "in-gateway" ? "in" : "out"}-${var.AWS_REGION}-mq-nlb-log-bucket-${var.ENV}-log"
//      target_prefix = "log/${var.APP == "trade-matching" ? "tm" : "sm"}-${var.COMPONENT == "in-gateway" ? "in" : "out"}-${var.AWS_REGION}-mq-nlb-log-bucket-${var.ENV}"
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
      "Resource": "arn:aws:s3:::${var.APP_SHORT}-${var.COMPONENT_SHORT}-${var.AWS_REGION}-mq-nlb-log-bucket-${var.ENV}/mq-nlb/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      }
    },
    {
      "Action": [
        "s3:GetBucketAcl"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.APP_SHORT}-${var.COMPONENT_SHORT}-${var.AWS_REGION}-mq-nlb-log-bucket-${var.ENV}",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
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

resource "aws_lb" "mq-nlb" {

  name                              = "${var.APP == "trade-matching" ? "tm" : "sm"}-${var.COMPONENT == "in-gateway" ? "in" : "out"}-${var.AWS_REGION}-mq-nlb"
//  name                              = "${var.APP_SHORT}-${var.COMPONENT_SHORT}-${var.AWS_REGION}-mq-nlb"
  internal                          = true
  load_balancer_type                = "network"
  subnets                           = var.SUBNET_IDS
  enable_cross_zone_load_balancing  = true
  enable_deletion_protection        = true

  access_logs {
    bucket  = "${var.APP == "trade-matching" ? "tm" : "sm"}-${var.COMPONENT == "in-gateway" ? "in" : "out"}-${var.AWS_REGION}-mq-nlb-log-bucket-${var.ENV}"
    prefix  = "mq-nlb"
    enabled = true
  }

//  access_logs {
//    bucket  = "${var.APP_SHORT}-${var.COMPONENT_SHORT}-${var.AWS_REGION}-mq-nlb-log-bucket-${var.ENV}"
//    prefix  = "mq-nlb"
//    enabled = true
// }

  tags = {
    Name = "${var.APP}-${var.COMPONENT}-${var.AWS_REGION}-mq-nlb"
  }

  depends_on = [
    aws_s3_bucket.log_bucket
  ]
}

data "aws_secretsmanager_secret" "ca-secret" {

  name = "${var.APP}-certificate-authority-${var.AWS_REGION}"
}

data "aws_secretsmanager_secret_version" "ca-secret-version" {

  secret_id = data.aws_secretsmanager_secret.ca-secret.id
}

resource "aws_acm_certificate" "nlb-certificate" {

  domain_name       = "mq.approtation.${var.APP}.${var.COMPONENT == "in-gateway" ? "in" : "out"}"
//  domain_name       = "mq.approtation.${var.APP}.${var.COMPONENT_SHORT}"

  certificate_authority_arn = data.aws_secretsmanager_secret_version.ca-secret-version.secret_string

  tags = {
    Name = "approtation-${var.APP}-${var.COMPONENT == "in-gateway" ? "in" : "out"}-${var.AWS_REGION}-certificate"
//    Name = "approtation-${var.APP}-${var.COMPONENT_SHORT}-${var.AWS_REGION}-certificate"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "mq-nlb-listener-1" {

  load_balancer_arn = aws_lb.mq-nlb.arn
  port              = "61617"
  protocol          = "TLS"
  certificate_arn   =  aws_acm_certificate.nlb-certificate.arn
  alpn_policy       = "HTTP2Preferred"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  #checkov:skip=CKV_AWS_103:Ensure that load balancer is using TLS 1.2

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mq-target-group-1.arn
  }
}

resource "aws_lb_listener" "mq-nlb-listener-2" {

  load_balancer_arn = aws_lb.mq-nlb.arn
  port              = "61614"
  protocol          = "TLS"
  certificate_arn   =  aws_acm_certificate.nlb-certificate.arn
  alpn_policy       = "HTTP2Preferred"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  #checkov:skip=CKV_AWS_103:Ensure that load balancer is using TLS 1.2

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mq-target-group-2.arn
  }
}

module "secret-mq-nlb" {

  source                = "../secret"

  NAME                  = "${var.APP}-${var.COMPONENT}-${var.AWS_REGION}-mq-nlb"
  VALUE                 = aws_lb.mq-nlb.dns_name
  AWS_BACKUP_REGION     = var.AWS_BACKUP_REGION
}
