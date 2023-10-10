resource "random_string" "random_suffix" {
  length  = 3
  special = false
  upper   = false
}

resource "aws_s3_bucket" "main" {
  bucket = "bucket-presignedurl-vouchers010203"
}

resource "aws_s3_object" "index" {
  bucket         = aws_s3_bucket.main.bucket
  key            = "/vouchers/voucher.txt"
  content_base64 = filebase64("${path.module}/../../assets/voucher.txt")
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
