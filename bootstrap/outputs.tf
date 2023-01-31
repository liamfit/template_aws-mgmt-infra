output "tf_state_bucket" {
  description = "Terraform state bucket"
  value       = module.s3_bucket_terraform_state.s3_bucket_id
}

output "tf_state_locking_table" {
  description = "Terraform state locking table"
  value       = aws_dynamodb_table.terraform_state.name
}

output "github_actions_role" {
  description = "Github Actions IAM role arn"
  value       = module.oidc_github.iam_role_arn
}