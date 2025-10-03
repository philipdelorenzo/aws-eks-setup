#!/usr/bin/env bash

set -euo pipefail

BASEDIR=$(dirname "$0")
REPO=$(dirname "$0")/..

[[ -z "${AWS_PROFILE:-}" ]] && (echo "[ERROR] - AWS_PROFILE environment variable not set! Please set it to the AWS CLI profile you wish to use for this project and try again...." && exit 1)
[[ -z "${PROJECT:-}" ]] && (echo "[ERROR] - PROJECT environment variable not set!" && exit 1)
[[ -z "${NETWORK_ID}" ]] && (echo "[ERROR] - NETWORK_ID environment variable not set!" && exit 1)
[[ -z "${VPC_CIDR_BLOCK}" ]] && (echo "[ERROR] - VPC_CIDR_BLOCK environment variable not set!" && exit 1)

[[ ! -f "${REPO}/.doppler" ]] && (echo "Doppler token file not found! Please create a .doppler file in the iac directory with your Doppler service token value as the contents...." && exit 1)
[[ -z $(cat "${REPO}/.doppler") ]] && (echo "Doppler token file is empty! Please add your Doppler service token value as the contents of the .doppler file in the iac directory...." && exit 1)

[[ $(command -v doppler || true) ]] || (echo "Doppler CLI not found. Please install it from https://docs.doppler.com/docs/install-cli" && echo "You can also run 'make init' from the iac directory to install all prerequisites." && exit 1)
[[ $(command -v aws || true) ]] || (echo "AWS CLI not found. Please install it from https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html" && echo "You can also run 'make init' from the iac directory to install all prerequisites." && exit 1)

rsync "${REPO}/iac/aws/terraform/environments/dev/env.template" "${REPO}/iac/aws/terraform/environments/dev/env.auto.tfvars"

sed -i '' "s/project = .*/project = \"${PROJECT}\"/g" "${REPO}/iac/aws/terraform/environments/dev/env.auto.tfvars"
sed -i '' "s/network_id = .*/network_id = \"${NETWORK_ID}\"/g" "${REPO}/iac/aws/terraform/environments/dev/env.auto.tfvars"
sed -i '' "s|vpc_cidr = .*|vpc_cidr = \"${VPC_CIDR_BLOCK}\"|g" "${REPO}/iac/aws/terraform/environments/dev/env.auto.tfvars"
