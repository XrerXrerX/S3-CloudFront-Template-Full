<!-- @format -->

# Contributing to S3 + CloudFront Terraform Configuration

Thank you for your interest in contributing to this project! This document provides guidelines and information for contributors.

## How to Contribute

### Reporting Issues

Before creating an issue, please:

1. Check if the issue has already been reported
2. Search existing issues and pull requests
3. Provide detailed information about the problem

When reporting an issue, please include:

- Terraform version
- AWS provider version
- Operating system
- Steps to reproduce the issue
- Expected vs actual behavior
- Error messages (if any)

### Suggesting Enhancements

We welcome suggestions for new features and improvements. When suggesting enhancements:

1. Describe the feature or improvement
2. Explain why it would be useful
3. Provide examples of how it would work
4. Consider the impact on existing functionality

### Submitting Pull Requests

When submitting a pull request:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test your changes thoroughly
5. Update documentation if needed
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Code Style Guidelines

- Use consistent indentation (2 spaces)
- Follow Terraform best practices
- Add comments for complex logic
- Use meaningful variable and resource names
- Include descriptions for outputs and variables
- Test your changes before submitting

### Testing

Before submitting changes:

1. Run `terraform validate` to check syntax
2. Run `terraform plan` to verify the configuration
3. Test in a non-production environment
4. Ensure all modules work together correctly

### Documentation

When adding new features:

1. Update the README.md if needed
2. Add examples to terraform.tfvars.example
3. Update the CHANGELOG.md
4. Add comments to explain complex configurations

## Development Setup

1. Clone the repository
2. Copy `terraform.tfvars.example` to `terraform.tfvars`
3. Configure your AWS credentials
4. Customize the variables for your environment
5. Run `terraform init` to initialize

## Questions or Need Help?

If you have questions or need help:

1. Check the README.md for documentation
2. Search existing issues
3. Create a new issue with the "question" label

## Code of Conduct

This project is committed to providing a welcoming and inclusive environment for all contributors. Please be respectful and considerate of others.

## License

By contributing to this project, you agree that your contributions will be licensed under the MIT License.
