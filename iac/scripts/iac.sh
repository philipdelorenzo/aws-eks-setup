#!/usr/bin/env bash

set -eou pipefail

BASEDIR="$(dirname "$0")"
REPO="$(realpath "${BASEDIR}/../..")"

state() {
    # If there is a STATE_UNIQUE_ID variable, append it to the bucket name to ensure uniqueness
    [[ -z "${STATE_UNIQUE_ID:-}" ]] || TF_STATE_BUCKET="${TF_STATE_BUCKET}-${STATE_UNIQUE_ID}"
}

cleanup() {
    unset service
    unset tfvars_file
    unset TF_STATE_BUCKET
}

upgrade() {
    cd ${REPO}/iac/aws/terraform/environments/dev || exit 1 && \
    terraform init -upgrade
}

run_init() {
	# Run the init
    state
    echo "[INFO] - Using the S3 bucket: ${TF_STATE_BUCKET} for the Terraform state backend"
    cd ${REPO}/iac/aws/terraform/environments/dev || exit 1 && \
    terraform init -backend-config="profile=${AWS_PROFILE}" \
    -backend-config="bucket=${TF_STATE_BUCKET}" \
    -backend-config="key=${PROJECT}/terraform.tfstate" \
    -backend-config="region=${AWS_REGION}" \
    -var-file="${tfvars_file}"

    # Run cleanup
    cleanup
}

reconfigure() {
    state
    echo "[INFO] - Using the S3 bucket: ${TF_STATE_BUCKET} for the Terraform state backend"
    cd ${REPO}/iac/aws/terraform/environments/dev || exit 1 && \
    terraform init --reconfigure -backend-config="profile=${AWS_PROFILE}" \
    -backend-config="bucket=${TF_STATE_BUCKET}" \
    -backend-config="key=${PROJECT}/terraform.tfstate" \
    -backend-config="region=${AWS_REGION}" \
    -var-file="${tfvars_file}"

    # Run cleanup
    cleanup
}

refresh() {
    cd ${REPO}/iac/aws/terraform/environments/dev || exit 1 && terraform refresh
}

plan() {
    cd ${REPO}/iac/aws/terraform/environments/dev || exit 1 && \
    terraform plan -out=tfplan -var="profile=${AWS_PROFILE}" -var-file="${tfvars_file}"
}

apply() {
    cd ${REPO}/iac/aws/terraform/environments/dev || exit 1 && \
    terraform apply "tfplan"
}

bootstrap() {
    cd ${REPO}/iac/aws/bootstrap || exit 1 && \
    terraform init
    set +e
    aws s3api head-bucket \
        --bucket ${TF_STATE_BUCKET} \
        --profile ${AWS_PROFILE} \
        --region ${AWS_REGION} 2>&1 >/dev/null
    set -e
    check=$? # Capture exit code of last command
    
    if [[ "${check}" == "0" ]]; then
        echo "[INFO] - Bootstrap configuration backend exists..."
        exit 0
    else
        echo "[INFO] - Bootstrapping configuration backend..."
        cd ${REPO}/iac/aws/bootstrap || exit 1 && \
        terraform plan -out=tfplan -var="profile=${AWS_PROFILE}" \
        -var="bucket=${TF_STATE_BUCKET}" \
        -var="region=${AWS_REGION}" \
        -var="project=${PROJECT}"
        
        cd ${REPO}/iac/aws/bootstrap || exit 1 && \
        terraform apply -auto-approve tfplan
    fi
}

destroy() {
    cd ${REPO}/iac/aws/terraform/environments/dev || exit 1 && \
    terraform destroy -var="profile=${AWS_PROFILE}"
}

format()
{
    terraform fmt -recursive ${REPO}/iac/aws/terraform
    terraform fmt -recursive ${REPO}/iac/aws/bootstrap
}

validate()
{
    cd ${REPO}/iac/aws/terraform/environments/dev || exit 1 && terraform validate
}

usage() { echo "Usage: $0 [-a apply] [-b bootstrap] [-d destroy] [-f format] [-i init] [-p plan] [-r reconfigure|refresh] [-u upgrade] [-v validate]" 1>&2; echo 'Requires: ${service}, ${tfvars_file} in SHELL' exit 1; }

while getopts ":abdfipruv" arg; do
    case "${arg}" in
        a)
            apply
            ;;
        b)
            # Bootstrap the backend S3 bucket for terraform state
            [[ -z "${PROJECT:-}" ]] && (echo '[ERROR] - This script requires ${PROJECT} - the project name; i.e. ~> $service'; exit 1)
            [[ -z "${tfvars_file:-}" ]] && (echo "[ERROR] - This script requires ${tfvars_file} - the tfvars file path"; exit 1)
            TF_STATE_BUCKET="${PROJECT}-terraform-state" # Default bucket name
            # Doppler Variables
            [[ -z "${AWS_PROFILE:-}" ]] && (echo "[ERROR] - This script requires the AWS_PROFILE environment variable to be set"; exit 1)
            [[ -z "${AWS_REGION:-}" ]] && (echo "[ERROR] - This script requires the AWS_REGION environment variable to be set"; exit 1)
            state
            bootstrap
            ;;
        d)
            # Doppler Variables
            [[ -z "${AWS_PROFILE:-}" ]] && (echo "[ERROR] - This script requires the AWS_PROFILE environment variable to be set"; exit 1)
            [[ -z "${AWS_REGION:-}" ]] && (echo "[ERROR] - This script requires the AWS_REGION environment variable to be set"; exit 1)
            destroy
            ;;
        f)
            format
            ;;
        i)
            [[ -z "${PROJECT:-}" ]] && (echo '[ERROR] - This script requires ${PROJECT} - the project name; i.e. ~> $service'; exit 1)
            [[ -z "${tfvars_file:-}" ]] && (echo "[ERROR] - This script requires ${tfvars_file} - the tfvars file path"; exit 1)
            TF_STATE_BUCKET="${PROJECT}-terraform-state" # Default bucket name
            # Doppler Variables
            [[ -z "${AWS_PROFILE:-}" ]] && (echo "[ERROR] - This script requires the AWS_PROFILE environment variable to be set"; exit 1)
            [[ -z "${AWS_REGION:-}" ]] && (echo "[ERROR] - This script requires the AWS_REGION environment variable to be set"; exit 1)
            run_init
            ;;
        r)
            [[ -z "${PROJECT:-}" ]] && (echo '[ERROR] - This script requires ${PROJECT} - the project name; i.e. ~> $service'; exit 1)
            [[ -z "${tfvars_file:-}" ]] && (echo "[ERROR] - This script requires ${tfvars_file} - the tfvars file path"; exit 1)
            TF_STATE_BUCKET="${PROJECT}-terraform-state" # Default bucket name
            # Doppler Variables
            [[ -z "${AWS_PROFILE:-}" ]] && (echo "[ERROR] - This script requires the AWS_PROFILE environment variable to be set"; exit 1)
            [[ -z "${AWS_REGION:-}" ]] && (echo "[ERROR] - This script requires the AWS_REGION environment variable to be set"; exit 1)
            reconfigure
            refresh
            ;;
        p)
            #[[ -z "${PROJECT:-}" ]] && (echo '[ERROR] - This script requires ${PROJECT} - the project name; i.e. ~> $service'; exit 1)
            [[ -z "${tfvars_file:-}" ]] && (echo "[ERROR] - This script requires ${tfvars_file} - the tfvars file path"; exit 1)
            #TF_STATE_BUCKET="${PROJECT}-terraform-state" # Default bucket name
            # Doppler Variables
            [[ -z "${AWS_PROFILE:-}" ]] && (echo "[ERROR] - This script requires the AWS_PROFILE environment variable to be set"; exit 1)
            [[ -z "${AWS_REGION:-}" ]] && (echo "[ERROR] - This script requires the AWS_REGION environment variable to be set"; exit 1)
            plan
            ;;
        u)
            [[ -z "${PROJECT:-}" ]] && (echo '[ERROR] - This script requires ${PROJECT} - the project name; i.e. ~> $service'; exit 1)
            [[ -z "${tfvars_file:-}" ]] && (echo "[ERROR] - This script requires ${tfvars_file} - the tfvars file path"; exit 1)
            TF_STATE_BUCKET="${PROJECT}-terraform-state" # Default bucket name
            # Doppler Variables
            [[ -z "${AWS_PROFILE:-}" ]] && (echo "[ERROR] - This script requires the AWS_PROFILE environment variable to be set"; exit 1)
            [[ -z "${AWS_REGION:-}" ]] && (echo "[ERROR] - This script requires the AWS_REGION environment variable to be set"; exit 1)
            upgrade
            ;;
        v)
            validate
            ;;
        s)
            sops_installation
            ;;
        \?)
            echo "[ERROR] - Unknown flag passed"
            usage
            ;;
        :)
            echo "[ERROR] - Option -$arg requires an argument." >&2
            exit 1
            ;;
        *)
            usage
        ;;
    esac
done
