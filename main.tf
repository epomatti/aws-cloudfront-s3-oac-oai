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

module "bucket" {
  source       = "./modules/s3/bucket"
  project_name = local.project_name
}

module "cloudfront" {
  source                      = "./modules/cloudfront"
  project_name                = local.project_name
  price_class                 = var.cloudfront_price_class
  bucket_regional_domain_name = module.bucket.bucket_regional_domain_name
}

module "oai" {
  source                 = "./modules/s3/oai"
  cloudfront_oai_iam_arn = module.cloudfront.oai_iam_arn
  bucket_arn             = module.bucket.bucket_arn
  bucket_id              = module.bucket.bucket_id
}

