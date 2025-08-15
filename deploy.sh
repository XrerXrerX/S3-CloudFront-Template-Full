#!/bin/bash

# S3 + CloudFront Deployment Script
# Script untuk deployment otomatis S3 bucket dengan CloudFront CDN

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

print_header() {
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}  S3 + CloudFront Deployment${NC}"
    echo -e "${CYAN}================================${NC}"
    echo
}

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    print_error "terraform.tfvars tidak ditemukan!"
    print_status "Silakan copy terraform.tfvars.example ke terraform.tfvars dan konfigurasi:"
    echo "  cp terraform.tfvars.example terraform.tfvars"
    echo "  # Kemudian edit terraform.tfvars dengan detail project Anda"
    exit 1
fi

# Check if AWS credentials are configured
print_step "Checking AWS credentials..."
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    print_error "AWS credentials belum dikonfigurasi!"
    print_status "Silakan konfigurasi AWS credentials Anda:"
    echo "  aws configure"
    echo "  # Atau set environment variables:"
    echo "  export AWS_ACCESS_KEY_ID=your access key"
    echo "  export AWS_SECRET_ACCESS_KEY=your secret key"
    echo "  export AWS_DEFAULT_REGION=ap-southeast-1"
    exit 1
fi

# Show AWS account info
AWS_ACCOUNT=$(aws sts get-caller-identity --query 'Account' --output text)
AWS_USER=$(aws sts get-caller-identity --query 'Arn' --output text)
print_success "AWS credentials valid"
print_status "Account: $AWS_ACCOUNT"
print_status "User: $AWS_USER"
echo

print_header
print_status "Memulai deployment S3 + CloudFront..."

# Initialize Terraform
print_step "Initializing Terraform..."
if terraform init; then
    print_success "Terraform initialized successfully"
else
    print_error "Failed to initialize Terraform"
    exit 1
fi

# Validate configuration
print_step "Validating Terraform configuration..."
if terraform validate; then
    print_success "Configuration is valid"
else
    print_error "Configuration validation failed"
    exit 1
fi

# Format Terraform files
print_step "Formatting Terraform files..."
terraform fmt -recursive
print_success "Files formatted"

# Show plan
print_step "Showing deployment plan..."
if terraform plan; then
    print_success "Plan generated successfully"
else
    print_error "Failed to generate plan"
    exit 1
fi

# Ask for confirmation
echo
print_warning "⚠️  PERHATIAN: Deployment ini akan membuat resource AWS yang mungkin dikenakan biaya"
echo
read -p "Apakah Anda yakin ingin melanjutkan deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Deployment dibatalkan oleh user"
    exit 0
fi

# Apply changes
print_step "Applying Terraform configuration..."
if terraform apply -auto-approve; then
    print_success "Deployment completed successfully!"
else
    print_error "Deployment failed"
    exit 1
fi

# Show outputs
echo
print_step "Deployment outputs:"
terraform output

echo
print_success "🎉 Deployment berhasil!"
echo
print_status "Langkah selanjutnya:"
echo "1. Gunakan nama S3 bucket dalam konfigurasi aplikasi Anda"
echo "2. Gunakan URL CloudFront untuk serving assets"
echo "3. Pasang IAM roles ke instance EC2/ECS jika diperlukan"
echo
print_status "Untuk informasi lebih lanjut, lihat README.md"

# Show cost estimation
echo
print_warning "💰 Estimasi Biaya Bulanan (untuk penggunaan normal):"
echo "  - S3 Storage (100GB): ~$2.30"
echo "  - CloudFront Requests (1M): ~$0.75"
echo "  - CloudFront Data Transfer (50GB): ~$4.50"
echo "  - Total: ~$7.55/bulan"
echo
print_status "💡 Tips: Gunakan Intelligent Tiering dan PriceClass_200 untuk optimasi biaya"
