provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_iam_user" "existing_user" {
  count = 3
  name = "Ssoon.${count.index}"
}