locals {
  random_affix = random_string.random_suffix.result
}

resource "random_string" "random_suffix" {
  length  = 3
  special = false
  upper   = false
}

resource "aws_s3_bucket" "main" {
  bucket = "bucket-oac-${var.project_name}-${local.random_affix}"
}

resource "aws_s3_object" "index" {
  bucket         = aws_s3_bucket.main.bucket
  key            = "/oac/index.html"
  content_base64 = filebase64("${path.module}/../../assets/index-oac.html")
  content_type   = "text/html"
}

resource "aws_kms_key" "oac" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.oac.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
