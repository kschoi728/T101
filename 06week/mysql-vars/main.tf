provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_db_instance" "ssoon_ec2" {
  identifier_prefix   = "ssoon"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  skip_final_snapshot = true
  db_name             = var.db_name

  #! secrets 를 리소스에 전달
  username = var.db_username
  password = var.db_password

  tags = {
    Name = "Ssoon-EC2"
  }
}
