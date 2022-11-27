provider "aws" {
  region = "ap-northeast-2"
}
/*
#! 현재 사용자의 세부 정보 조회
data "aws_caller_identity" "self" {}

#! 현재 IAM 사용자를 CMK의 관리자로 만드는 정책
data "aws_iam_policy_document" "cmk_admin_policy" {
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:*"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.self.arn]
    }
  }
}
*/
#! KMS Customer Managed Key (CMK) 생성
resource "aws_kms_key" "cmk" {

  #! 테스트를 위해 짧은 삭제 기간을 설정
  deletion_window_in_days = 7
}

#! CMK에 대한 alias 생성
resource "aws_kms_alias" "cmk" {
  name          = "alias/kms-cmk-ssoon"
  target_key_id = aws_kms_key.cmk.id
}