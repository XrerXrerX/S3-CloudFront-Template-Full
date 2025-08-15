# App policy (S3 limited prefixes)
data "aws_iam_policy_document" "app_permissions" {
  statement {
    sid     = "ListBucketWithPrefix"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = [var.bucket_arn]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = var.allowed_prefixes
    }
  }
  statement {
    sid     = "CRUDWithinPrefixes"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts"
    ]
    resources = [for p in var.allowed_prefixes : "${var.bucket_arn}/${p}"]
  }
}

resource "aws_iam_policy" "app_s3_policy" {
  name        = "app-s3-prefix-policy"
  description = "Minimal S3 access scoped to prefixes"
  policy      = data.aws_iam_policy_document.app_permissions.json
}

# ---- EC2 ROLE (optional) ----
data "aws_iam_policy_document" "ec2_trust" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  count              = var.enable_ec2 ? 1 : 0
  name               = "ec2-app-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ec2_attach" {
  count      = var.enable_ec2 ? 1 : 0
  role       = aws_iam_role.ec2_role[0].name
  policy_arn = aws_iam_policy.app_s3_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  count = var.enable_ec2 ? 1 : 0
  name  = "ec2-app-profile"
  role  = aws_iam_role.ec2_role[0].name
}

# ---- ECS TASK ROLE + EXECUTION ROLE (optional) ----
data "aws_iam_policy_document" "ecs_task_trust" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  count              = var.enable_ecs ? 1 : 0
  name               = "ecs-task-app-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_attach" {
  count      = var.enable_ecs ? 1 : 0
  role       = aws_iam_role.ecs_task_role[0].name
  policy_arn = aws_iam_policy.app_s3_policy.arn
}

resource "aws_iam_role" "ecs_execution_role" {
  count              = var.enable_ecs ? 1 : 0
  name               = "ecs-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_exec_attach" {
  count      = var.enable_ecs ? 1 : 0
  role       = aws_iam_role.ecs_execution_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
