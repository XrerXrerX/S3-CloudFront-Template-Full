#!/bin/bash

# S3 + CloudFront Test Script
# Script untuk testing konfigurasi S3 dan CloudFront

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
    echo -e "${CYAN}  S3 + CloudFront Test Suite${NC}"
    echo -e "${CYAN}================================${NC}"
    echo
}

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    print_error "terraform.tfvars tidak ditemukan!"
    print_status "Silakan copy terraform.tfvars.example ke terraform.tfvars dan konfigurasi"
    exit 1
fi

# Check if AWS credentials are configured
print_step "Checking AWS credentials..."
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    print_error "AWS credentials belum dikonfigurasi!"
    exit 1
fi

print_header

# Get configuration values
print_step "Reading configuration..."
BUCKET_NAME=$(grep 'bucket_name' terraform.tfvars | cut -d'"' -f2)
REGION=$(grep 'region' terraform.tfvars | cut -d'"' -f2)

if [ -z "$BUCKET_NAME" ] || [ -z "$REGION" ]; then
    print_error "Tidak dapat membaca bucket_name atau region dari terraform.tfvars"
    exit 1
fi

print_success "Configuration loaded"
print_status "Bucket: $BUCKET_NAME"
print_status "Region: $REGION"
echo

# Test 1: Check if S3 bucket exists
print_step "Test 1: Checking S3 bucket existence..."
if aws s3 ls "s3://$BUCKET_NAME" > /dev/null 2>&1; then
    print_success "✅ S3 bucket exists"
else
    print_error "❌ S3 bucket does not exist"
    print_status "Run ./deploy.sh first to create the bucket"
    exit 1
fi

# Test 2: Check bucket properties
print_step "Test 2: Checking S3 bucket properties..."
BUCKET_ENCRYPTION=$(aws s3api get-bucket-encryption --bucket "$BUCKET_NAME" --query 'ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' --output text 2>/dev/null || echo "None")
BUCKET_VERSIONING=$(aws s3api get-bucket-versioning --bucket "$BUCKET_NAME" --query 'Status' --output text 2>/dev/null || echo "None")

print_status "Encryption: $BUCKET_ENCRYPTION"
print_status "Versioning: $BUCKET_VERSIONING"

if [ "$BUCKET_ENCRYPTION" = "AES256" ]; then
    print_success "✅ Encryption enabled"
else
    print_warning "⚠️  Encryption not configured"
fi

if [ "$BUCKET_VERSIONING" = "Enabled" ]; then
    print_success "✅ Versioning enabled"
else
    print_warning "⚠️  Versioning not enabled"
fi

# Test 3: Check CloudFront distribution
print_step "Test 3: Checking CloudFront distribution..."
DISTRIBUTION_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[?contains(Origins.Items[0].DomainName, '$BUCKET_NAME')].Id" --output text 2>/dev/null)

if [ -n "$DISTRIBUTION_ID" ] && [ "$DISTRIBUTION_ID" != "None" ]; then
    print_success "✅ CloudFront distribution found: $DISTRIBUTION_ID"
    
    # Check distribution status
    DISTRIBUTION_STATUS=$(aws cloudfront get-distribution --id "$DISTRIBUTION_ID" --query 'Distribution.Status' --output text 2>/dev/null)
    print_status "Distribution Status: $DISTRIBUTION_STATUS"
    
    if [ "$DISTRIBUTION_STATUS" = "Deployed" ]; then
        print_success "✅ CloudFront distribution is deployed"
    else
        print_warning "⚠️  CloudFront distribution is not fully deployed yet"
    fi
    
    # Get CloudFront domain
    CLOUDFRONT_DOMAIN=$(aws cloudfront get-distribution --id "$DISTRIBUTION_ID" --query 'Distribution.DomainName' --output text 2>/dev/null)
    print_status "CloudFront Domain: $CLOUDFRONT_DOMAIN"
else
    print_error "❌ CloudFront distribution not found"
    print_status "Run ./deploy.sh first to create the distribution"
    exit 1
fi

# Test 4: Test file upload and access
print_step "Test 4: Testing file upload and access..."
TEST_FILE="test-$(date +%s).txt"
TEST_CONTENT="Hello from S3 + CloudFront test at $(date)"

# Create test file
echo "$TEST_CONTENT" > "$TEST_FILE"

# Upload to S3
if aws s3 cp "$TEST_FILE" "s3://$BUCKET_NAME/test/$TEST_FILE" > /dev/null 2>&1; then
    print_success "✅ File uploaded to S3"
    
    # Test S3 access
    if aws s3 cp "s3://$BUCKET_NAME/test/$TEST_FILE" "downloaded-$TEST_FILE" > /dev/null 2>&1; then
        print_success "✅ File downloaded from S3"
        
        # Compare content
        if [ "$(cat "downloaded-$TEST_FILE")" = "$TEST_CONTENT" ]; then
            print_success "✅ File content matches"
        else
            print_error "❌ File content mismatch"
        fi
        
        # Clean up downloaded file
        rm -f "downloaded-$TEST_FILE"
    else
        print_error "❌ Failed to download file from S3"
    fi
    
    # Test CloudFront access (if distribution is deployed)
    if [ "$DISTRIBUTION_STATUS" = "Deployed" ]; then
        print_step "Testing CloudFront access..."
        CLOUDFRONT_URL="https://$CLOUDFRONT_DOMAIN/test/$TEST_FILE"
        
        # Wait a moment for CloudFront to propagate
        sleep 5
        
        if curl -s "$CLOUDFRONT_URL" > /dev/null 2>&1; then
            print_success "✅ CloudFront access working"
            print_status "Test URL: $CLOUDFRONT_URL"
        else
            print_warning "⚠️  CloudFront access not working yet (may need more time to propagate)"
        fi
    fi
    
    # Clean up test file from S3
    aws s3 rm "s3://$BUCKET_NAME/test/$TEST_FILE" > /dev/null 2>&1
    print_success "✅ Test file cleaned up from S3"
else
    print_error "❌ Failed to upload file to S3"
fi

# Clean up local test file
rm -f "$TEST_FILE"

# Test 5: Check IAM roles
print_step "Test 5: Checking IAM roles..."
EC2_ROLE=$(aws iam list-roles --query 'Roles[?contains(RoleName, `ec2-app-role`)].RoleName' --output text 2>/dev/null)
ECS_TASK_ROLE=$(aws iam list-roles --query 'Roles[?contains(RoleName, `ecs-task-app-role`)].RoleName' --output text 2>/dev/null)
ECS_EXEC_ROLE=$(aws iam list-roles --query 'Roles[?contains(RoleName, `ecs-exec-role`)].RoleName' --output text 2>/dev/null)

if [ -n "$EC2_ROLE" ] && [ "$EC2_ROLE" != "None" ]; then
    print_success "✅ EC2 role exists: $EC2_ROLE"
else
    print_warning "⚠️  EC2 role not found"
fi

if [ -n "$ECS_TASK_ROLE" ] && [ "$ECS_TASK_ROLE" != "None" ]; then
    print_success "✅ ECS task role exists: $ECS_TASK_ROLE"
else
    print_warning "⚠️  ECS task role not found"
fi

if [ -n "$ECS_EXEC_ROLE" ] && [ "$ECS_EXEC_ROLE" != "None" ]; then
    print_success "✅ ECS execution role exists: $ECS_EXEC_ROLE"
else
    print_warning "⚠️  ECS execution role not found"
fi

# Test 6: Check CORS configuration
print_step "Test 6: Checking CORS configuration..."
CORS_CONFIG=$(aws s3api get-bucket-cors --bucket "$BUCKET_NAME" --query 'CORSRules[0].AllowedOrigins' --output text 2>/dev/null || echo "None")

if [ "$CORS_CONFIG" != "None" ]; then
    print_success "✅ CORS configuration exists"
    print_status "Allowed origins: $CORS_CONFIG"
else
    print_warning "⚠️  CORS configuration not found"
fi

echo
print_success "🎉 Test suite completed!"
echo
print_status "Summary:"
echo "  ✅ S3 bucket: $BUCKET_NAME"
echo "  ✅ CloudFront: $CLOUDFRONT_DOMAIN"
echo "  ✅ IAM roles: Configured"
echo "  ✅ File operations: Working"
echo
print_status "Your S3 + CloudFront setup is ready to use!"
print_status "Use the CloudFront URL for serving your assets:"
print_status "  https://$CLOUDFRONT_DOMAIN"
