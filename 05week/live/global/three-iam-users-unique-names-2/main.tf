provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_iam_user" "main" {
  count = length(var.user_names)
  name  = var.user_names[count.index]
}

#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#! IAM 설정 - CloudWatch 읽기전용
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

data "aws_iam_policy_document" "cloudwatch_read_olny" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:Describe",
      "cloudwatch:Get*",
      "cloudwatch:List*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cloudwatch_read_only" {
  name   = "cloudwatch-read-only"
  policy = data.aws_iam_policy_document.cloudwatch_read_olny.json
}

#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#! IAM 설정 - CloudWatch 읽기/쓰기허용
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

data "aws_iam_policy_document" "cloudwatch_full_access" {
  statement {
    effect    = "Allow"
    actions   = ["cloudwatch:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cloudwatch_full_access" {
  name   = "cloudwatch_full_access"
  policy = data.aws_iam_policy_document.cloudwatch_full_access.json
}

#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#! IAM 설정 - 조건표현식 사용
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

resource "aws_iam_user_policy_attachment" "chunsik_cloudwatch_full_access" {
  count      = var.give_chunsik_cloudwatch_full_access ? 1 : 0
  user       = aws_iam_user.main[1].name
  policy_arn = aws_iam_policy.cloudwatch_full_access.arn
}

resource "aws_iam_user_policy_attachment" "chunsik_cloudwatch_read_only" {
  count      = var.give_chunsik_cloudwatch_full_access ? 0 : 1
  user       = aws_iam_user.main[1].name
  policy_arn = aws_iam_policy.cloudwatch_read_only.arn
}
