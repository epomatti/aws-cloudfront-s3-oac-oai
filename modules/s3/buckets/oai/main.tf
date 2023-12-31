locals {
  random_affix = random_string.random_suffix.result
}

resource "random_string" "random_suffix" {
  length  = 3
  special = false
  upper   = false
}

resource "aws_s3_bucket" "main" {
  bucket = "bucket-oai-${var.project_name}-${local.random_affix}"
}

resource "aws_s3_object" "index" {
  bucket         = aws_s3_bucket.main.bucket
  key            = "/oai/index.html"
  content_base64 = filebase64("${path.module}/../../assets/index-oai.html")
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
