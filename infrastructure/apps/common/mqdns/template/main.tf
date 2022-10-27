// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

provider "aws" {

  alias  = "secondary"
  region = var.AWS_SECONDARY_REGION
}

data "aws_secretsmanager_secret" "app-primary-vpc-secret" {

  name = "${var.APP}-${var.AWS_PRIMARY_REGION}-vpc"
}

data "aws_secretsmanager_secret_version" "app-primary-vpc-secret-version" {

  secret_id = data.aws_secretsmanager_secret.app-primary-vpc-secret.id
}

data "aws_secretsmanager_secret" "app-secondary-vpc-secret" {

  name = "${var.APP}-${var.AWS_SECONDARY_REGION}-vpc"
}

data "aws_secretsmanager_secret_version" "app-secondary-vpc-secret-version" {

  secret_id = data.aws_secretsmanager_secret.app-secondary-vpc-secret.id
}

data "aws_secretsmanager_secret" "peer-app-primary-vpc-secret" {

  name = "${var.PEER_APP}-${var.AWS_PRIMARY_REGION}-vpc"
}

data "aws_secretsmanager_secret_version" "peer-app-primary-vpc-secret-version" {

  secret_id = data.aws_secretsmanager_secret.peer-app-primary-vpc-secret.id
}

data "aws_secretsmanager_secret" "peer-app-secondary-vpc-secret" {

  name = "${var.PEER_APP}-${var.AWS_SECONDARY_REGION}-vpc"
}

data "aws_secretsmanager_secret_version" "peer-app-secondary-vpc-secret-version" {

  secret_id = data.aws_secretsmanager_secret.peer-app-secondary-vpc-secret.id
}

data "aws_secretsmanager_secret" "app-primary-health-check-secret" {

  name = "${var.APP}-${var.AWS_PRIMARY_REGION}-arc-health-check"
}

data "aws_secretsmanager_secret_version" "app-primary-health-check-secret-version" {

  secret_id = data.aws_secretsmanager_secret.app-primary-health-check-secret.id
}

data "aws_secretsmanager_secret" "app-secondary-health-check-secret" {

  name = "${var.APP}-${var.AWS_SECONDARY_REGION}-arc-health-check"
}

data "aws_secretsmanager_secret_version" "app-secondary-health-check-secret-version" {

  secret_id = data.aws_secretsmanager_secret.app-secondary-health-check-secret.id
}

data "aws_secretsmanager_secret" "app-component-primary-mq-secret" {

  name = "${var.APP}-${var.COMPONENT}-${var.AWS_PRIMARY_REGION}-mq"
}

data "aws_secretsmanager_secret_version" "app-component-primary-mq-secret-version" {

  secret_id = data.aws_secretsmanager_secret.app-component-primary-mq-secret.id
}

data "aws_secretsmanager_secret" "app-component-primary-mq-nlb-secret" {

  name = "${var.APP}-${var.COMPONENT}-${var.AWS_PRIMARY_REGION}-mq-nlb"
}

data "aws_secretsmanager_secret_version" "app-component-primary-mq-nlb-secret-version" {

  secret_id = data.aws_secretsmanager_secret.app-component-primary-mq-nlb-secret.id
}

data "aws_secretsmanager_secret" "app-component-secondary-mq-secret" {

  name = "${var.APP}-${var.COMPONENT}-${var.AWS_SECONDARY_REGION}-mq"
}

data "aws_secretsmanager_secret_version" "app-component-secondary-mq-secret-version" {

  secret_id = data.aws_secretsmanager_secret.app-component-secondary-mq-secret.id
}

data "aws_secretsmanager_secret" "app-component-secondary-mq-nlb-secret" {

  name = "${var.APP}-${var.COMPONENT}-${var.AWS_SECONDARY_REGION}-mq-nlb"
}

data "aws_secretsmanager_secret_version" "app-component-secondary-mq-nlb-secret-version" {

  secret_id = data.aws_secretsmanager_secret.app-component-secondary-mq-nlb-secret.id
}

resource "aws_route53_zone" "trade-matching-component-private-zone" {

  name = "approtation.${var.APP}.${var.COMPONENT_SHORT}"
  comment = "approtation.${var.APP}.${var.COMPONENT_SHORT}"

  vpc {
    vpc_id = data.aws_secretsmanager_secret_version.app-primary-vpc-secret-version.secret_string
    vpc_region = var.AWS_PRIMARY_REGION
  }
}

resource "aws_route53_record" "trade-matching-component-primary-record" {

  zone_id = aws_route53_zone.trade-matching-component-private-zone.zone_id
  name    = "mq.approtation.${var.APP}.${var.COMPONENT_SHORT}"
  type    = "CNAME"
  ttl     = "5"

  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier = "${var.APP}-${var.COMPONENT_SHORT}-primary"
  health_check_id = data.aws_secretsmanager_secret_version.app-primary-health-check-secret-version.secret_string
  records        = [data.aws_secretsmanager_secret_version.app-component-primary-mq-nlb-secret-version.secret_string]
  //records        = [replace(replace(jsondecode(data.aws_secretsmanager_secret_version.app-component-primary-mq-secret-version.secret_string)["endpoint"], "ssl://", ""), ":61617", "")]
}

resource "aws_route53_record" "trade-matching-component-secondary-record" {

  zone_id = aws_route53_zone.trade-matching-component-private-zone.zone_id
  name    = "mq.approtation.${var.APP}.${var.COMPONENT_SHORT}"
  type    = "CNAME"
  ttl     = "5"

  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier = "${var.APP}-${var.COMPONENT_SHORT}-secondary"
  health_check_id = data.aws_secretsmanager_secret_version.app-secondary-health-check-secret-version.secret_string
  records        = [data.aws_secretsmanager_secret_version.app-component-secondary-mq-nlb-secret-version.secret_string]
  //records        = [replace(replace(jsondecode(data.aws_secretsmanager_secret_version.app-component-secondary-mq-secret-version.secret_string)["endpoint"], "ssl://", ""), ":61617", "")]
}

//resource "aws_route53_vpc_association_authorization" "app-component-secondary-association-authorization" {
//  vpc_id  = data.aws_secretsmanager_secret_version.app-secondary-vpc-secret-version.secret_string
//  zone_id = aws_route53_zone.trade-matching-component-private-zone.zone_id
//}

//resource "aws_route53_vpc_association_authorization" "peer-app-component-primary-association-authorization" {
//  vpc_id  = data.aws_secretsmanager_secret_version.peer-app-primary-vpc-secret-version.secret_string
//  zone_id = aws_route53_zone.trade-matching-component-private-zone.zone_id
//}
//
//resource "aws_route53_vpc_association_authorization" "peer-app-component-secondary-association-authorization" {
//  vpc_id  = data.aws_secretsmanager_secret_version.peer-app-secondary-vpc-secret-version.secret_string
//  zone_id = aws_route53_zone.trade-matching-component-private-zone.zone_id
//}

resource "aws_route53_zone_association" "app-component-secondary-association" {

  provider = aws.secondary

  vpc_id  = data.aws_secretsmanager_secret_version.app-secondary-vpc-secret-version.secret_string
  zone_id = aws_route53_zone.trade-matching-component-private-zone.zone_id
}

resource "aws_route53_zone_association" "peer-app-component-primary-association" {


  vpc_id  = data.aws_secretsmanager_secret_version.peer-app-primary-vpc-secret-version.secret_string
  zone_id = aws_route53_zone.trade-matching-component-private-zone.zone_id
}

resource "aws_route53_zone_association" "peer-app-component-secondary-association" {

  provider = aws.secondary

  vpc_id  = data.aws_secretsmanager_secret_version.peer-app-secondary-vpc-secret-version.secret_string
  zone_id = aws_route53_zone.trade-matching-component-private-zone.zone_id
}

locals  {
  MQCredentials1 = {
    username = jsondecode(data.aws_secretsmanager_secret_version.app-component-secondary-mq-secret-version.secret_string)["username"]
    password = jsondecode(data.aws_secretsmanager_secret_version.app-component-secondary-mq-secret-version.secret_string)["password"]
    endpoint = "ssl://mq.approtation.${var.APP}.${var.COMPONENT_SHORT}:61617"
  }
}

module "app-in-gateway-mq-connection-secret" {

  source                = "../../../../modules/secret"

  NAME                  = "${var.APP}-${var.COMPONENT}-mq-connection"
  VALUE                 = jsonencode(local.MQCredentials1)
  AWS_BACKUP_REGION     = var.AWS_SECONDARY_REGION
}

