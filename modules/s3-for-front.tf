resource "aws_s3_bucket" "web-front-bucket" {
  bucket = "masayasviel-anime-list-front-bucket"
}

resource "aws_s3_bucket_acl" "web-front-bucket-acl" {
  bucket = aws_s3_bucket.web-front-bucket.bucket
  acl = "private"
}

resource "aws_s3_bucket_website_configuration" "s3-web-front-configuration" {
  bucket = aws_s3_bucket.web-front-bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
