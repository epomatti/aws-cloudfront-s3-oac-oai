variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "cloudfront_price_class" {
  type    = string
  default = "PriceClass_100"
}

variable "certificate_domain" {
  type = string
}

variable "cloudfront_minimum_protocol_version" {
  type = string
}
