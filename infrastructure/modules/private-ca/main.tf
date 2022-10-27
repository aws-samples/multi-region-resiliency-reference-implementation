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

//resource "aws_cloudformation_stack" "root-ca-activation" {
//  provider          = aws.primary-provider
//  name = "root-ca-activation"
//
//  parameters = {
//    certificate = aws_acmpca_certificate.root-certificate.certificate
//    certificateAuthorityArn = aws_acmpca_certificate_authority.root-ca.arn
//    certificateChain =  aws_acmpca_certificate.root-certificate.certificate_chain
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
//    "rcaactivation": {
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

data "aws_kms_key" "secret-manager-secret-key" {

  key_id = "alias/secret-manager-secret-key"
}

resource "aws_secretsmanager_secret" "secret" {

  provider          = aws.primary-provider
  name = "${var.APP}-certificate-authority-${var.AWS_PRIMARY_REGION}"
  kms_key_id = data.aws_kms_key.secret-manager-secret-key.key_id
  replica {
    region = var.AWS_SECONDARY_REGION
  }
  recovery_window_in_days = 0
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "secret-version" {

  provider      = aws.primary-provider
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = aws_acmpca_certificate_authority.subordinate-ca.arn
}







