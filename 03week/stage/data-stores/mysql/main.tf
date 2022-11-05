resource "aws_db_subnet_group" "ssoon_dbsubnet" {
  name       = "ssoon_dbsubnetgroup"
  subnet_ids = [aws_subnet.ssoon_subnet3.id, aws_subnet.ssoon_subnet4.id]

  tags = {
    Name = "ssoon_DB subnet group"
  }
}

resource "aws_db_instance" "ssoon_rds" {
  identifier             = "ssoon-rds"
  engine                 = "mysql"
  allocated_storage      = 10
  instance_class         = "db.t2.micro"
  db_subnet_group_name   = aws_db_subnet_group.ssoon_dbsubnet.name
  vpc_security_group_ids = [aws_security_group.ssoon_sg2.id]
  skip_final_snapshot    = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  tags = {
    Name = "ssoon-rds"
  }
}
