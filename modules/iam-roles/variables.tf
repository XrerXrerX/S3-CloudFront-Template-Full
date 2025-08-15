variable "bucket_arn" {
  type = string
  description = "S3 bucket ARN"
}

variable "allowed_prefixes" {
  type = list(string)
  default = [
    "users/*",
    "public/*"
  ]
  description = "S3 prefixes that EC2/ECS instances can access"
}

variable "enable_ec2" {
  type    = bool
  default = true
  description = "Enable EC2 instance profile creation"
}

variable "enable_ecs" {
  type    = bool
  default = true
  description = "Enable ECS task and execution roles creation"
}

variable "tags" {
  type    = map(string)
  default = {}
}
