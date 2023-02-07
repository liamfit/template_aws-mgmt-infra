data "aws_iam_policy_document" "github_policy_document_mgmt_account" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [ "arn:aws:dynamodb:${var.region}:${local.account_id}:table/${aws_dynamodb_table.terraform_state.id}" ]
  }
  statement {
    effect = "Allow"
    actions = [ "s3:ListBucket" ]
    resources = [ "arn:aws:s3:::${module.s3_bucket_terraform_state.s3_bucket_id}" ]
  }
  statement {
    effect = "Allow"
    actions = [ 
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [ "arn:aws:s3:::${module.s3_bucket_terraform_state.s3_bucket_id}/*" ]
  }
  statement {
    effect = "Allow"
    actions = [ "ssm:GetParameter" ]
    resources = [ "arn:aws:ssm:${var.region}:${local.account_id}:parameter/terraform.tfvars.json" ]
  }
  dynamic "statement" {
    for_each = var.accounts

    content {
      effect = "Allow"
      actions = [ "sts:AssumeRole" ]
      resources = [ "arn:aws:iam::${statement.value}:role/${var.github_role_name}" ]
    }
  }
}