#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#! Provider 설정
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
provider "aws" {
  region = "ap-northeast-2"
}

#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#! S3 버킷 생성
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
resource "aws_s3_bucket" "ssoon_s3bucket" {
  bucket = "ssoon-t101study-tfstate-week4-files"
}

resource "aws_s3_bucket_versioning" "ssoon_s3bucket_versioning" {
  bucket = aws_s3_bucket.ssoon_s3bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#! DynamoDB 테이블 생성
#! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
resource "aws_dynamodb_table" "ssoon_dynamodbtable" {
  name         = "terraform-locks-week4-files"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
