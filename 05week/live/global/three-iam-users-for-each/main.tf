provider "aws" {
  region = "us-east-2"
}

resource "aws_iam_user" "main" {
  for_each = toset(var.user_names)
  name     = each.value
}
