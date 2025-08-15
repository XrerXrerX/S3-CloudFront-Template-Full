locals { 
  tags = { 
    Project     = var.project, 
    Environment = var.env,
    ManagedBy   = "terraform"
  } 
}

# S3 Bucket
module "s3_bucket" {
  source = "./modules/s3-bucket"

  bucket_name             = var.bucket_name
  cors_allowed_origins    = var.cors_allowed_origins
  lifecycle_days          = var.lifecycle_days
  enable_versioning       = var.enable_versioning
  tags                    = local.tags
}

# CloudFront Distribution with OAC
module "cloudfront_oac" {
  source = "./modules/cloudfront-oac"

  origin_domain_name      = module.s3_bucket.bucket_regional_domain_name
  aliases                 = var.aliases
  acm_certificate_arn     = var.acm_certificate_arn
  price_class             = var.price_class
  tags                    = local.tags

  providers = {
    aws = aws.us_east_1
  }
}

# S3 Bucket Policy for CloudFront OAC
module "s3_bucket_policy" {
  source = "./modules/s3-bucket-policy"

  bucket_id                    = module.s3_bucket.bucket_id
  bucket_arn                   = module.s3_bucket.bucket_arn
  cloudfront_distribution_arn  = module.cloudfront_oac.distribution_arn
}

# IAM Roles for EC2/ECS
module "iam_roles" {
  source = "./modules/iam-roles"

  bucket_arn        = module.s3_bucket.bucket_arn
  allowed_prefixes  = var.allowed_prefixes
  enable_ec2        = var.enable_ec2
  enable_ecs        = var.enable_ecs
  tags              = local.tags
}

# IAM User for Laravel
module "iam_laravel" {
  source = "./modules/iam-laravel"

  project    = var.project
  env        = var.env
  bucket_arn = module.s3_bucket.bucket_arn
  tags       = local.tags
}
