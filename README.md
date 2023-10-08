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

To test the distribution access the endpoints on paths `/oac` and `/oai` respectively.

Policy implementation between the two authentication methods differ:

| Policy | OAC | OAI |
|-|-|-|
| Principal | `cloudfront.amazonaws.com` | OAI identity id |
| Condition | `AWS:SourceArn` with the distribution ARN | n/a|


[1]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html
[2]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html