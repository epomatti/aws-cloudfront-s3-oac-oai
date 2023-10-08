locals {
  random_affix = random_string.random_suffix.result
}

resource "random_string" "random_suffix" {
  length  = 3
  special = false
  upper   = false
}

### S3 Bucket ###
resource "aws_s3_bucket" "main" {
  bucket = "bucket-oai-${var.project_name}-${local.random_affix}"
}

# resource "aws_s3_bucket_website_configuration" "main" {
#   bucket = aws_s3_bucket.main.bucket

#   index_document {
#     suffix = "index.html"
#   }
# }

### S3 Objects ###

resource "aws_s3_object" "index" {
  bucket         = aws_s3_bucket.main.bucket
  key            = "/oai/index.html"
  content_base64 = filebase64("${path.module}/../../assets/index-oai.html")
  content_type   = "text/html"
}

# resource "aws_s3_object" "saturn5" {
#   bucket         = aws_s3_bucket.main.bucket
#   key            = "saturn5.jpg"
#   content_base64 = filebase64("${path.module}/assets/saturn5.jpg")
#   content_type   = "image/jpeg"
# }

# resource "aws_s3_object" "saturn5flame" {
#   bucket         = aws_s3_bucket.main.bucket
#   key            = "saturn5-flame.jpg"
#   content_base64 = filebase64("${path.module}/assets/saturn5-flame.jpg")
#   content_type   = "image/jpeg"
# }
