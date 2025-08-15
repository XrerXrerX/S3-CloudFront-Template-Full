# IAM User for Laravel S3 Access
resource "aws_iam_user" "laravel" {
  name = "${var.project}-${var.env}-laravel-s3-user"
  path = "/system/"

  tags = merge(var.tags, {
    Purpose = "Laravel S3 Access"
  })
}

# IAM Access Key for Laravel
resource "aws_iam_access_key" "laravel" {
  user = aws_iam_user.laravel.name
}

# IAM Policy for Laravel S3 Access
resource "aws_iam_policy" "laravel_s3_access" {
  name        = "${var.project}-${var.env}-laravel-s3-policy"
  description = "Policy for Laravel to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LaravelS3BucketAccess"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [var.bucket_arn]
      },
      {
        Sid    = "LaravelS3ObjectAccess"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObjectAcl",
          "s3:GetObjectAcl"
        ]
        Resource = ["${var.bucket_arn}/*"]
      }
    ]
  })

  tags = merge(var.tags, {
    Purpose = "Laravel S3 Policy"
  })
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "laravel_s3_policy" {
  user       = aws_iam_user.laravel.name
  policy_arn = aws_iam_policy.laravel_s3_access.arn
}

# IAM Group for Laravel (optional, for better organization)
resource "aws_iam_group" "laravel" {
  name = "${var.project}-${var.env}-laravel-group"
  path = "/system/"
}

# Add user to group
resource "aws_iam_user_group_membership" "laravel" {
  user   = aws_iam_user.laravel.name
  groups = [aws_iam_group.laravel.name]
}

# Attach policy to group as well
resource "aws_iam_group_policy_attachment" "laravel_s3_policy" {
  group      = aws_iam_group.laravel.name
  policy_arn = aws_iam_policy.laravel_s3_access.arn
}
