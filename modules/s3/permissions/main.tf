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

resource "aws_s3_bucket_policy" "oac" {
  bucket = var.oac_bucket_id

  policy = jsonencode({
    "Version" : "2008-10-17",
    "Id" : "PolicyForCloudFrontPrivateContent",
    "Statement" : [
      {
        "Sid" : "AllowCloudFrontServicePrincipalOAC",
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
