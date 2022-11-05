output "address" {
  value       = aws_db_instance.ssoon_rds.address
  description = "Connect to the database at this endpoint"
}

output "port" {
  value       = aws_db_instance.ssoon_rds.port
  description = "The port the database is listening on"
}

output "vpcid" {
  value       = aws_vpc.ssoon_vpc.id
  description = "ssoon_ VPC Id"
}