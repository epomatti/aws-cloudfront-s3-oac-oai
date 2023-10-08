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

module "cloudfront" {
  source                 = "./modules/cloudfront"
  project_name           = local.project_name
  price_class            = var.cloudfront_price_class
  oai_bucket_domain_name = module.bucket_oai.bucket_domain_name
  oac_bucket_domain_name = module.bucket_oac.bucket_domain_name
}

module "s3_permissions" {
  source = "./modules/s3/permissions"

  # OAI
  oai_bucket_id          = module.bucket_oai.bucket_id
  oai_bucket_arn         = module.bucket_oai.bucket_arn
  cloudfront_oai_iam_arn = module.cloudfront.oai_iam_arn

  # OAC
  oac_bucket_id               = module.bucket_oac.bucket_id
  oac_bucket_arn              = module.bucket_oac.bucket_arn
  cloudfront_distribution_arn = module.cloudfront.distribution_arn
}
