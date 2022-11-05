provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_s3_bucket" "ssoon_s3bucket" {
  bucket = "ssoon-t101study-tfstate-week3-files"
}

# Enable versioning so you can see the full revision history of your state files
resource "aws_s3_bucket_versioning" "ssoon_s3bucket_versioning" {
  bucket = aws_s3_bucket.ssoon_s3bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "ssoon_dynamodbtable" {
  name         = "terraform-locks-week3-files"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}