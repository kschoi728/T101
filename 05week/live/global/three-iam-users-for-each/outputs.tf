output "all_arns" {
  value = values(aws_iam_user.main)[*].arn
}

output "all_users" {
  value = aws_iam_user.main
}