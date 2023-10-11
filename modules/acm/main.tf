provider "aws" {
  region = "us-east-1"
  alias  = "global"
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  provider = aws.global

  lifecycle {
    create_before_destroy = true
  }
}
