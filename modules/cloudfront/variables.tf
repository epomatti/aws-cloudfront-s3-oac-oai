variable "project_name" {
  type = string
}

variable "price_class" {
  type = string
}

variable "oai_bucket_regional_domain_name" {
  type = string
}

variable "oac_bucket_regional_domain_name" {
  type = string
}

variable "signed_vouchers_bucket_regional_domain_name" {
  type = string
}

variable "enforce_tls_bucket_regional_domain_name" {
  type = string
}


## Custom TLS
variable "acm_arn" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "minimum_protocol_version" {
  type = string
}
