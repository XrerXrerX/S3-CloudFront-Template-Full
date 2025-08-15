output "bucket" {
  value = aws_s3_bucket.this.bucket
  description = "S3 bucket name"
}

output "bucket_id" {
  value = aws_s3_bucket.this.id
  description = "S3 bucket ID"
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
  description = "S3 bucket ARN"
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.this.bucket_regional_domain_name
  description = "S3 bucket regional domain name"
}
