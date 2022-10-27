// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_vpc_endpoint" "kinesis-stream-endpoint" {

  vpc_id       = module.approtation-vpc.vpc_id
  service_name = "com.amazonaws.${var.AWS_REGION}.kinesis-streams"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.vpc-endpoint-sg.id]
  private_dns_enabled = true
  tags = {
    Name = "kinesis-stream-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint_subnet_association" "sna1" {

  vpc_endpoint_id = aws_vpc_endpoint.kinesis-stream-endpoint.id
  subnet_id       = module.approtation-vpc.public_subnets[0]
}

resource "aws_vpc_endpoint_subnet_association" "sna2" {

  vpc_endpoint_id = aws_vpc_endpoint.kinesis-stream-endpoint.id
  subnet_id       = module.approtation-vpc.public_subnets[1]
}

resource "aws_vpc_endpoint_subnet_association" "sna3" {

  vpc_endpoint_id = aws_vpc_endpoint.kinesis-stream-endpoint.id
  subnet_id       = module.approtation-vpc.public_subnets[2]
}

//resource "aws_vpc_endpoint_subnet_association" "sna4" {
//  vpc_endpoint_id = aws_vpc_endpoint.kinesis-stream-endpoint.id
//  subnet_id       = module.approtation-vpc.private_subnets[0]
//}
//
//resource "aws_vpc_endpoint_subnet_association" "sna5" {
//  vpc_endpoint_id = aws_vpc_endpoint.kinesis-stream-endpoint.id
//  subnet_id       = module.approtation-vpc.private_subnets[1]
//}
//
//resource "aws_vpc_endpoint_subnet_association" "sna6" {
//  vpc_endpoint_id = aws_vpc_endpoint.kinesis-stream-endpoint.id
//  subnet_id       = module.approtation-vpc.private_subnets[2]
//}


resource "aws_vpc_endpoint" "rds-endpoint" {

  vpc_id       = module.approtation-vpc.vpc_id
  service_name = "com.amazonaws.${var.AWS_REGION}.rds"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.vpc-endpoint-sg.id]
  private_dns_enabled = true
  tags = {
    Name = "rds-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint_subnet_association" "sna11" {

  vpc_endpoint_id = aws_vpc_endpoint.rds-endpoint.id
  subnet_id       = module.approtation-vpc.public_subnets[0]
}

resource "aws_vpc_endpoint_subnet_association" "sna12" {

  vpc_endpoint_id = aws_vpc_endpoint.rds-endpoint.id
  subnet_id       = module.approtation-vpc.public_subnets[1]
}

resource "aws_vpc_endpoint_subnet_association" "sna13" {

  vpc_endpoint_id = aws_vpc_endpoint.rds-endpoint.id
  subnet_id       = module.approtation-vpc.public_subnets[2]
}

//resource "aws_vpc_endpoint_subnet_association" "sna14" {
//  vpc_endpoint_id = aws_vpc_endpoint.rds-endpoint.id
//  subnet_id       = module.approtation-vpc.private_subnets[0]
//}
//
//resource "aws_vpc_endpoint_subnet_association" "sna15" {
//  vpc_endpoint_id = aws_vpc_endpoint.rds-endpoint.id
//  subnet_id       = module.approtation-vpc.private_subnets[1]
//}
//
//resource "aws_vpc_endpoint_subnet_association" "sna16" {
//  vpc_endpoint_id = aws_vpc_endpoint.rds-endpoint.id
//  subnet_id       = module.approtation-vpc.private_subnets[2]
//}

resource "aws_vpc_endpoint" "dynamodb-endpoint" {

  vpc_id       = module.approtation-vpc.vpc_id
  service_name = "com.amazonaws.${var.AWS_REGION}.dynamodb"
  vpc_endpoint_type = "Gateway"
  tags = {
    Name = "dynamodb-vpc-endpoint"
  }
}

//resource "aws_vpc_endpoint_subnet_association" "sna21" {
//  vpc_endpoint_id = aws_vpc_endpoint.dynamodb-endpoint.id
//  subnet_id       = module.approtation-vpc.public_subnets[0]
//}
//
//resource "aws_vpc_endpoint_subnet_association" "sna22" {
//  vpc_endpoint_id = aws_vpc_endpoint.dynamodb-endpoint.id
//  subnet_id       = module.approtation-vpc.public_subnets[1]
//}
//
//resource "aws_vpc_endpoint_subnet_association" "sna23" {
//  vpc_endpoint_id = aws_vpc_endpoint.dynamodb-endpoint.id
//  subnet_id       = module.approtation-vpc.public_subnets[2]
//}

//resource "aws_vpc_endpoint_subnet_association" "sna24" {
//  vpc_endpoint_id = aws_vpc_endpoint.dynamodb-endpoint.id
//  subnet_id       = module.approtation-vpc.private_subnets[0]
//}
//
//resource "aws_vpc_endpoint_subnet_association" "sna25" {
//  vpc_endpoint_id = aws_vpc_endpoint.dynamodb-endpoint.id
//  subnet_id       = module.approtation-vpc.private_subnets[1]
//}
//
//resource "aws_vpc_endpoint_subnet_association" "sna26" {
//  vpc_endpoint_id = aws_vpc_endpoint.dynamodb-endpoint.id
//  subnet_id       = module.approtation-vpc.private_subnets[2]
//}


resource "aws_vpc_endpoint" "secretsmanager-endpoint" {

  vpc_id       = module.approtation-vpc.vpc_id
  service_name = "com.amazonaws.${var.AWS_REGION}.secretsmanager"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.vpc-endpoint-sg.id]
  private_dns_enabled = true
  tags = {
    Name = "secretsmanager-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint_subnet_association" "sna31" {

  vpc_endpoint_id = aws_vpc_endpoint.secretsmanager-endpoint.id
  subnet_id       = module.approtation-vpc.public_subnets[0]
}

resource "aws_vpc_endpoint_subnet_association" "sna32" {

  vpc_endpoint_id = aws_vpc_endpoint.secretsmanager-endpoint.id
  subnet_id       = module.approtation-vpc.public_subnets[1]
}

resource "aws_vpc_endpoint_subnet_association" "sna33" {

  vpc_endpoint_id = aws_vpc_endpoint.secretsmanager-endpoint.id
  subnet_id       = module.approtation-vpc.public_subnets[2]
}

//resource "aws_vpc_endpoint_subnet_association" "sna34" {
//  vpc_endpoint_id = aws_vpc_endpoint.secretsmanager-endpoint.id
//  subnet_id       = module.approtation-vpc.private_subnets[0]
//}
//
//resource "aws_vpc_endpoint_subnet_association" "sna35" {
//  vpc_endpoint_id = aws_vpc_endpoint.secretsmanager-endpoint.id
//  subnet_id       = module.approtation-vpc.private_subnets[1]
//}
//
//resource "aws_vpc_endpoint_subnet_association" "sna36" {
//  vpc_endpoint_id = aws_vpc_endpoint.secretsmanager-endpoint.id
//  subnet_id       = module.approtation-vpc.private_subnets[2]
//}

resource "aws_vpc_endpoint" "ssm-endpoint" {

  vpc_id       = module.approtation-vpc.vpc_id
  service_name = "com.amazonaws.${var.AWS_REGION}.ssm"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.vpc-endpoint-sg.id]
  private_dns_enabled = true
  tags = {
    Name = "ssm-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint_subnet_association" "sna41" {

  vpc_endpoint_id = aws_vpc_endpoint.ssm-endpoint.id
  subnet_id       = module.approtation-vpc.public_subnets[0]
}

resource "aws_vpc_endpoint_subnet_association" "sna42" {

  vpc_endpoint_id = aws_vpc_endpoint.ssm-endpoint.id
  subnet_id       = module.approtation-vpc.public_subnets[1]
}

resource "aws_vpc_endpoint_subnet_association" "sna43" {

  vpc_endpoint_id = aws_vpc_endpoint.ssm-endpoint.id
  subnet_id       = module.approtation-vpc.public_subnets[2]
}

//resource "aws_vpc_endpoint_subnet_association" "sna44" {
//  vpc_endpoint_id = aws_vpc_endpoint.ssm-endpoint.id
//  subnet_id       = module.approtation-vpc.private_subnets[0]
//}
//
//resource "aws_vpc_endpoint_subnet_association" "sna45" {
//  vpc_endpoint_id = aws_vpc_endpoint.ssm-endpoint.id
//  subnet_id       = module.approtation-vpc.private_subnets[1]
//}
//
//resource "aws_vpc_endpoint_subnet_association" "sna46" {
//  vpc_endpoint_id = aws_vpc_endpoint.ssm-endpoint.id
//  subnet_id       = module.approtation-vpc.private_subnets[2]
//}

resource "aws_vpc_endpoint" "execute-api-endpoint" {

  vpc_id       = module.approtation-vpc.vpc_id
  service_name = "com.amazonaws.${var.AWS_REGION}.execute-api"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.vpc-endpoint-sg.id]
  private_dns_enabled = true
  tags = {
    Name = "execute-api-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint_subnet_association" "sna51" {

  vpc_endpoint_id = aws_vpc_endpoint.execute-api-endpoint.id
  subnet_id       = module.approtation-vpc.public_subnets[0]
}

resource "aws_vpc_endpoint_subnet_association" "sna52" {

  vpc_endpoint_id = aws_vpc_endpoint.execute-api-endpoint.id
  subnet_id       = module.approtation-vpc.public_subnets[1]
}

resource "aws_vpc_endpoint_subnet_association" "sna53" {

  vpc_endpoint_id = aws_vpc_endpoint.execute-api-endpoint.id
  subnet_id       = module.approtation-vpc.public_subnets[2]
}

//resource "aws_vpc_endpoint_subnet_association" "sna54" {
//  vpc_endpoint_id = aws_vpc_endpoint.execute-api-endpoint.id
//  subnet_id       = module.approtation-vpc.private_subnets[0]
//}
//
//resource "aws_vpc_endpoint_subnet_association" "sna55" {
//  vpc_endpoint_id = aws_vpc_endpoint.execute-api-endpoint.id
//  subnet_id       = module.approtation-vpc.private_subnets[1]
//}
//
//resource "aws_vpc_endpoint_subnet_association" "sna56" {
//  vpc_endpoint_id = aws_vpc_endpoint.execute-api-endpoint.id
//  subnet_id       = module.approtation-vpc.private_subnets[2]
//}
