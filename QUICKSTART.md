<!-- @format -->

# 🚀 Quick Start Guide

Setup S3 + CloudFront dalam 5 menit!

## 📋 Prerequisites

- ✅ AWS CLI installed
- ✅ Terraform >= 1.0
- ✅ AWS credentials dengan permission S3, CloudFront, IAM

## ⚡ Super Quick Setup

### 1. Setup

```bash
cd s3-cloudfront
make setup
```

### 2. Setup AWS Credentials

```bash
# Setup AWS credentials
make aws-setup
# atau
./setup-aws.sh
```

### 3. Edit Configuration

```bash
# Edit terraform.tfvars dengan detail project Anda
nano terraform.tfvars
```

### 4. Deploy

```bash
make deploy
# atau
./deploy.sh
```

### 5. Test

```bash
make test
# atau
./test.sh
```

## 🎯 What You Get

- 🔒 **S3 Bucket**: Private, encrypted, versioned
- 🌐 **CloudFront CDN**: Global content delivery
- 👤 **IAM Roles**: Ready for EC2/ECS
- 🛡️ **Security**: OAC, encryption, CORS

## 📤 Outputs

Setelah deployment, Anda akan mendapatkan:

```bash
terraform output
```

- `s3_bucket_name` - Nama bucket S3
- `cloudfront_domain_name` - Domain CloudFront
- `cdn_url` - URL CDN lengkap

## 🔗 Integration

### Laravel (.env)

```env
AWS_DEFAULT_REGION=ap-southeast-1
AWS_BUCKET=your-bucket-name
AWS_URL=https://your-cloudfront-domain.cloudfront.net
```

### JavaScript Upload

```javascript
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";

const s3Client = new S3Client({
  region: "ap-southeast-1",
  credentials: {
    /* your credentials */
  },
});

const uploadFile = async (file, key) => {
  const command = new PutObjectCommand({
    Bucket: "your-bucket-name",
    Key: `users/${key}`,
    Body: file,
    ContentType: file.type,
  });

  await s3Client.send(command);
  return `https://your-cloudfront-domain.cloudfront.net/users/${key}`;
};
```

## 🛠️ Useful Commands

```bash
# Check status
make status

# Show costs
make costs

# Show security features
make security

# Show documentation
make docs

# Cleanup (⚠️ destroys everything)
make destroy
# atau
./destroy.sh
```

## 💰 Cost Estimation

**Monthly (normal usage):**

- S3 Storage (100GB): ~$2.30
- CloudFront Requests (1M): ~$0.75
- CloudFront Data Transfer (50GB): ~$4.50
- **Total: ~$7.55/month**

## 🆘 Need Help?

1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Run `make test` to diagnose issues
3. Review [README.md](README.md) for detailed docs

## 🎉 Done!

Your S3 + CloudFront setup is ready! Use the CloudFront URL to serve your assets globally.
