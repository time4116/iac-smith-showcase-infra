resource "aws_kinesis_stream" "data_stream" {
  name = "kinesis-firehose-pipeline-${var.environment}"
  tags = {
    Environment = var.environment
    Module      = "kinesis-firehose-s3-pipeline"
  }
  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }
}

resource "aws_s3_bucket" "delivery_bucket" {
  tags = {
    Environment = var.environment
    Module      = "kinesis-firehose-s3-pipeline"
  }
}

resource "aws_s3_bucket_versioning" "delivery_bucket_versioning" {
  bucket = aws_s3_bucket.delivery_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "delivery_bucket_encryption" {
  bucket = aws_s3_bucket.delivery_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "delivery_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.delivery_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudwatch_log_group" "firehose_log_group" {
  name              = "/aws/kinesisfirehose/kinesis-firehose-pipeline-${var.environment}"
  retention_in_days = 7
  tags = {
    Environment = var.environment
    Module      = "kinesis-firehose-s3-pipeline"
  }
}

resource "aws_cloudwatch_log_stream" "firehose_error_log_stream" {
  name           = "S3Delivery"
  log_group_name = aws_cloudwatch_log_group.firehose_log_group.name
}

resource "aws_iam_role" "firehose_role" {
  name               = "kinesis-firehose-role-${var.environment}"
  assume_role_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"firehose.amazonaws.com\"},\"Action\":\"sts:AssumeRole\"}]}"
}

resource "aws_iam_role_policy" "firehose_kinesis_read_policy" {
  name   = "firehose-kinesis-read"
  role   = aws_iam_role.firehose_role.id
  policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"kinesis:DescribeStream\",\"kinesis:GetShardIterator\",\"kinesis:GetRecords\",\"kinesis:ListRecords\",\"kinesis:ListStreams\"],\"Resource\":\"${aws_kinesis_stream.data_stream.arn}\"}]}"
}

resource "aws_iam_role_policy" "firehose_s3_write_policy" {
  name   = "firehose-s3-write"
  role   = aws_iam_role.firehose_role.id
  policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"s3:AbortMultipartUpload\",\"s3:GetBucketVersioning\",\"s3:PutObject\",\"s3:GetObject\"],\"Resource\":[\"${aws_s3_bucket.delivery_bucket.arn}\",\"${aws_s3_bucket.delivery_bucket.arn}/*\"]}]}"
}

resource "aws_iam_role_policy" "firehose_cloudwatch_logs_policy" {
  name   = "firehose-cloudwatch-logs"
  role   = aws_iam_role.firehose_role.id
  policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"logs:PutLogEvents\"],\"Resource\":\"${aws_cloudwatch_log_group.firehose_log_group.arn}:*\"}]}"
}

resource "aws_kinesis_firehose_delivery_stream" "s3_delivery_stream" {
  name        = "kinesis-firehose-s3-delivery-${var.environment}"
  destination = "extended_s3"
  tags = {
    Environment = var.environment
    Module      = "kinesis-firehose-s3-pipeline"
  }
  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose_role.arn
    bucket_arn          = aws_s3_bucket.delivery_bucket.arn
    prefix              = "data/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    error_output_prefix = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/!{firehose:error-output-type}"
    compression_format  = "GZIP"
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose_log_group.name
      log_stream_name = aws_cloudwatch_log_stream.firehose_error_log_stream.name
    }
  }
  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.data_stream.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }
}
