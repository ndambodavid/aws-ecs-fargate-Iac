output "bucket_id" {
  description = "The ID (name) of the S3 bucket."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = aws_s3_bucket.this.arn
}

output "bucket_path" {
  description = "The S3 path (URI) to the key prefix folder."
  value       = "s3://${aws_s3_bucket.this.bucket}/${var.key_prefix}"
}
