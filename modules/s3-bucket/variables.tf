variable "bucket_name" {
  type = string
}

variable "cors_allowed_origins" {
  type = list(string)
}

variable "lifecycle_days" {
  type    = number
  default = 30
}

variable "enable_versioning" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
