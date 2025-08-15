.PHONY: help init plan apply destroy validate format clean deploy test aws-setup env-setup

# Default target
help:
	@echo "Available commands:"
	@echo "  aws-setup - Setup AWS credentials"
	@echo "  env-setup - Setup AWS environment variables"
	@echo "  init     - Initialize Terraform"
	@echo "  validate - Validate Terraform configuration"
	@echo "  format   - Format Terraform files"
	@echo "  plan     - Show Terraform plan"
	@echo "  apply    - Apply Terraform configuration"
	@echo "  destroy  - Destroy all resources"
	@echo "  clean    - Clean up Terraform files"
	@echo "  deploy   - Run deployment script"
	@echo "  test     - Run test suite"
	@echo "  status   - Show current status"

# Setup AWS credentials
aws-setup:
	@echo "Setting up AWS credentials..."
	@chmod +x setup-aws.sh
	./setup-aws.sh

# Setup AWS environment variables
env-setup:
	@echo "Setting up AWS environment variables..."
	@chmod +x setup-env.sh
	./setup-env.sh

# Initialize Terraform
init:
	@echo "Initializing Terraform..."
	terraform init

# Validate configuration
validate:
	@echo "Validating Terraform configuration..."
	terraform validate

# Format Terraform files
format:
	@echo "Formatting Terraform files..."
	terraform fmt -recursive

# Show plan
plan:
	@echo "Showing Terraform plan..."
	terraform plan

# Apply configuration
apply:
	@echo "Applying Terraform configuration..."
	terraform apply -auto-approve

# Destroy all resources
destroy:
	@echo "Destroying all resources..."
	@read -p "Are you sure you want to destroy all resources? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	terraform destroy -auto-approve

# Clean up
clean:
	@echo "Cleaning up Terraform files..."
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f *.tfstate
	rm -f *.tfstate.backup
	rm -f *.tfplan

# Show outputs
output:
	@echo "Showing Terraform outputs..."
	terraform output

# Refresh state
refresh:
	@echo "Refreshing Terraform state..."
	terraform refresh

# Show resources
show:
	@echo "Showing Terraform resources..."
	terraform show

# Run deployment script
deploy:
	@echo "Running deployment script..."
	@chmod +x deploy.sh
	./deploy.sh

# Run test suite
test:
	@echo "Running test suite..."
	@chmod +x test.sh
	./test.sh

# Show current status
status:
	@echo "Checking current status..."
	@if [ -f "terraform.tfvars" ]; then \
		echo "✅ terraform.tfvars exists"; \
		BUCKET_NAME=$$(grep 'bucket_name' terraform.tfvars | cut -d'"' -f2); \
		echo "📦 Bucket: $$BUCKET_NAME"; \
	else \
		echo "❌ terraform.tfvars not found"; \
	fi
	@if [ -d ".terraform" ]; then \
		echo "✅ Terraform initialized"; \
	else \
		echo "❌ Terraform not initialized"; \
	fi
	@if [ -f "*.tfstate" ]; then \
		echo "✅ Terraform state exists"; \
	else \
		echo "❌ No Terraform state found"; \
	fi
	@if aws sts get-caller-identity > /dev/null 2>&1; then \
		echo "✅ AWS credentials configured"; \
	else \
		echo "❌ AWS credentials not configured"; \
		echo "   Run 'make aws-setup' or 'make env-setup' to configure"; \
	fi

# Quick setup
setup:
	@echo "Setting up S3 + CloudFront..."
	@if [ ! -f "terraform.tfvars" ]; then \
		cp terraform.tfvars.example terraform.tfvars; \
		echo "✅ Created terraform.tfvars from example"; \
		echo "📝 Please edit terraform.tfvars with your configuration"; \
	else \
		echo "✅ terraform.tfvars already exists"; \
	fi
	@chmod +x deploy.sh test.sh destroy.sh setup-aws.sh setup-env.sh
	@echo "✅ Made scripts executable"

# Full deployment workflow
full-deploy: setup env-setup init validate plan apply output
	@echo "🎉 Full deployment completed!"

# Quick test
quick-test: test
	@echo "✅ Quick test completed!"

# Show costs
costs:
	@echo "💰 Estimated Monthly Costs:"
	@echo "  - S3 Storage (100GB): ~$2.30"
	@echo "  - CloudFront Requests (1M): ~$0.75"
	@echo "  - CloudFront Data Transfer (50GB): ~$4.50"
	@echo "  - Total: ~$7.55/month"
	@echo ""
	@echo "💡 Tips for cost optimization:"
	@echo "  - Use Intelligent Tiering (enabled by default)"
	@echo "  - Choose appropriate PriceClass"
	@echo "  - Monitor usage with AWS Cost Explorer"

# Show security status
security:
	@echo "🔒 Security Features:"
	@echo "  ✅ Private S3 bucket (no public access)"
	@echo "  ✅ Server-side encryption (AES256)"
	@echo "  ✅ Origin Access Control (OAC)"
	@echo "  ✅ Secure transport enforcement"
	@echo "  ✅ IAM roles with minimal permissions"
	@echo "  ✅ CORS configuration for controlled access"

# Show documentation
docs:
	@echo "📚 Available Documentation:"
	@echo "  - README.md - Main documentation"
	@echo "  - QUICKSTART.md - Quick start guide"
	@echo "  - TROUBLESHOOTING.md - Common issues and solutions"
	@echo "  - COST_OPTIMIZATION.md - Cost optimization guide"
	@echo "  - SECURITY.md - Security policy"
	@echo "  - CONTRIBUTING.md - Contribution guidelines"
	@echo "  - CHANGELOG.md - Version history"
