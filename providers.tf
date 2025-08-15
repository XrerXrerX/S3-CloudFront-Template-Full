# Configure the AWS Provider
provider "aws" {
  region = var.region
  
  # Uncomment and configure if you want to use a specific AWS profile
  # profile = "default"
  
  # Uncomment and configure if you want to use specific AWS credentials
  # access_key = "your-access-key"
  # secret_key = "your-secret-key"
  
  # Uncomment if you want to use shared credentials file
  # shared_credentials_files = ["~/.aws/credentials"]
  
  # Uncomment if you want to use config file
  # shared_config_files = ["~/.aws/config"]
  
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.env
      ManagedBy   = "terraform"
    }
  }
}

# Provider for ACM certificates (must be in us-east-1 for CloudFront)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  
  # Uncomment and configure if you want to use a specific AWS profile
  # profile = "default"
  
  # Uncomment and configure if you want to use specific AWS credentials
  # access_key = "your-access-key"
  # secret_key = "your-secret-key"
}
