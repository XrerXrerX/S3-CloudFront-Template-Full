<!-- @format -->

# Troubleshooting Guide

This guide helps you resolve common issues when using the S3 + CloudFront Terraform configuration.

## Common Issues

### 1. Bucket Name Already Exists

**Error**: `Error: failed to create S3 bucket: BucketAlreadyExists`

**Solution**:

- Change the `bucket_name` in `terraform.tfvars`
- Bucket names must be globally unique across all AWS accounts
- Use your domain name or add a unique identifier

```hcl
bucket_name = "myapp-assets-dev-2024-ap-southeast-1"
```

### 2. CORS Errors in Browser

**Error**: `Access to fetch at 'https://bucket.s3.amazonaws.com' from origin 'http://localhost:3000' has been blocked by CORS policy`

**Solution**:

- Add your domain to `cors_allowed_origins` in `terraform.tfvars`
- Ensure the origin includes the protocol (http/https)

```hcl
cors_allowed_origins = [
  "https://myapp.com",
  "http://localhost:3000",
  "http://localhost:5173"
]
```

### 3. Permission Denied Errors

**Error**: `Access Denied` when trying to upload to S3

**Solution**:

- Ensure IAM roles are properly attached to your EC2/ECS instances
- Check that the `allowed_prefixes` include the path you're trying to access
- Verify AWS credentials are configured correctly

### 4. CloudFront Distribution Not Working

**Error**: Files not loading from CloudFront URL

**Solution**:

- Wait for CloudFront distribution to deploy (can take 15-30 minutes)
- Check that the S3 bucket policy allows CloudFront access
- Verify the origin domain name is correct

### 5. Custom Domain Not Working

**Error**: Custom domain returns SSL errors or doesn't load

**Solution**:

- Ensure ACM certificate is in `us-east-1` region
- Verify certificate is validated and active
- Check DNS records point to CloudFront distribution
- Wait for DNS propagation (can take up to 48 hours)

### 6. Terraform State Issues

**Error**: `Error: No such resource` or state conflicts

**Solution**:

- Run `terraform refresh` to sync state
- Check for manual changes to resources
- Use `terraform import` if resources were created manually
- Consider using remote state storage for team environments

### 7. Provider Version Conflicts

**Error**: `Error: incompatible provider version`

**Solution**:

- Update the AWS provider version in `versions.tf`
- Run `terraform init -upgrade`
- Check for breaking changes in provider updates

### 8. IAM Role Creation Fails

**Error**: `Error: failed to create IAM role`

**Solution**:

- Check if role names already exist
- Ensure you have IAM permissions to create roles
- Verify role names follow AWS naming conventions

## Debugging Commands

### Check Terraform Configuration

```bash
terraform validate
terraform plan
```

### Check AWS Resources

```bash
# List S3 buckets
aws s3 ls

# Check CloudFront distributions
aws cloudfront list-distributions

# Check IAM roles
aws iam list-roles --query 'Roles[?contains(RoleName, `ec2-app-role`) || contains(RoleName, `ecs-task-app-role`)].RoleName'
```

### Test S3 Access

```bash
# Test bucket access
aws s3 ls s3://your-bucket-name/

# Test file upload
aws s3 cp test.txt s3://your-bucket-name/test.txt
```

### Check CloudFront Status

```bash
# Get distribution status
aws cloudfront get-distribution --id E1234567890ABC

# Create invalidation
aws cloudfront create-invalidation --distribution-id E1234567890ABC --paths "/*"
```

## Performance Issues

### Slow CloudFront Performance

- Check if files are being cached properly
- Verify cache headers are set correctly
- Consider using cache invalidation for updated files

### High S3 Costs

- Review lifecycle policies
- Check for unnecessary file versions
- Monitor storage usage and access patterns

## Security Issues

### Unauthorized Access

- Review IAM policies and roles
- Check S3 bucket policy
- Verify CloudFront origin access control
- Monitor CloudTrail logs

### SSL/TLS Issues

- Ensure ACM certificate is valid
- Check certificate expiration dates
- Verify DNS configuration for custom domains

## Getting Help

If you're still experiencing issues:

1. Check the [README.md](README.md) for detailed documentation
2. Review the [CHANGELOG.md](CHANGELOG.md) for known issues
3. Search existing GitHub issues
4. Create a new issue with detailed information:
   - Terraform version
   - AWS provider version
   - Error messages
   - Steps to reproduce
   - Expected vs actual behavior

## Useful Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [AWS CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [AWS IAM Documentation](https://docs.aws.amazon.com/iam/)
