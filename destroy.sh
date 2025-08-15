#!/bin/bash

# S3 + CloudFront Destroy Script
# Script untuk menghapus semua resource yang dibuat

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
    echo -e "${CYAN}  S3 + CloudFront Cleanup${NC}"
    echo -e "${CYAN}================================${NC}"
    echo
}

print_header

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    print_error "terraform.tfvars tidak ditemukan!"
    print_status "Pastikan Anda berada di direktori yang benar"
    exit 1
fi

# Check if AWS credentials are configured
print_step "Checking AWS credentials..."
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    print_error "AWS credentials belum dikonfigurasi!"
    exit 1
fi

# Show AWS account info
AWS_ACCOUNT=$(aws sts get-caller-identity --query 'Account' --output text)
AWS_USER=$(aws sts get-caller-identity --query 'Arn' --output text)
print_success "AWS credentials valid"
print_status "Account: $AWS_ACCOUNT"
print_status "User: $AWS_USER"
echo

# Show what will be destroyed
print_step "Resources yang akan dihapus:"
echo "  - S3 Bucket (dan semua file di dalamnya)"
echo "  - CloudFront Distribution"
echo "  - IAM Roles dan Policies"
echo "  - S3 Bucket Policy"
echo

# Multiple confirmations
print_warning "⚠️  PERHATIAN: Tindakan ini akan menghapus SEMUA resource dan data!"
echo
read -p "Apakah Anda yakin ingin menghapus semua resource? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Cleanup dibatalkan oleh user"
    exit 0
fi

echo
print_warning "⚠️  PERHATIAN: Semua file di S3 bucket akan dihapus secara permanen!"
echo
read -p "Apakah Anda sudah backup data penting? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Cleanup dibatalkan - silakan backup data terlebih dahulu"
    exit 0
fi

echo
print_warning "⚠️  PERHATIAN: Tindakan ini tidak dapat dibatalkan!"
echo
read -p "Ketik 'DELETE' untuk konfirmasi final: " -r
if [[ $REPLY != "DELETE" ]]; then
    print_warning "Cleanup dibatalkan - konfirmasi tidak valid"
    exit 0
fi

echo
print_step "Memulai cleanup..."

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    print_step "Initializing Terraform..."
    terraform init
fi

# Show what will be destroyed
print_step "Showing destroy plan..."
if terraform plan -destroy; then
    print_success "Destroy plan generated"
else
    print_error "Failed to generate destroy plan"
    exit 1
fi

# Final confirmation
echo
print_warning "⚠️  KONFIRMASI FINAL: Semua resource akan dihapus!"
echo
read -p "Lanjutkan dengan destroy? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Destroy dibatalkan oleh user"
    exit 0
fi

# Destroy resources
print_step "Destroying resources..."
if terraform destroy -auto-approve; then
    print_success "🎉 Cleanup berhasil!"
    echo
    print_status "Semua resource telah dihapus:"
    echo "  ✅ S3 Bucket"
    echo "  ✅ CloudFront Distribution"
    echo "  ✅ IAM Roles dan Policies"
    echo "  ✅ S3 Bucket Policy"
    echo
    print_status "💡 Tips: Jika Anda ingin menggunakan konfigurasi ini lagi,"
    print_status "      cukup jalankan ./deploy.sh"
else
    print_error "Destroy failed"
    exit 1
fi

# Clean up local files
echo
print_step "Cleaning up local files..."
rm -rf .terraform
rm -f .terraform.lock.hcl
rm -f *.tfstate
rm -f *.tfstate.backup
rm -f *.tfplan
print_success "Local files cleaned up"

echo
print_success "🎉 Semua resource berhasil dihapus!"
print_status "Terima kasih telah menggunakan S3 + CloudFront Terraform configuration"
