resource "aws_vpc" "ssoon_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "T101_Ssoon_vpc"
  }
}

resource "aws_subnet" "ssoon_subnet1" {
  vpc_id     = aws_vpc.ssoon_vpc.id
  cidr_block = "10.10.1.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "T101_Ssoon_subnet1"
  }
}

resource "aws_subnet" "ssoon_subnet2" {
  vpc_id     = aws_vpc.ssoon_vpc.id
  cidr_block = "10.10.2.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "T101_Ssoon_subnet2"
  }
}

resource "aws_internet_gateway" "ssoon_igw" {
  vpc_id = aws_vpc.ssoon_vpc.id

  tags = {
    Name = "T101_Ssoon_igw"
  }
}

resource "aws_route_table" "ssoon_rt" {
  vpc_id = aws_vpc.ssoon_vpc.id

  tags = {
    Name = "T101_Ssoon_rt"
  }
}

resource "aws_route_table_association" "ssoon_rt_association1" {
  subnet_id      = aws_subnet.ssoon_subnet1.id
  route_table_id = aws_route_table.ssoon_rt.id
}

resource "aws_route_table_association" "ssoon_rt_association2" {
  subnet_id      = aws_subnet.ssoon_subnet2.id
  route_table_id = aws_route_table.ssoon_rt.id
}

resource "aws_route" "ssoon_default_route" {
  route_table_id         = aws_route_table.ssoon_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ssoon_igw.id
}
