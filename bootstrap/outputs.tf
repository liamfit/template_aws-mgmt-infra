output "tf_state_bucket" {
  description = "Terraform state bucket"
  value       = module.s3_bucket_terraform_state.s3_bucket_id
}

output "tf_state_locking_table" {
  description = "Terraform state locking table"
  value       = aws_dynamodb_table.terraform_state.name
}

output "github_actions_role_mgmt_account" {
  description = "Github Actions IAM role arn for management account"
  value       = module.oidc_github.iam_role_arn
}

output "github_actions_role_dev_account" {
  description = "Github Actions IAM role arn for dev account"
  value       = module.iam_iam-assumable-role-dev.iam_role_arn
}

output "github_actions_role_prod_account" {
  description = "Github Actions IAM role arn for prod account"
  value       = module.iam_iam-assumable-role-prod.iam_role_arn
}
