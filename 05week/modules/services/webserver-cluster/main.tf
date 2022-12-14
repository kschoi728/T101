#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#! Local 설정
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}

#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#! VPC 설정
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
resource "aws_vpc" "ssoon_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#! Subnet 설정
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
resource "aws_subnet" "ssoon_subnet1" {
  vpc_id     = aws_vpc.ssoon_vpc.id
  cidr_block = "10.10.1.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "${var.cluster_name}-subnet1"
  }
}

resource "aws_subnet" "ssoon_subnet2" {
  vpc_id     = aws_vpc.ssoon_vpc.id
  cidr_block = "10.10.2.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "${var.cluster_name}-subnet2"
  }
}

#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#! Internet Gateway 설정
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
resource "aws_internet_gateway" "ssoon_igw" {
  vpc_id = aws_vpc.ssoon_vpc.id

  tags = {
    Name = "${var.cluster_name}-igw"
  }
}

#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#! Route Table 설정
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
resource "aws_route_table" "ssoon_rt" {
  vpc_id = aws_vpc.ssoon_vpc.id

  tags = {
    Name = "${var.cluster_name}-rt"
  }
}

resource "aws_route_table_association" "ssoon_rtassociation1" {
  subnet_id      = aws_subnet.ssoon_subnet1.id
  route_table_id = aws_route_table.ssoon_rt.id
}

resource "aws_route_table_association" "ssoon_rtassociation2" {
  subnet_id      = aws_subnet.ssoon_subnet2.id
  route_table_id = aws_route_table.ssoon_rt.id
}

resource "aws_route" "ssoon_defaultroute" {
  route_table_id         = aws_route_table.ssoon_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ssoon_igw.id
}

#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#! Security Group 설정
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
resource "aws_security_group" "ssoon_sg" {
  vpc_id = aws_vpc.ssoon_vpc.id
  name   = "${var.cluster_name}-SG"
}

resource "aws_security_group_rule" "ssoon_sginbound" {
  type              = "ingress"
  from_port         = local.http_port
  to_port           = local.http_port
  protocol          = local.tcp_protocol
  cidr_blocks       = local.all_ips
  security_group_id = aws_security_group.ssoon_sg.id
}
resource "aws_security_group_rule" "ssoon_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = local.tcp_protocol
  cidr_blocks       = local.all_ips
  security_group_id = aws_security_group.ssoon_sg.id
}
resource "aws_security_group_rule" "ssoon_sgoutbound" {
  type              = "egress"
  from_port         = local.any_port
  to_port           = local.any_port
  protocol          = local.any_protocol
  cidr_blocks       = local.all_ips
  security_group_id = aws_security_group.ssoon_sg.id
}

#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#! Auto Scailing Group 설정
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
data "aws_ami" "amazonlinux2" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}

data "template_file" "user_data" {
  count = var.enable_new_user_data ? 0 : 1

  template = file("${path.module}/user-data.sh")

  vars = {
    server_port = var.server_port
  }
}

data "template_file" "user_data_new" {
  count = var.enable_new_user_data ? 1 : 0

  template = file("${path.module}/user-data-new.sh")

  vars = {
    server_port = var.server_port
  }
}

resource "aws_launch_configuration" "ssoon_lauchconfig" {
  name_prefix                 = "ssoon_lauchconfig-"
  image_id                    = data.aws_ami.amazonlinux2.id
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.ssoon_sg.id]
  associate_public_ip_address = true
  key_name                    = "new-key"

  /*
  user_data = templatefile("${path.module}/user-data.sh", {
    server_port = local.http_port
  })
  */

  user_data = (
    length(data.template_file.user_data[*]) > 0
    ? data.template_file.user_data[0].rendered
    : data.template_file.user_data_new[0].rendered
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ssoon_asg" {
  name                 = "ssoon_asg"
  launch_configuration = aws_launch_configuration.ssoon_lauchconfig.name
  vpc_zone_identifier  = [aws_subnet.ssoon_subnet1.id, aws_subnet.ssoon_subnet2.id]
  min_size             = var.min_size
  max_size             = var.max_size
  health_check_type    = "ELB"
  target_group_arns    = [aws_lb_target_group.ssoon_albtg.arn]

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-asg"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.custom_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#! Application Load Balancer 설정
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
resource "aws_lb" "ssoon_alb" {
  name               = "ssoon-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.ssoon_subnet1.id, aws_subnet.ssoon_subnet2.id]
  security_groups    = [aws_security_group.ssoon_sg.id]

  tags = {
    Name = "${var.cluster_name}-alb"
  }
}

resource "aws_lb_listener" "ssoon_http" {
  load_balancer_arn = aws_lb.ssoon_alb.arn
  port              = local.http_port
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found - T101 Study"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "ssoon_albtg" {
  name     = "t101-alb-tg"
  port     = local.http_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.ssoon_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-299"
    interval            = 5
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "ssoon_albrule" {
  listener_arn = aws_lb_listener.ssoon_http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ssoon_albtg.arn
  }
}

#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#! Autoscaling Schedule 설정
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count = var.enable_autoscaling ? 1 : 0

  scheduled_action_name  = "${var.cluster_name}-scale-out-during-business-hours"
  min_size               = 2
  max_size               = 4
  desired_capacity       = 4
  recurrence             = "0 9 * * *"
  autoscaling_group_name = aws_autoscaling_group.ssoon_asg.name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count = var.enable_autoscaling ? 1 : 0

  scheduled_action_name  = "${var.cluster_name}-scale-in-at-night"
  min_size               = 2
  max_size               = 2
  desired_capacity       = 2
  recurrence             = "0 17 * * *"
  autoscaling_group_name = aws_autoscaling_group.ssoon_asg.name
}

#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#! CloudwWtch Metric Alarm 설정
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name  = "${var.cluster_name}-high-cpu-utilization"
  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ssoon_asg.name
  }

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"
  threshold           = 90
  unit                = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_credit_balance" {
  count = format("%.1s", var.instance_type) == "t" ? 1 : 0

  alarm_name  = "${var.cluster_name}-low-cpu-credit-balance"
  namespace   = "AWS/EC2"
  metric_name = "CPUCreditBalance"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ssoon_asg.name
  }

  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Minimum"
  threshold           = 10
  unit                = "Count"
}
