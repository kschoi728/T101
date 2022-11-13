#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#! Provider 설정
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
provider "aws" {
  region = "ap-northeast-2"
}

#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#! Backend 설정
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
terraform {
  backend "s3" {
    bucket         = "ssoon-t101study-tfstate-week4-files"
    key            = "stage/services/webserver-cluster/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-locks-week4-files"
  }
}

#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#! Module 설정
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name  = "ssoon-stage"
  instance_type = "t2.micro"
  min_size      = 2
  max_size      = 2
}

#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#! ASG Schedule 설정
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name = "scale-out-during-business-hours"
  min_size              = 2
  max_size              = 4
  desired_capacity      = 4
  recurrence            = "0 9 * * *"

  autoscaling_group_name = module.webserver_cluster.asg_name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale-in-at-night"
  min_size              = 2
  max_size              = 4
  desired_capacity      = 2
  recurrence            = "0 17 * * *"

  autoscaling_group_name = module.webserver_cluster.asg_name
}

#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#! aws_security_group_rule 추가설정
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
resource "aws_security_group_rule" "ssoon_sginbound" {
  type              = "ingress"
  security_group_id = module.webserver_cluster.alb_security_group_id

  from_port         = 1234
  to_port           = 1234
  protocol          = "TCP"
  cidr_blocks       = ["1.2.3.4/32"]
}