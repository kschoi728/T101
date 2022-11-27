provider "aws" {
  region = "ap-northeast-2"
}

data "aws_kms_secrets" "creds" {
  secret {
    name    = "db"
    payload = file("../kms-cmk/db-creds.yml.encrypted")
  }
}

#! YAML 구문 분석
locals {
  db_creds = yamldecode(data.aws_kms_secrets.creds.plaintext["db"])
}

resource "aws_db_instance" "ssoon_db" {
  identifier_prefix   = "ssoon"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  skip_final_snapshot = true
  db_name             = "ssoon"

  # Pass the secrets to the resource
  username = local.db_creds.username
  password = local.db_creds.password
}
