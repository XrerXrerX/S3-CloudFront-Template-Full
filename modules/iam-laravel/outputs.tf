output "user_name" {
  description = "Name of the Laravel IAM user"
  value       = aws_iam_user.laravel.name
}

output "user_arn" {
  description = "ARN of the Laravel IAM user"
  value       = aws_iam_user.laravel.arn
}

output "access_key_id" {
  description = "Access key ID for Laravel"
  value       = aws_iam_access_key.laravel.id
  sensitive   = true
}

output "secret_access_key" {
  description = "Secret access key for Laravel"
  value       = aws_iam_access_key.laravel.secret
  sensitive   = true
}

output "policy_arn" {
  description = "ARN of the Laravel S3 policy"
  value       = aws_iam_policy.laravel_s3_access.arn
}

output "group_name" {
  description = "Name of the Laravel IAM group"
  value       = aws_iam_group.laravel.name
}
