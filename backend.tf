# Uncomment and configure if you want to use remote state storage
# terraform {
#   backend "s3" {
#     bucket = "your-terraform-state-bucket"
#     key    = "s3-cloudfront/terraform.tfstate"
#     region = "ap-southeast-1"
#     
#     # Uncomment if you want to use DynamoDB for state locking
#     # dynamodb_table = "terraform-state-lock"
#     
#     # Uncomment if you want to encrypt the state file
#     # encrypt = true
#   }
# }

# Alternative: Local state (default)
# terraform {
#   backend "local" {}
# }
