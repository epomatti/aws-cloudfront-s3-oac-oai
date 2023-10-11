variable "cloudfront_oai_iam_arn" {
  type = string
}

variable "oai_bucket_id" {
  type = string
}

variable "oai_bucket_arn" {
  type = string
}

variable "oac_bucket_id" {
  type = string
}

variable "oac_bucket_arn" {
  type = string
}

variable "cloudfront_distribution_arn" {
  type = string
}

variable "kms_key_arn" {
  type = string
}


# Signed URLs

variable "signedurls_bucket_id" {
  type = string
}

variable "signedurls_bucket_arn" {
  type = string
}

# Enforce TLS

variable "enforce_tls_bucket_id" {
  type = string
}

variable "enforce_tls_bucket_arn" {
  type = string
}
