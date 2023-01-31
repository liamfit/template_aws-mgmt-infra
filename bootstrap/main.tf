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
  iam_role_name           = "iar-github-actions-role"
  iam_role_policy_arns    = [ aws_iam_policy.github_policy.arn ]

  github_repositories = [
    "${var.org}/${var.infra_prefix}-*"
  ]
}

resource "aws_iam_policy" "github_policy" {
  name = "iap-github-actions-policy"

  policy = templatefile("${path.module}/github-actions-policy.json", {
    account_id     = "${local.account_id}"
    region         = "${var.region}"
    bucket_name    = "${module.s3_bucket_terraform_state.s3_bucket_id}"
    dynamodb_table = "${aws_dynamodb_table.terraform_state.id}"
  })
}
