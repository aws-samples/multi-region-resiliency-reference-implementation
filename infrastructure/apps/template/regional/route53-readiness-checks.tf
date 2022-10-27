// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

// inbound-gateway
resource "aws_route53recoveryreadiness_cell" "inbound-gateway-cell" {

  cell_name = "${var.APP}-${var.AWS_REGION}-inbound-gateway"
}

resource "aws_route53recoveryreadiness_resource_set" "inbound-gateway-resource-set-asg" {

  resource_set_name = "${var.APP}-${var.AWS_REGION}-inbound-gateway-asg"
  resource_set_type = "AWS::AutoScaling::AutoScalingGroup"

  resources {
    resource_arn = module.inbound-gateway.ecs_asg_arn
    readiness_scopes = [aws_route53recoveryreadiness_cell.inbound-gateway-cell.arn]
  }
}

resource "aws_route53recoveryreadiness_readiness_check" "inbound-gateway-readiness-check-asg" {

  readiness_check_name = "${var.APP}-${var.AWS_REGION}-inbound-gateway-asg"
  resource_set_name    = aws_route53recoveryreadiness_resource_set.inbound-gateway-resource-set-asg.resource_set_name
}

//resource "aws_route53recoveryreadiness_resource_set" "inbound-gateway-resource-set-elb" {
//  resource_set_name = "${var.APP}-${var.AWS_REGION}-inbound-gateway-elb"
//  resource_set_type = "AWS::ElasticLoadBalancing::LoadBalancer"
//
//  resources {
//    resource_arn = module.inbound-gateway.ecs_elb_arn
//    readiness_scopes = [aws_route53recoveryreadiness_cell.regional-cell.arn]
//  }
//}
//
//resource "aws_route53recoveryreadiness_readiness_check" "inbound-gateway-readiness-check-elb" {
//  readiness_check_name = "${var.APP}-${var.AWS_REGION}-inbound-gateway-elb"
//  resource_set_name    = aws_route53recoveryreadiness_resource_set.inbound-gateway-resource-set-elb.resource_set_name
//}

// ingress
resource "aws_route53recoveryreadiness_cell" "ingress-cell" {

  cell_name = "${var.APP}-${var.AWS_REGION}-ingress"
}

resource "aws_route53recoveryreadiness_resource_set" "ingress-resource-set-asg" {

  resource_set_name = "${var.APP}-${var.AWS_REGION}-ingress-asg"
  resource_set_type = "AWS::AutoScaling::AutoScalingGroup"

  resources {
    resource_arn = module.ingress.ecs_asg_arn
    readiness_scopes = [aws_route53recoveryreadiness_cell.ingress-cell.arn]
  }
}

resource "aws_route53recoveryreadiness_readiness_check" "ingress-readiness-check-asg" {

  readiness_check_name = "${var.APP}-${var.AWS_REGION}-ingress-asg"
  resource_set_name    = aws_route53recoveryreadiness_resource_set.ingress-resource-set-asg.resource_set_name
}

//resource "aws_route53recoveryreadiness_resource_set" "ingress-resource-set-elb" {
//  resource_set_name = "${var.APP}-${var.AWS_REGION}-ingress-elb"
//  resource_set_type = "AWS::ElasticLoadBalancing::LoadBalancer"
//
//  resources {
//    resource_arn = module.ingress.ecs_elb_arn
//    readiness_scopes = [aws_route53recoveryreadiness_cell.regional-cell.arn]
//  }
//}
//
//resource "aws_route53recoveryreadiness_readiness_check" "ingress-readiness-check-elb" {
//  readiness_check_name = "${var.APP}-${var.AWS_REGION}-ingress-elb"
//  resource_set_name    = aws_route53recoveryreadiness_resource_set.ingress-resource-set-elb.resource_set_name
//}

// core processing
resource "aws_route53recoveryreadiness_cell" "core-cell" {

  cell_name = "${var.APP}-${var.AWS_REGION}-core"
}

resource "aws_route53recoveryreadiness_resource_set" "core-resource-set-asg-2" {

  resource_set_name = "${var.APP}-${var.AWS_REGION}-core-asg-2"
  resource_set_type = "AWS::AutoScaling::AutoScalingGroup"

  resources {
    resource_arn = module.core-processing.ecs_asg_2_arn
    readiness_scopes = [aws_route53recoveryreadiness_cell.core-cell.arn]
  }
}

resource "aws_route53recoveryreadiness_readiness_check" "core-readiness-check-asg-2" {

  readiness_check_name = "${var.APP}-${var.AWS_REGION}-core-asg-2"
  resource_set_name    = aws_route53recoveryreadiness_resource_set.core-resource-set-asg-2.resource_set_name
}

//resource "aws_route53recoveryreadiness_resource_set" "core-resource-set-elb" {
//  resource_set_name = "${var.APP}-${var.AWS_REGION}-core-elb"
//  resource_set_type = "AWS::ElasticLoadBalancing::LoadBalancer"
//
//  resources {
//    resource_arn = module.core-processing.ecs_elb_arn
//    readiness_scopes = [aws_route53recoveryreadiness_cell.regional-cell.arn]
//  }
//}
//
//resource "aws_route53recoveryreadiness_readiness_check" "core-readiness-check-elb" {
//  readiness_check_name = "${var.APP}-${var.AWS_REGION}-core-elb"
//  resource_set_name    = aws_route53recoveryreadiness_resource_set.core-resource-set-elb.resource_set_name
//}

// egress
resource "aws_route53recoveryreadiness_cell" "egress-cell" {

  cell_name = "${var.APP}-${var.AWS_REGION}-egress"
}

resource "aws_route53recoveryreadiness_resource_set" "egress-resource-set-asg" {

  resource_set_name = "${var.APP}-${var.AWS_REGION}-egress-asg"
  resource_set_type = "AWS::AutoScaling::AutoScalingGroup"

  resources {
    resource_arn = module.egress.ecs_asg_arn
    readiness_scopes = [aws_route53recoveryreadiness_cell.egress-cell.arn]
  }
}

resource "aws_route53recoveryreadiness_readiness_check" "egress-readiness-check-asg" {

  readiness_check_name = "${var.APP}-${var.AWS_REGION}-egress-asg"
  resource_set_name    = aws_route53recoveryreadiness_resource_set.egress-resource-set-asg.resource_set_name
}

//resource "aws_route53recoveryreadiness_resource_set" "egress-resource-set-elb" {
//  resource_set_name = "${var.APP}-${var.AWS_REGION}-egress-elb"
//  resource_set_type = "AWS::ElasticLoadBalancing::LoadBalancer"
//
//  resources {
//    resource_arn = module.egress.ecs_elb_arn
//    readiness_scopes = [aws_route53recoveryreadiness_cell.regional-cell.arn]
//  }
//}
//
//resource "aws_route53recoveryreadiness_readiness_check" "egress-readiness-check-elb" {
//  readiness_check_name = "${var.APP}-${var.AWS_REGION}-egress-elb"
//  resource_set_name    = aws_route53recoveryreadiness_resource_set.egress-resource-set-elb.resource_set_name
//}

// outbound-gateway
resource "aws_route53recoveryreadiness_cell" "outbound-gateway-cell" {

  cell_name = "${var.APP}-${var.AWS_REGION}-outbound-gateway"
}

resource "aws_route53recoveryreadiness_resource_set" "outbound-gateway-resource-set-asg" {

  resource_set_name = "${var.APP}-${var.AWS_REGION}-outbound-gateway-asg"
  resource_set_type = "AWS::AutoScaling::AutoScalingGroup"

  resources {
    resource_arn = module.outbound-gateway.ecs_asg_arn
    readiness_scopes = [aws_route53recoveryreadiness_cell.outbound-gateway-cell.arn]
  }
}

resource "aws_route53recoveryreadiness_readiness_check" "outbound-gateway-readiness-check-asg" {

  readiness_check_name = "${var.APP}-${var.AWS_REGION}-outbound-gateway-asg"
  resource_set_name    = aws_route53recoveryreadiness_resource_set.outbound-gateway-resource-set-asg.resource_set_name
}

//resource "aws_route53recoveryreadiness_resource_set" "outbound-gateway-resource-set-elb" {
//  resource_set_name = "${var.APP}-${var.AWS_REGION}-outbound-gateway-elb"
//  resource_set_type = "AWS::ElasticLoadBalancing::LoadBalancer"
//
//  resources {
//    resource_arn = module.outbound-gateway.ecs_elb_arn
//    readiness_scopes = [aws_route53recoveryreadiness_cell.regional-cell.arn]
//  }
//}
//
//resource "aws_route53recoveryreadiness_readiness_check" "outbound-gateway-readiness-check-elb" {
//  readiness_check_name = "${var.APP}-${var.AWS_REGION}-outbound-gateway-elb"
//  resource_set_name    = aws_route53recoveryreadiness_resource_set.outbound-gateway-resource-set-elb.resource_set_name
//}

// global-cell
resource "aws_route53recoveryreadiness_cell" "regional-cell" {

  cell_name = "${var.APP}-${var.AWS_REGION}"
  cells = [aws_route53recoveryreadiness_cell.inbound-gateway-cell.arn, aws_route53recoveryreadiness_cell.ingress-cell.arn, aws_route53recoveryreadiness_cell.core-cell.arn, aws_route53recoveryreadiness_cell.egress-cell.arn, aws_route53recoveryreadiness_cell.outbound-gateway-cell.arn]
}

module "secret" {

  source                = "../../../modules/secret"

  NAME                  = "${var.APP}-${var.AWS_REGION}-arc"
  VALUE                 = aws_route53recoveryreadiness_cell.regional-cell.arn
  AWS_BACKUP_REGION     = var.AWS_BACKUP_REGION
}

