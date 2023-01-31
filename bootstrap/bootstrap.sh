#!/bin/zsh

read -q "SSM?Do you want to create/update the terraform.tfvars.json parameter in SSM? "

if [[ "${SSM}" == 'y' ]]; then
    # Check file exists
    if [[ ! -f ../bootstrap/terraform.tfvars.json ]]; then
        echo "\nPlease create 'bootstrap/terraform.tfvars.json' file, see 'bootstrap/terraform.tfvars.json.example' for format.\n"
        exit 1
    fi

    echo "\nCreating/updating terraform.tfvars.json parameter in SSM..."
    # Create terraform.tfvars.json parameter
    aws ssm put-parameter \
        --name "terraform.tfvars.json" \
        --value "$(cat ../bootstrap/terraform.tfvars.json)" \
        --type "SecureString" \
        --overwrite
fi

echo "\n"
read -q "FIRST_RUN?Is this the first run? "

if [[ "${FIRST_RUN}" == 'y' ]]; then
    # Run terraform init & apply for bootstrap resources
    echo "\nRunning terraform init..."
    terraform init -upgrade

    echo "\nRunning terraform apply..."
    terraform apply -auto-approve
    if [[ $? != 0 ]]; then
        echo "\nTerraform apply failed"
        exit 1
    fi
fi

echo "\n"
read -q "MIGRATE_STATE?Do you want to migrate the terraform state to S3? "

if [[ "${MIGRATE_STATE}" == 'y' ]]; then
    # Get variables for remote state
    TF_STATE_BUCKET=$(terraform output -raw tf_state_bucket)
    TF_STATE_LOCKING_TABLE=$(terraform output -raw tf_state_locking_table)
    REPO_NAME=$(basename $(git rev-parse --show-toplevel))
    AWS_REGION=$(jq -r .region terraform.tfvars.json)

    # Change backend from local to S3
    sed -i '' 's/"local"/"s3"/g' config.tf

    # Migrate state to S3
    terraform init \
        -force-copy \
        -backend-config="encrypt=true" \
        -backend-config="bucket=${TF_STATE_BUCKET}" \
        -backend-config="key=${REPO_NAME}/bootstrap/terraform.tfstate" \
        -backend-config="dynamodb_table=${TF_STATE_LOCKING_TABLE}" \
        -backend-config="region=${AWS_REGION}"
fi

echo "\n"
read -q "GH_SECRETS?Do you want to create Github secrets? "

if [[ "${GH_SECRETS}" == 'y' ]]; then
    # Get token
    echo "\n"
    read "TOKEN?Please enter your Github API token: "
    export GITHUB_TOKEN="${TOKEN}"

    # Get Github secrets values
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
    AWS_ROLE=$(terraform output -raw github_actions_role)
    AWS_REGION=$(jq -r .region terraform.tfvars.json)
    TF_STATE_BUCKET=$(terraform output -raw tf_state_bucket)
    TF_STATE_LOCKING_TABLE=$(terraform output -raw tf_state_locking_table)

    # Set Github secrets
    gh secret set AWS_ACCOUNT_ID --body "${AWS_ACCOUNT_ID}"
    gh secret set AWS_ROLE --body "${AWS_ROLE}"
    gh secret set AWS_REGION --body "${AWS_REGION}"
    gh secret set TF_STATE_BUCKET --body "${TF_STATE_BUCKET}"
    gh secret set TF_STATE_LOCKING_TABLE --body "${TF_STATE_LOCKING_TABLE}"
fi
