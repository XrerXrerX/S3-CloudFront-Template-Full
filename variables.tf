variable "project" {
  type    = string
  default = "yourapp"
}

variable "env" {
  type    = string
  default = "prod"
}

variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "bucket_name" {
  type    = string
  default = "img-yourapp-prod-ap-southeast-1"
}

variable "cors_allowed_origins" {
  type        = list(string)
  description = "List of allowed origins for CORS"
  default = [
    "http://localhost:3000",
    "http://localhost:8000",
    "http://localhost:5050",
    "https://staging.myapp.com",
    "https://myapp.com"
  ]
}

variable "price_class" {
  type    = string
  default = "PriceClass_200"
}

# S3 Bucket Configuration
variable "lifecycle_days" {
  type    = number
  default = 30
}

variable "enable_versioning" {
  type    = bool
  default = true
}

# CloudFront Configuration
variable "aliases" {
  type    = list(string)
  default = []
}

variable "acm_certificate_arn" {
  type    = string
  default = ""
}

# IAM Configuration
variable "allowed_prefixes" {
  type = list(string)
  default = [
    "users/*",
    "public/*"
  ]
}

# Toggle sesuai compute yang kamu pakai
variable "enable_ec2" {
  type    = bool
  default = true
}

variable "enable_ecs" {
  type    = bool
  default = true
}
