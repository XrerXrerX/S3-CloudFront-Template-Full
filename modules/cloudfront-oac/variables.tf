variable "origin_domain_name" {
  type = string
  description = "S3 bucket regional domain name"
}

variable "aliases" {
  type    = list(string)
  default = []
  description = "Custom domain aliases (optional)"
}

variable "acm_certificate_arn" {
  type    = string
  default = ""
  description = "ACM certificate ARN in us-east-1 region if aliases used"
}

variable "price_class" {
  type    = string
  default = "PriceClass_200"
  description = "CloudFront price class"
}

variable "tags" {
  type    = map(string)
  default = {}
}
