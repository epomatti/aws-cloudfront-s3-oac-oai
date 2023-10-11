data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  aws_account_id        = data.aws_caller_identity.current.account_id
  aws_region            = data.aws_region.current.name
  aws_account_principal = "arn:aws:iam::${local.aws_account_id}:root"
}

resource "aws_s3_bucket_policy" "oai" {
  bucket = var.oai_bucket_id

  policy = jsonencode({
    "Version" : "2008-10-17",
    "Id" : "PolicyForCloudFrontPrivateContent",
    "Statement" : [
      {
        "Sid" : "OAIPermissions"
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${var.cloudfront_oai_iam_arn}"
        },
        "Action" : "s3:GetObject",
        "Resource" : "${var.oai_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_kms_key_policy" "oac" {
  key_id = var.kms_key_arn

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "EvandroCustomEFS",
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${local.aws_account_principal}"
        }
        "Action" : "kms:*",
        "Resource" : "*",
      },
      {
        "Sid" : "AllowCloudFrontServicePrincipalSSE-KMS",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey*"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "aws:SourceArn" : "${var.cloudfront_distribution_arn}"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "oac" {
  bucket = var.oac_bucket_id

  policy = jsonencode({
    "Version" : "2008-10-17",
    "Id" : "PolicyForCloudFrontPrivateContent",
    "Statement" : [
      {
        "Sid" : "AllowCloudFrontServicePrincipalReadOnly",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : "s3:GetObject",
        "Resource" : "${var.oac_bucket_arn}/*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : "${var.cloudfront_distribution_arn}"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "vouchers_signedurls" {
  bucket = var.signedurls_bucket_id

  policy = jsonencode({
    "Version" : "2008-10-17",
    "Id" : "PolicyForCloudFrontPrivateContent",
    "Statement" : [
      {
        "Sid" : "AllowCloudFrontServicePrincipalReadOnly",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : "s3:GetObject",
        "Resource" : "${var.signedurls_bucket_arn}/*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : "${var.cloudfront_distribution_arn}"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "enforce_tls" {
  bucket = var.enforce_tls_bucket_id

  policy = jsonencode({
    "Version" : "2008-10-17",
    "Id" : "PolicyForCloudFrontPrivateContent",
    "Statement" : [
      {
        "Sid" : "AllowCloudFrontServicePrincipalReadOnly",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : "s3:GetObject",
        "Resource" : "${var.enforce_tls_bucket_arn}/*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : "${var.cloudfront_distribution_arn}"
          }
        }
      },
      {
        "Sid" : "EnforceTLS",
        "Action" : "s3:*",
        "Effect" : "Deny",
        "Principal" : "*",
        "Resource" : [
          "${var.enforce_tls_bucket_arn}",
          "${var.enforce_tls_bucket_arn}/*"
        ],
        "Condition" : {
          "Bool" : {
            "aws:SecureTransport" : "false"
          }
        }
      }
    ]
  })
}


