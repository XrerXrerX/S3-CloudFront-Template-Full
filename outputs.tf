output "aws_default_region" {
  value       = var.region
  description = "Use as AWS_DEFAULT_REGION in Laravel .env"
}

# S3 Bucket Outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3_bucket.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3_bucket.bucket_arn
}

output "s3_bucket_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = module.s3_bucket.bucket_regional_domain_name
}

# CloudFront Outputs
output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = module.cloudfront_oac.distribution_id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = module.cloudfront_oac.domain_name
}

output "cdn_url" {
  description = "CDN URL for accessing files"
  value       = "https://${module.cloudfront_oac.domain_name}"
}

# IAM Laravel Outputs
output "laravel_user_name" {
  description = "Name of the Laravel IAM user"
  value       = module.iam_laravel.user_name
}

output "laravel_access_key_id" {
  description = "Access key ID for Laravel"
  value       = module.iam_laravel.access_key_id
  sensitive   = true
}

output "laravel_secret_access_key" {
  description = "Secret access key for Laravel"
  value       = module.iam_laravel.secret_access_key
  sensitive   = true
}

output "laravel_policy_arn" {
  description = "ARN of the Laravel S3 policy"
  value       = module.iam_laravel.policy_arn
}

# IAM Roles Outputs
output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = module.iam_roles.ec2_instance_profile_name
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = module.iam_roles.ecs_task_role_arn
}

output "ecs_execution_role_arn" {
  description = "ARN of the ECS execution role"
  value       = module.iam_roles.ecs_execution_role_arn
}
