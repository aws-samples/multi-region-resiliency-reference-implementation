// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

provider "aws" {

  alias  = "primary-provider"
  region = var.AWS_PRIMARY_REGION
}

data "aws_partition" "current" {}

resource "aws_acmpca_certificate_authority" "root-ca" {

  provider          = aws.primary-provider
  type = "ROOT"

  certificate_authority_configuration {
    key_algorithm     = var.KEY_ALGORITHM
    signing_algorithm = var.SIGNING_ALGORITHM

    subject {
      common_name     = var.DOMAIN
    }
  }

  permanent_deletion_time_in_days = 7

  tags = {
      Name = var.DOMAIN
  }
}

resource "aws_acmpca_certificate" "root-certificate" {

  provider          = aws.primary-provider
  certificate_authority_arn   = aws_acmpca_certificate_authority.root-ca.arn
  certificate_signing_request = aws_acmpca_certificate_authority.root-ca.certificate_signing_request
  signing_algorithm           = var.SIGNING_ALGORITHM

  template_arn = "arn:${data.aws_partition.current.partition}:acm-pca:::template/RootCACertificate/V1"

  validity {
    type  = "YEARS"
    value = var.VALIDITY
  }
}

resource "aws_acmpca_certificate_authority_certificate" "root-ca-certificate" {

  provider          = aws.primary-provider
  certificate_authority_arn = aws_acmpca_certificate_authority.root-ca.arn

  certificate       = aws_acmpca_certificate.root-certificate.certificate
  certificate_chain = aws_acmpca_certificate.root-certificate.certificate_chain
}

resource "aws_acmpca_certificate_authority" "subordinate-ca" {

  provider          = aws.primary-provider
  type = "SUBORDINATE"

  certificate_authority_configuration {
    key_algorithm     = var.KEY_ALGORITHM
    signing_algorithm = var.SIGNING_ALGORITHM

    subject {
      common_name = "sub.${var.DOMAIN}"
    }
  }
}

resource "aws_acmpca_certificate" "subordinate-certificate" {

  provider          = aws.primary-provider
  certificate_authority_arn   = aws_acmpca_certificate_authority.root-ca.arn
  certificate_signing_request = aws_acmpca_certificate_authority.subordinate-ca.certificate_signing_request
  signing_algorithm           = var.SIGNING_ALGORITHM

  template_arn = "arn:${data.aws_partition.current.partition}:acm-pca:::template/SubordinateCACertificate_PathLen0/V1"

  validity {
    type  = "MONTHS"
    value = 10
  }
}

resource "aws_acmpca_certificate_authority_certificate" "subordinate-ca-certificate" {

  provider          = aws.primary-provider
  certificate_authority_arn = aws_acmpca_certificate_authority.subordinate-ca.arn

  certificate       = aws_acmpca_certificate.subordinate-certificate.certificate
  certificate_chain = aws_acmpca_certificate.subordinate-certificate.certificate_chain
}

//resource "aws_cloudformation_stack" "subordinate-ca-activation" {
//  provider          = aws.primary-provider
//  name = "subordinate-ca-activation"
//
//  parameters = {
//    certificate = aws_acmpca_certificate.subordinate-certificate.certificate
//    certificateAuthorityArn = aws_acmpca_certificate_authority.subordinate-ca.arn
//    certificateChain =  aws_acmpca_certificate.subordinate-certificate.certificate_chain
//  }
//
//  template_body = <<STACK
//{
//  "Parameters" : {
//    "certificate" : {
//      "Type" : "String"
//    },
//    "certificateAuthorityArn" : {
//      "Type" : "String"
//    },
//    "certificateChain" : {
//      "Type" : "String"
//    }
//  },
//  "Resources" : {
//    "scaactivation": {
//      "Type": "AWS::ACMPCA::CertificateAuthorityActivation",
//		"Properties": {
//			"Certificate" : {"Ref": "certificate"},
//            "CertificateAuthorityArn" : {"Ref": "certificateAuthorityArn"},
//            "CertificateChain" : {"Ref": "certificateChain"}
//		}
//    }
//  }
//}
//STACK
//}

data "aws_secretsmanager_secret" "app-primary-vpc-secret" {

  name = "${var.APP}-${var.AWS_PRIMARY_REGION}-vpc"
}

data "aws_secretsmanager_secret_version" "app-primary-vpc-secret-version" {

  secret_id = data.aws_secretsmanager_secret.app-primary-vpc-secret.id
}

resource "aws_route53_zone" "trade-matching-component-private-zone" {

  name = var.DOMAIN
  comment = var.DOMAIN

  vpc {
    vpc_id = data.aws_secretsmanager_secret_version.app-primary-vpc-secret-version.secret_string
    vpc_region = var.AWS_PRIMARY_REGION
  }
}

resource "aws_acm_certificate" "nlb-certificate" {

  domain_name               = var.DOMAIN
  certificate_authority_arn = aws_acmpca_certificate_authority.subordinate-ca.arn

  lifecycle {
    create_before_destroy = true
  }
}



