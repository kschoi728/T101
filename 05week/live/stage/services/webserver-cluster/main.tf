#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #  
#! Provider 설정
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
provider "aws" {
  region = "ap-northeast-2"
}

#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #  
#! Backend 설정
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #  
terraform {
  backend "s3" {
    bucket         = "ssoon-t101study-tfstate-week4-files"
    key            = "stage/services/webserver-cluster/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-locks-week4-files"
  }
}

#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#! Module 설정
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
module "webserver_cluster" {
  source = "../../../../modules/services/webserver-cluster"

  cluster_name       = var.cluster_name
  instance_type      = "t2.micro"
  min_size           = 2
  max_size           = 2
  enable_autoscaling = false
}
