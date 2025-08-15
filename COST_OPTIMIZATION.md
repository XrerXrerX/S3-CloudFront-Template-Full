<!-- @format -->

# Cost Optimization Guide

This guide provides strategies and best practices for optimizing costs when using the S3 + CloudFront Terraform configuration.

## Cost Components

### S3 Storage Costs

- **Standard Storage**: $0.023 per GB per month
- **Intelligent Tiering**: Automatic cost optimization
- **Lifecycle Transitions**: Reduced costs for infrequently accessed data
- **Data Transfer**: Free within same region

### CloudFront Costs

- **Data Transfer Out**: Varies by region
- **Requests**: $0.0075 per 10,000 requests
- **Price Classes**: Different coverage areas affect costs

### IAM Costs

- **Free**: IAM roles and policies are free
- **No additional charges** for the IAM configuration

## Optimization Strategies

### 1. S3 Storage Optimization

#### Use Intelligent Tiering

The configuration automatically moves files to Intelligent Tiering after 30 days:

```hcl
lifecycle_days = 30  # Adjust based on your access patterns
```

#### Optimize Lifecycle Policies

Consider different lifecycle rules for different file types:

```hcl
# Example: Different lifecycle for different prefixes
lifecycle_days = {
  "images/*"     = 90,   # Keep images longer
  "documents/*"  = 30,   # Move documents to IA sooner
  "temp/*"       = 7     # Delete temporary files quickly
}
```

#### Monitor Storage Usage

- Use AWS Cost Explorer to track S3 costs
- Set up billing alerts
- Review storage metrics regularly

### 2. CloudFront Cost Optimization

#### Choose the Right Price Class

- **PriceClass_100**: North America and Europe only (cheapest)
- **PriceClass_200**: North America, Europe, Asia, Middle East, and Africa (recommended)
- **PriceClass_All**: All locations (most expensive)

```hcl
price_class = "PriceClass_200"  # Best balance of cost and coverage
```

#### Optimize Cache Settings

- Use appropriate cache headers
- Set reasonable TTL values
- Implement cache invalidation strategies

#### Monitor Usage

- Track data transfer costs
- Monitor request patterns
- Use CloudFront analytics

### 3. Data Transfer Optimization

#### Minimize Cross-Region Transfer

- Keep S3 bucket and CloudFront in the same region
- Use regional endpoints when possible

#### Optimize File Sizes

- Compress images and files
- Use appropriate file formats
- Consider lazy loading for large files

### 4. Request Optimization

#### Reduce API Calls

- Batch operations when possible
- Use presigned URLs for direct uploads
- Implement client-side caching

#### Optimize CORS

- Only allow necessary origins
- Minimize preflight requests
- Use appropriate CORS headers

## Cost Monitoring

### Set Up Billing Alerts

```bash
# Create billing alarm (example)
aws cloudwatch put-metric-alarm \
  --alarm-name "S3-CloudFront-Cost-Alert" \
  --alarm-description "Alert when costs exceed threshold" \
  --metric-name "EstimatedCharges" \
  --namespace "AWS/Billing" \
  --statistic "Maximum" \
  --period 86400 \
  --threshold 50 \
  --comparison-operator "GreaterThanThreshold"
```

### Use AWS Cost Explorer

- Monitor daily, monthly, and yearly costs
- Analyze costs by service, region, and tags
- Set up cost allocation tags

### CloudWatch Metrics

- Monitor S3 bucket metrics
- Track CloudFront distribution performance
- Set up custom dashboards

## Best Practices

### 1. Right-Size Your Resources

- Start with minimal configuration
- Scale up based on actual usage
- Monitor and adjust regularly

### 2. Use Tags for Cost Allocation

```hcl
tags = {
  Project     = var.project
  Environment = var.env
  CostCenter  = "IT-Infrastructure"
  Owner       = "DevOps Team"
}
```

### 3. Implement Lifecycle Policies

- Automatically delete old versions
- Move infrequently accessed data to cheaper storage
- Archive old data to Glacier if needed

### 4. Optimize File Management

- Use appropriate file formats
- Compress files when possible
- Implement cleanup procedures

### 5. Monitor and Optimize

- Regular cost reviews
- Performance monitoring
- Usage pattern analysis

## Cost Estimation

### Monthly Cost Example

For a typical setup with:

- 100 GB of data
- 1 million CloudFront requests
- 50 GB data transfer

**Estimated Monthly Cost**:

- S3 Storage: ~$2.30
- CloudFront Requests: ~$0.75
- CloudFront Data Transfer: ~$4.50
- **Total: ~$7.55/month**

### Cost Reduction Tips

1. **Use Intelligent Tiering**: Can reduce storage costs by 40-60%
2. **Optimize Price Class**: Choose appropriate CloudFront coverage
3. **Implement Lifecycle Policies**: Automatically manage data lifecycle
4. **Monitor Usage**: Regular monitoring helps identify optimization opportunities
5. **Use Reserved Capacity**: For predictable workloads

## Tools and Resources

### AWS Cost Management Tools

- AWS Cost Explorer
- AWS Budgets
- AWS Cost and Usage Reports
- AWS Cost Anomaly Detection

### Third-Party Tools

- CloudHealth
- CloudCheckr
- AWS Cost Optimization Tools

### Documentation

- [AWS S3 Pricing](https://aws.amazon.com/s3/pricing/)
- [AWS CloudFront Pricing](https://aws.amazon.com/cloudfront/pricing/)
- [AWS Cost Optimization](https://aws.amazon.com/cost-optimization/)

## Regular Review Schedule

### Weekly

- Check billing alerts
- Review CloudWatch metrics
- Monitor usage patterns

### Monthly

- Analyze cost reports
- Review and optimize lifecycle policies
- Update cost allocation tags

### Quarterly

- Comprehensive cost review
- Performance optimization
- Architecture review for cost efficiency

## Emergency Cost Control

If costs exceed expectations:

1. **Immediate Actions**:

   - Review recent changes
   - Check for unusual usage patterns
   - Implement cost controls

2. **Short-term**:

   - Optimize lifecycle policies
   - Reduce CloudFront price class
   - Implement stricter access controls

3. **Long-term**:
   - Architecture review
   - Consider alternative solutions
   - Implement cost governance policies
