resource "aws_security_group" "ssoon_sg" {
  vpc_id      = aws_vpc.ssoon_vpc.id
  name        = "T101_Ssoon_SG"
  description = "T101_Ssoon_SG"

    tags = {
    Name = "T101_Ssoon_SG"
  }
}

resource "aws_security_group_rule" "ssoon_sg_inbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ssoon_sg.id
}

resource "aws_security_group_rule" "ssoon_sg_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ssoon_sg.id
}
