resource "aws_s3_bucket" "lambda_assets" {
  bucket = "lambda-deploy-bucket"
}

resource "aws_s3_bucket_acl" "lambda_assets" {
  bucket = aws_s3_bucket.lambda_assets.id
  acl = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_assets" {
  bucket = aws_s3_bucket.lambda_assets.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "lambda_assets" {
  bucket = aws_s3_bucket.lambda_assets.bucket
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}
