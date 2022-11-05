provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_s3_bucket" "ssoon_s3bucket" {
  bucket = "ssoon-t101study-tfstate-week3"
}

resource "aws_s3_bucket_versioning" "ssoon_s3bucket_versioning" {
  bucket = aws_s3_bucket.ssoon_s3bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "ssoon_dynamodbtable" {
  name         = "terraform-locks-week3"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.ssoon_s3bucket.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.ssoon_dynamodbtable.name
  description = "The name of the DynamoDB table"
}
