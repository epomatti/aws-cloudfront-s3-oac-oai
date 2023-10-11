locals {
  s3_origin_oac = "bucket-oac"
  s3_origin_oai = "bucket-oai"
  s3_signedurls = "bucket-signedurls"
  s3_enforcetls = "bucket-enforcetls"
}

resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "S3 CloudFront OAI"
}

resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "oacbucket"
  description                       = "OAC authorization for S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_control" "vouchers" {
  name                              = "vouchersbucket"
  description                       = "Signed URLs for vouchers"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_control" "enforce_tls" {
  name                              = "enforcetls"
  description                       = "OAC authorization for S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  price_class     = var.price_class
  enabled         = true
  is_ipv6_enabled = true
  comment         = "Distribution for OAI and OAC bucket origins"

  aliases = [var.domain_name]

  ### ORIGINS ###

  # OAC
  origin {
    domain_name = var.oac_bucket_regional_domain_name
    origin_id   = local.s3_origin_oac

    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
  }

  # OAI
  origin {
    domain_name = var.oai_bucket_regional_domain_name
    origin_id   = local.s3_origin_oai

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }

  # Signed URLs Vouchers
  origin {
    domain_name = var.signed_vouchers_bucket_regional_domain_name
    origin_id   = local.s3_signedurls

    origin_access_control_id = aws_cloudfront_origin_access_control.vouchers.id
  }

  origin {
    domain_name = var.enforce_tls_bucket_regional_domain_name
    origin_id   = local.s3_enforcetls

    origin_access_control_id = aws_cloudfront_origin_access_control.enforce_tls.id
  }


  ### BEHAVIORS ###

  ordered_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["HEAD", "GET"]
    target_origin_id       = local.s3_origin_oac
    path_pattern           = "/oac/*"
    viewer_protocol_policy = "redirect-to-https"

    # CachingDisabled managed policy
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  }

  ordered_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["HEAD", "GET"]
    target_origin_id       = local.s3_origin_oai
    path_pattern           = "/oai/*"
    viewer_protocol_policy = "redirect-to-https"

    # CachingDisabled managed policy
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  }

  ordered_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["HEAD", "GET"]
    target_origin_id       = local.s3_signedurls
    path_pattern           = "/vouchers/*"
    viewer_protocol_policy = "redirect-to-https"

    trusted_key_groups = [aws_cloudfront_key_group.default.id]

    # CachingDisabled managed policy
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  }

  ordered_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["HEAD", "GET"]
    target_origin_id       = local.s3_enforcetls
    path_pattern           = "/enforcetls/*"
    viewer_protocol_policy = "https-only"

    # CachingDisabled managed policy
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_oac
    viewer_protocol_policy = "redirect-to-https"

    # CachingOptimized
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.acm_arn
    minimum_protocol_version       = var.minimum_protocol_version
    ssl_support_method             = "sni-only"
  }
}

### Signed URLs stuff

resource "aws_cloudfront_public_key" "default" {
  comment     = "Signed URLs with Terraform"
  encoded_key = file("${path.module}/../../keys/public.pem")
  name        = "terraform-key"
}

resource "aws_cloudfront_key_group" "default" {
  comment = "Signed URLs with Terraform"
  items   = [aws_cloudfront_public_key.default.id]
  name    = "terraform-key-group"
}
