# This file is IMPORTANT
# It checks for the prerequisites needed to run the Terraform scripts
# It also creates the env.auto.tfvars file from the template and replaces variables
#!/usr/bin/env bash

set -euo pipefail

BASEDIR=$(dirname "$0")
REPO=$(dirname "$0")/..

[[ -z "${AWS_PROFILE:-}" ]] && (echo "[ERROR] - AWS_PROFILE environment variable not set! Please set it to the AWS CLI profile you wish to use for this project and try again...." && exit 1)
[[ -z "${PROJECT:-}" ]] && (echo "[ERROR] - PROJECT environment variable not set!" && exit 1)
[[ -z "${SUBNET:-}" ]] && (echo "[ERROR] - SUBNET environment variable not set!" && exit 1)
[[ -z "${BUCKET:-}" ]] && (echo "[ERROR] - BUCKET environment variable not set!" && exit 1)

STATE_BUCKET="${BUCKET}" # Default bucket name

### If there is a STATE_UNIQUE_ID variable, append it to the bucket name to ensure uniqueness
[[ -z "${STATE_UNIQUE_ID:-}" ]] || export STATE_BUCKET="${BUCKET}-${STATE_UNIQUE_ID}"

[[ ! -f "${REPO}/.doppler" ]] && (echo "Doppler token file not found! Please create a .doppler file in the iac directory with your Doppler service token value as the contents...." && exit 1)
[[ -z $(cat "${REPO}/.doppler") ]] && (echo "Doppler token file is empty! Please add your Doppler service token value as the contents of the .doppler file in the iac directory...." && exit 1)

[[ $(command -v doppler || true) ]] || (echo "Doppler CLI not found. Please install it from https://docs.doppler.com/docs/install-cli" && echo "You can also run 'make init' from the iac directory to install all prerequisites." && exit 1)
[[ $(command -v aws || true) ]] || (echo "AWS CLI not found. Please install it from https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html" && echo "You can also run 'make init' from the iac directory to install all prerequisites." && exit 1)

# Create the env.auto.tfvars file from the template and replace variables
echo "[INFO] - Creating the env.auto.tfvars file from the template and replacing variables..."

rsync "${REPO}/iac/aws/terraform/environments/dev/env.template" "${REPO}/iac/aws/terraform/environments/dev/env.auto.tfvars"

sed -i '' "s/project = .*/project = \"${PROJECT}\"/g" "${REPO}/iac/aws/terraform/environments/dev/env.auto.tfvars"
#sed -i '' "s/network_id = .*/network_id = \"${NETWORK_ID}\"/g" "${REPO}/iac/aws/terraform/environments/dev/env.auto.tfvars"
sed -i '' "s|subnet = .*|subnet = \"${SUBNET}\"|g" "${REPO}/iac/aws/terraform/environments/dev/env.auto.tfvars"
sed -i '' "s|bucket = .*|bucket = \"${STATE_BUCKET}\"|g" "${REPO}/iac/aws/terraform/environments/dev/env.auto.tfvars"

unset STATE_BUCKET
