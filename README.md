# AWS CloudFront OAC OAI

AWS CloudFront S3 origina with OAC and OAI.

As per the current [documentation][1], **OAC** authenticated requests supports:

- All Amazon S3 buckets in all AWS Regions, including opt-in Regions launched after December 2022
- Amazon S3 [server-side encryption][2] with AWS KMS (SSE-KMS)
- Dynamic requests (PUT and DELETE) to Amazon S3

First, create a key pair for the CloudFront signed URL stuff ([ref1][6], [ref2][5]):

```sh
mkdir keys
openssl genrsa -des3 -out keys/private.pem 2048
openssl rsa -in keys/private.pem -outform PEM -pubout -out keys/public.pem
```

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
- [CloudFront Signed URLs][7]

### S3 presigned URLs

You can generate a presigned URL which will use the credentials of the user who generated the URLs. This would be useful for users who do not have access to the account with AWS credentials ("anonymous").

Generate a presigned URL, open an anonymous browser session and use the link to access the object:

```sh
# For regions launched prior to 2019
aws s3 presign s3://bucket-presignedurl-vouchers010203/vouchers/voucher.txt --expires-in 604800
```

### CloudFront Signed URLs

Signed URLs are more secure and offer additional controls with [canned policies][8] but specially with [custom policies][9].

Edit the [`policy.json`](policyjson) file accordingly, and generate the signature:

```sh
cat policy | tr -d "\n" | tr -d " \t\n\r" | openssl sha1 -sign keys/private.pem | openssl base64 -A | tr -- '+=/' '-_~'
```

The signed URL will look like this:

```
https://ddddddd00001111.cloudfront.net/vouchers/voucher.txt?Expires=1698637841&Signature=<SIGNATURE>&Key-Pair-Id=KQPALV128937
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
[5]: https://rietta.com/blog/openssl-generating-rsa-key-from-command/
[6]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-trusted-signers.html#choosing-key-groups-or-AWS-accounts
[7]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-signed-urls.html
[8]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-creating-signed-url-canned-policy.html
[9]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-creating-signed-url-custom-policy.html
