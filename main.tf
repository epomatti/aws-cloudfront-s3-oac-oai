terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.20.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  project_name = "saturn5"
}

module "bucket_oai" {
  source       = "./modules/s3/buckets/oai"
  project_name = local.project_name
}

module "bucket_oac" {
  source       = "./modules/s3/buckets/oac"
  project_name = local.project_name
}

module "bucket_presigned_url" {
  source       = "./modules/s3/buckets/presignedurl"
  project_name = local.project_name
}

module "bucket_enforcetls" {
  source = "./modules/s3/buckets/enforcetls"
}

module "cloudfront" {
  source       = "./modules/cloudfront"
  project_name = local.project_name
  price_class  = var.cloudfront_price_class

  oai_bucket_regional_domain_name = module.bucket_oai.bucket_regional_domain_name
  oac_bucket_regional_domain_name = module.bucket_oac.bucket_regional_domain_name

  signed_vouchers_bucket_regional_domain_name = module.bucket_presigned_url.bucket_regional_domain_name
}

module "s3_permissions" {
  source = "./modules/s3/permissions"

  # OAI
  oai_bucket_id          = module.bucket_oai.bucket_id
  oai_bucket_arn         = module.bucket_oai.bucket_arn
  cloudfront_oai_iam_arn = module.cloudfront.oai_iam_arn

  # OAC
  cloudfront_distribution_arn = module.cloudfront.distribution_arn

  # OAC bucket
  kms_key_arn    = module.bucket_oac.kms_key_arn
  oac_bucket_id  = module.bucket_oac.bucket_id
  oac_bucket_arn = module.bucket_oac.bucket_arn

  # Signed URLs bucket
  signedurls_bucket_id  = module.bucket_presigned_url.bucket_id
  signedurls_bucket_arn = module.bucket_presigned_url.bucket_arn

  # Enforce TLS
  enforce_tls_bucket_id  = module.bucket_enforcetls.bucket_id
  enforce_tls_bucket_arn = module.bucket_enforcetls.bucket_arn
}
