provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_instance" "example" {
  ami                    = "ami-0eddbd81024d3fbdd"
  instance_type          = "t2.micro"
  key_name               = "kp-ssoon"
  vpc_security_group_ids = ["${aws_security_group.stg_mysg.id}"]

  #! 인스턴스 프로필 연결
  iam_instance_profile = aws_iam_instance_profile.instance.name
}

#! EC2 인스턴스가 IAM 역할을 맡도록 허용
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

#! IAM role 생성
resource "aws_iam_role" "instance" {
  name_prefix        = "ec2-iam-role-example"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

#! EC2 관리자 권한을 부여하는 IAM policy 생성
data "aws_iam_policy_document" "ec2_admin_permissions" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:*"]
    resources = ["*"]
  }
}

#! EC2 관리자 권한을 IAM role 에 연결
resource "aws_iam_role_policy" "example" {
  role   = aws_iam_role.instance.id
  policy = data.aws_iam_policy_document.ec2_admin_permissions.json
}

#! IAM role 이 연결된 인스턴스 프로파일 생성
resource "aws_iam_instance_profile" "instance" {
  role = aws_iam_role.instance.name
}
