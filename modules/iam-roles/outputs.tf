output "ec2_instance_profile_name" {
  value       = try(aws_iam_instance_profile.ec2_profile[0].name, null)
  description = "Attach to EC2 instances (if enable_ec2=true)"
}

output "ecs_task_role_arn" {
  value       = try(aws_iam_role.ecs_task_role[0].arn, null)
  description = "Use as taskRoleArn in ECS task definitions"
}

output "ecs_execution_role_arn" {
  value       = try(aws_iam_role.ecs_execution_role[0].arn, null)
  description = "Use as executionRoleArn in ECS task definitions"
}
