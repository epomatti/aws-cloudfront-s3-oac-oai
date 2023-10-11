resource "random_string" "random_suffix" {
  length  = 3
  special = false
  upper   = false
}

locals {
  affix = random_string.random_suffix.result
}

resource "aws_s3_bucket" "main" {
  bucket = "bucket-enforcetls-${local.affix}"
}

resource "aws_s3_object" "index" {
  bucket         = aws_s3_bucket.main.bucket
  key            = "/enforcetls/hello.txt"
  content_base64 = filebase64("${path.module}/../../assets/hello.txt")
  content_type   = "text/html"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
