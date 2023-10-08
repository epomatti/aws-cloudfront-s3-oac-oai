# aws-cloudfront-s3-oac-oai

AWS CloudFront S3 origina with OAC and OAI.

As per current [documentation][1], **OAC** authenticated requests supports:

- All Amazon S3 buckets in all AWS Regions, including opt-in Regions launched after December 2022
- Amazon S3 [server-side encryption][2] with AWS KMS (SSE-KMS)
- Dynamic requests (PUT and DELETE) to Amazon S3



[1]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html
[2]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html