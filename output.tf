output "cloudfront_distribution_domain_name" {
  value = module.cloudfront.domain_name
}

output "presigned_bucket" {
  value = module.bucket_presigned_url.bucket
}

output "cloudfront_public_key_id" {
  value = module.cloudfront.key_pair_id
}
