terraform {
  backend "s3" {
    bucket = "ssoon-t101study-tfstate-week3-files"
    key    = "stage/data-stores/ssoon_sql/terraform.tfstate"
    region = "ap-northeast-2"
    dynamodb_table = "terraform-locks-week3-files"
  }
}

provider "aws" {
  region  = "ap-northeast-2"
}

resource "aws_vpc" "ssoon_vpc" {
  cidr_block       = "10.10.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "t101-study"
  }
}

resource "aws_subnet" "ssoon_subnet3" {
  vpc_id     = aws_vpc.ssoon_vpc.id
  cidr_block = "10.10.3.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "t101-subnet3"
  }
}

resource "aws_subnet" "ssoon_subnet4" {
  vpc_id     = aws_vpc.ssoon_vpc.id
  cidr_block = "10.10.4.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "t101-subnet4"
  }
}

resource "aws_route_table" "ssoon_rt2" {
  vpc_id = aws_vpc.ssoon_vpc.id

  tags = {
    Name = "t101-rt2"
  }
}

resource "aws_route_table_association" "ssoon_rtassociation3" {
  subnet_id      = aws_subnet.ssoon_subnet3.id
  route_table_id = aws_route_table.ssoon_rt2.id
}

resource "aws_route_table_association" "ssoon_rtassociation4" {
  subnet_id      = aws_subnet.ssoon_subnet4.id
  route_table_id = aws_route_table.ssoon_rt2.id
}

resource "aws_security_group" "ssoon_sg2" {
  vpc_id      = aws_vpc.ssoon_vpc.id
  name        = "T101 SG - RDS"
  description = "T101 Study SG - RDS"
}

resource "aws_security_group_rule" "rdssginbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ssoon_sg2.id
}

resource "aws_security_group_rule" "rdssgoutbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ssoon_sg2.id
}