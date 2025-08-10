#!/bin/bash

set -euo pipefail

echo "📦 Loading environment variables from .env"
set -a
source ../.env
set +a

echo "🚀 Initializing Terraform backend..."
terraform init -reconfigure \
  -backend-config="bucket=vitr-terraform-states" \
  -backend-config="key=users/${GITHUB_USER}/${PROJECT_NAME}/hosted-zone/terraform.tfstate" \
  -backend-config="region=${AWS_REGION}" \
  -backend-config="encrypt=true"

echo "⚠️ WARNING: This will destroy all Terraform-managed resources for this module"
read -p "Are you sure you want to continue? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "❌ Aborted."
  exit 1
fi

echo "🔥 Destroying Terraform-managed infrastructure..."
terraform destroy -auto-approve \
  -var="domain_name=${DOMAIN_NAME}"

echo "🧹 Cleaning up SSM parameters..."
aws ssm delete-parameter \
  --name "/${PROJECT_NAME}/hosted_zone_id" \
  --region "${AWS_REGION}" || echo "⚠️ Parameter not found: hosted_zone_id"

echo "✅ Destruction complete"
