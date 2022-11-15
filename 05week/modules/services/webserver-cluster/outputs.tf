output "asg_name" {
    value = aws_autoscaling_group.ssoon_asg.name
    description = "the name of the auto scaling group"
}

output "alb_dns_name" {
    value = aws_lb.ssoon_alb.dns_name
    description = "the domain name of the load balancer"
}

output "alb_security_group_id" {
    value = aws_security_group.ssoon_sg.id
    description = "the id of the sg attached to the lb"  
}