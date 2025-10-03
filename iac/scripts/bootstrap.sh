#!/usr/bin/env bash

set -eou pipefail

[[ -z "${1:-}" ]] && (echo "[ERROR] - This script requires an argument - the bucket name to check"; exit 1)

service="${1}"
TF_STATE_FILE="${service}-terraform-state" # Found, let's name it

BASEDIR=$(dirname "$0")
REPO=$(dirname "$0")/../..

run_apply() {
	# Run the plan
	doppler run --token ${DOPPLER_TOKEN} --command "cd ${REPO}/iac/aws/bootstrap || exit 1 && \
		terraform plan -out=tfplan \
		-var='profile=${AWS_PROFILE}' \
		-var='region=${AWS_REGION}' \
		-var='project=${service}'"

	# Based on the above plan outfile, run the apply
	doppler run --token ${DOPPLER_TOKEN} --command "cd ${REPO}/iac/aws/bootstrap || exit 1 && terraform apply tfplan"
}

set +e
doppler run --token ${DOPPLER_TOKEN} --command "aws s3api head-bucket \
	--bucket ${TF_STATE_FILE} \
	--profile ${AWS_PROFILE} \
	--region ${AWS_REGION} 2>&1 >/dev/null"

check=$?
set -e

if [[ "${check}" == "0" ]]; then
	echo "[INFO] - Bootstrap configuration backend exists..."
	exit 0
else
	echo "[INFO] - Bootstrapping configuration backend..."
	run_apply
fi
