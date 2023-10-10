output "domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "oai_iam_arn" {
  value       = aws_cloudfront_origin_access_identity.main.iam_arn
  description = "Used for OAI"
}

output "distribution_arn" {
  value       = aws_cloudfront_distribution.s3_distribution.arn
  description = "Used for OAC"
}

output "key_pair_id" {
  value = aws_cloudfront_public_key.default.id
}
