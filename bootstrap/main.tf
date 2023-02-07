data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

module "s3_bucket_terraform_state" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.6.0"

  bucket_prefix = "${var.infra_prefix}-terraform-state-"
  acl           = "private"

  versioning = {
    enabled = true
  }
  tags = var.default_tags
}

resource "aws_dynamodb_table" "terraform_state" {
  name           = "${var.infra_prefix}-${var.dynamodb_table}"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

module "oidc_github" {
  source  = "github.com/liamfit/terraform-aws-oidc-github?ref=dd52585"

  attach_read_only_policy	= false
  iam_role_name           = "${var.github_role_name}"
  iam_role_policy_arns    = [ aws_iam_policy.github_policy_mgmt_account.arn ]

  github_repositories = [
    "${var.org}/${var.infra_prefix}-*"
  ]
}

resource "aws_iam_policy" "github_policy_mgmt_account" {
  name   = "iap-github-actions-policy"
  policy = data.aws_iam_policy_document.github_policy_document_mgmt_account.json
}

module "iam_iam-assumable-role-dev" {
  source   = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version  = "5.11.1"

  providers = {
    aws = aws.dev
  }

  attach_admin_policy = true
  create_role         = true
  role_name           = "${var.github_role_name}"
  role_requires_mfa   = false
  trusted_role_arns   = [ "${module.oidc_github.iam_role_arn}" ]
}

module "iam_iam-assumable-role-prod" {
  source   = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version  = "5.11.1"

  providers = {
    aws = aws.prod
  }

  attach_admin_policy = true
  create_role         = true
  role_name           = "${var.github_role_name}"
  role_requires_mfa   = false
  trusted_role_arns   = [ "${module.oidc_github.iam_role_arn}" ]
}

