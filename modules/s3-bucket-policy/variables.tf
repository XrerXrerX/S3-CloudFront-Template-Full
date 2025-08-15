variable "bucket_id" {
  type = string
  description = "S3 bucket ID"
}

variable "bucket_arn" {
  type = string
  description = "S3 bucket ARN"
}

variable "cloudfront_distribution_arn" {
  type = string
  description = "CloudFront distribution ARN required for OAC allow"
}
