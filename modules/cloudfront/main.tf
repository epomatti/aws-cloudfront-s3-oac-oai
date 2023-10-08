locals {
  s3_origin_oai = "bucket-oai"
  s3_origin_oac = "bucket-oac"
}

resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "S3 CloudFront OAI"
}

resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "oacbucket"
  description                       = "OAC authorizationf for S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

### Distribution ###
resource "aws_cloudfront_distribution" "s3_distribution" {
  price_class     = var.price_class
  enabled         = true
  is_ipv6_enabled = true
  comment         = "Distribution for OAI and OAC bucket origins"

  # OAI
  origin {
    domain_name = var.oai_bucket_domain_name
    origin_id   = local.s3_origin_oai

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }

  # OAC
  origin {
    domain_name              = var.oac_bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
    origin_id                = local.s3_origin_oac
  }

  default_cache_behavior {
    allowed_methods  = ["HEAD", "GET"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = local.s3_origin_oai

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}


### S3 Bucket ###

# resource "random_string" "random_suffix" {
#   length  = 6
#   special = false
#   upper   = false
# }

# resource "aws_s3_bucket" "main" {
#   bucket = "cloufrontlogs-saturn5-${random_string.random_suffix.result}"
# }

# data "aws_iam_policy_document" "s3_policy" {
#   statement {
#     actions   = ["s3:*"]
#     resources = ["${aws_s3_bucket.main.arn}/*"]

#     principals {
#       type        = "AWS"
#       identifiers = [aws_cloudfront_origin_access_identity.main.iam_arn]
#     }
#   }
# }

# resource "aws_s3_bucket_policy" "cloudfront_oai" {
#   bucket = aws_s3_bucket.main.id
#   policy = data.aws_iam_policy_document.s3_policy.json
# }
