# template-mgmt-infra

This repo is a template for the AWS management account infrastructure for a project. The following minimum set of resources are created by default:
- An S3 bucket and DynamoDB table for Terraform remote state
- OIDC identity provider and IAM Role for Github Actions to assume in the management account
- An IAM role for Github Actions to assume in each workload account

![Management Infrastructure](mgmt-infra.png)


## How do I use this project to bootstrap a new AWS account?

The bootstrap directory contains terraform config to create the minimum set of resources. This is deployed from your local machine so AWS credentials are required for the accounts you are deploying into. It is assumed that the `default` profile is configured for the management account and you have config profiles for the workload accounts, e.g. `dev`, `prod` for example.

Steps are as follows:

1. Clone this template repository with an appropriate name, e.g. `project_x-mgmt-infra`
2. Create a `terraform.tfvars.json` file with details of the AWS accounts and other project information (see `terraform.tfvars.json.example` for the format)
3. Run the `bootstrap.sh` script


## How do I add new terraform managed resources?

New resources should be created in the root directory.

1. Make sure you have the appropriate deployment approvals in place for the `mgmt` environment
2. Create your resources in the root directory by modifying `main.tf`, `variables.tf` and `outputs.tf` as appropriate
3. Open a pull request against the main branch to trigger a `terraform plan` 
4. Once approved, `terraform apply` will run automatically


## How do I give Github additional permissions to create new terraform resources in the management account?

The policy for the Github Actions IAM role in the management account is contained in the bootstrap directory. You will need to deploy changes from your local machine using your own AWS credentials.

1. Modify `github_policy.tf` as required
2. Run `terraform apply`

| NOTE: You should create a workload account policy with more restrictive permissions. |
| By default it is configured with `AdministratorAccess`.                              |
|--------------------------------------------------------------------------------------|
