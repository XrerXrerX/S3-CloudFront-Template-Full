<!-- @format -->

# Changelog

All notable changes to this S3 + CloudFront Terraform configuration will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### Added

- Initial release of S3 + CloudFront CDN Terraform configuration
- S3 bucket with versioning, encryption, and lifecycle policies
- CloudFront distribution with Origin Access Control (OAC)
- CORS configuration for web applications
- IAM roles for EC2 and ECS integration
- Comprehensive documentation and examples
- Deployment script and Makefile for easy management
- Support for custom domains with ACM certificates
- Security best practices implementation

### Features

- **S3 Bucket Module**: Private bucket with comprehensive security settings
- **CloudFront Module**: Global CDN with OAC for secure S3 access
- **IAM Roles Module**: Pre-configured roles for EC2 and ECS
- **Bucket Policy Module**: Secure policy allowing only CloudFront access
- **Custom Domain Support**: Optional custom domain configuration
- **Cost Optimization**: Lifecycle policies and configurable price classes

### Security

- Private S3 bucket with public access blocked
- Origin Access Control for CloudFront
- Server-side encryption enabled
- Secure transport enforcement
- Minimal IAM permissions with prefix-based access

### Documentation

- Comprehensive README with usage examples
- Integration guides for Laravel, React, and other frameworks
- Troubleshooting section
- Best practices and cost optimization tips
- Step-by-step deployment instructions

## [Unreleased]

### Planned

- Support for multiple CloudFront distributions
- Enhanced monitoring and logging
- Backup and disaster recovery options
- Multi-region deployment support
- Advanced caching policies
- Integration with AWS WAF
