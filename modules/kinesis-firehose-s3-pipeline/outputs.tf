output "spec_summary" {
  description = "Human-readable summary of the rendered infrastructure spec."
  value       = "Rendered deterministic IaC Smith structure for ${var.environment}"
}

output "kinesis_stream_name" {
  description = "Name of the Kinesis data stream"
  value       = aws_kinesis_stream.data_stream.name
}

output "kinesis_stream_arn" {
  description = "ARN of the Kinesis data stream"
  value       = aws_kinesis_stream.data_stream.arn
}

output "delivery_bucket_name" {
  description = "Name of the S3 delivery bucket"
  value       = aws_s3_bucket.delivery_bucket.id
}

output "firehose_delivery_stream_name" {
  description = "Name of the Kinesis Data Firehose delivery stream"
  value       = aws_kinesis_firehose_delivery_stream.s3_delivery_stream.name
}
