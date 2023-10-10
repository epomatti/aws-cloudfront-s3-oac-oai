# AWS CloudFront OAC OAI

AWS CloudFront S3 origina with OAC and OAI.

As per the current [documentation][1], **OAC** authenticated requests supports:

- All Amazon S3 buckets in all AWS Regions, including opt-in Regions launched after December 2022
- Amazon S3 [server-side encryption][2] with AWS KMS (SSE-KMS)
- Dynamic requests (PUT and DELETE) to Amazon S3

To create the infrastructure:

```sh
terraform init
terraform apply -auto-approve
```

As described in the [S3 origin documentation][3], S3 regional domains should be used:

```sh
# Use the regional bucket domain
<bucket-name>.s3.<region>.amazonaws.com
```

For server-side encryption (SSE) The implementation enabled `aws:kms` (SSE-KMS) encryption for OAC, and `AES256` (SSE-S3)for OAI.

To test the distribution access the endpoints on paths `/oac` and `/oai` respectively.

Policy implementation between the two authentication methods differ:

| Policy | OAC | OAI |
|-|-|-|
| Principal | `cloudfront.amazonaws.com` | OAI identity id |
| Condition | `AWS:SourceArn` with the distribution ARN | n/a|

## Sharing Objects with URLs

There are two types of share with URLs:

- [S3 presigned URLs][4]
- CloudFront Signed URLs

### S3 presigned URLs

You can generate a presigned URL which will use the credentials of the user who generated the URLs. This would be useful for users who do not have access to the account with AWS credentials ("anonymous").

Generate a presigned URL, open an anonymous browser session and use the link to access the object:

```sh
# For regions launched prior to 2019
aws s3 presign s3://bucket-presignedurl-vouchers010203/vouchers/voucher.txt --expires-in 604800
```



---

### Clean-up

Destroy the resources when you're done using it:

```sh
terraform destroy -auto-approve
```

[1]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html
[2]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html
[3]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/DownloadDistS3AndCustomOrigins.html#using-s3-as-origin
[4]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/ShareObjectPreSignedURL.html
