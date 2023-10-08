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

resource "aws_cloudfront_distribution" "s3_distribution" {
  price_class     = var.price_class
  enabled         = true
  is_ipv6_enabled = true
  comment         = "Distribution for OAI and OAC bucket origins"

  # OAI
  origin {
    domain_name = var.oai_bucket_regional_domain_name
    origin_id   = local.s3_origin_oai
    origin_path = "/oai"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }

  # OAC
  origin {
    domain_name = var.oac_bucket_regional_domain_name
    origin_id   = local.s3_origin_oac
    origin_path = "/oac"

    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = local.s3_origin_oai

    # CachingDisabled managed policy
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"

    viewer_protocol_policy = "allow-all"
  }

  ordered_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = local.s3_origin_oac

    path_pattern = "/oac"

    # CachingDisabled managed policy
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"

    viewer_protocol_policy = "allow-all"
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
