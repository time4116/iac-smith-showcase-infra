# kinesis-firehose-s3-pipeline

Declares the following resources:

* `aws_kinesis_stream.data_stream`
* `aws_s3_bucket.delivery_bucket`
* `aws_s3_bucket_versioning.delivery_bucket_versioning`
* `aws_s3_bucket_server_side_encryption_configuration.delivery_bucket_encryption`
* `aws_s3_bucket_public_access_block.delivery_bucket_public_access_block`
* `aws_cloudwatch_log_group.firehose_log_group`
* `aws_cloudwatch_log_stream.firehose_error_log_stream`
* `aws_iam_role.firehose_role`
* `aws_iam_role_policy.firehose_kinesis_read_policy`
* `aws_iam_role_policy.firehose_s3_write_policy`
* `aws_iam_role_policy.firehose_cloudwatch_logs_policy`
* `aws_kinesis_firehose_delivery_stream.s3_delivery_stream`

## Inputs

| Name | Type |
|---|---|
| `environment` | `string` |

The root-generated AWS provider supplies the region. This standalone module does
not use a VPC or depend on foundation state. The delivery stream waits for its
three IAM policies and bucket hardening resources before creation.

## Outputs

| Name | Description |
|---|---|
| `spec_summary` | Human-readable summary of the rendered infrastructure spec. |
| `kinesis_stream_name` | Name of the Kinesis data stream |
| `kinesis_stream_arn` | ARN of the Kinesis data stream |
| `delivery_bucket_name` | Name of the S3 delivery bucket |
| `firehose_delivery_stream_name` | Name of the Kinesis Data Firehose delivery stream |
