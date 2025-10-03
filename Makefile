# NOTE: make help uses a special comment format to group targets.
# If you'd like your target to show up use the following:
#
# my_target: ##@category_name sample description for my_target
service := "aws-base"
service_title := "AWS Base Setup - VPC|Network, etc."
service_author := "Philip DeLorenzo"
env := "dev"
repo := "${service}-setup"
tfvars_file := "$(shell pwd)"/iac/aws/terraform/environments/dev/env.auto.tfvars
AWS_PROFILE := $(shell cat .aws_profile)
NETWORK_ID := 10.10
CIDR_NOTATION := 16
VPC_CIDR_BLOCK := "${NETWORK_ID}.0.0/${CIDR_NOTATION}"
default: help

# We need to have a doppler token set to proceed, this is by design so that bad actors cannot access the secrets, or environments.
define TOKEN_ALIVE_SCRIPT
[[ -f .doppler ]] && cat .doppler || echo "false"
endef
export TOKEN_ALIVE_SCRIPT

DOPPLER_TOKEN := $$(bash -c "$$TOKEN_ALIVE_SCRIPT")

define DTOKEN_EVAL
[[ "${DOPPLER_TOKEN}" == "false" ]] && echo "[CRITICAL] - The .doppler file is missing, please set the Doppler token in this file." || echo 0
endef
export DTOKEN_EVAL

IS_TOKEN := $$(bash -c "$$DTOKEN_EVAL")

############# Development Section #############
.PHONY: configure prereqs setup fmt
configure:
	$(info ********** Configure the AWS CLI **********)
	@if [[ ${IS_TOKEN} == '[CRITICAL] - The .doppler file is missing, please set the Doppler token in this file.' ]]; then echo "${IS_TOKEN}" && exit 1; fi
	@doppler run --token ${DOPPLER_TOKEN} --command "bash scripts/configure.sh"
	@echo "[INFO] - AWS CLI Configuration Complete!"

prereqs:
	@if [[ ${IS_TOKEN} == '[CRITICAL] - The .doppler file is missing, please set the Doppler token in this file.' ]]; then echo "${IS_TOKEN}" && exit 1; fi
	@export AWS_PROFILE=${AWS_PROFILE} && \
	export PROJECT=${service} && \
	export NETWORK_ID=${NETWORK_ID} && \
	export VPC_CIDR_BLOCK=${VPC_CIDR_BLOCK} && \
	export ENVIRONMENT=${env} && \
	bash -l "scripts/prereqs.sh"

setup: ##@development Installs needed prerequisites and software to develop the project
	$(info ********** Installing Developer Tooling Prerequisites **********)
	@bash -l scripts/init.sh -a
	@bash -l scripts/init.sh -p
	@asdf install
	@asdf reshim
	@echo "[INFO] - Installation Complete!"

fmt: ##@development Formats the terraform files
	$(info ********** Formatting Terraform Files **********)
	@terraform fmt -recursive iac/aws/terraform
	@terraform fmt -recursive iac/aws/bootstrap
	@echo "[INFO] - Terraform Format Complete!"

.PHONY: bootstrap init refresh validate plan apply destroy
bootstrap: ##@terraform Bootstraps the development environment
	$(info ********** Bootstrapping Development Environment (Creating AWS s3 Backend) **********)
	@$(MAKE) prereqs
	@doppler run --token ${DOPPLER_TOKEN} --command "cd iac/aws/bootstrap || exit 1 && terraform init"
	@doppler run --token ${DOPPLER_TOKEN} --command "export DOPPLER_TOKEN=${DOPPLER_TOKEN} && bash iac/scripts/bootstrap.sh ${service}"
	@echo "[INFO] - Bootstrap Complete!"

init: ##@terraform Installs needed providers and initializes the terraform files
	$(info ********** Initializing the Terraform Environment/Providers **********)
	@$(MAKE) prereqs
	@doppler run --token ${DOPPLER_TOKEN} --command "cd iac/aws/terraform/environments/dev || exit 1 && \
	terraform init \
	-backend-config='profile=${AWS_PROFILE}' \
	-backend-config='bucket=${service}-terraform-state' \
	-backend-config='key=${service}/${env}/terraform.tfstate' \
	-backend-config='region=${REGION}' \
	-var-file=${tfvars_file}"

reconfig: ##@terraform Installs needed providers and initializes the terraform files
	$(info ********** Initializing (reconfigure) the Terraform Environment/Providers **********)
	@$(MAKE) prereqs
	@doppler run --token ${DOPPLER_TOKEN} \
	--command "export TV_VARS_DB_NAME=${DB_NAME} && \
	export TV_VARS_DB_USERNAME=${DB_USERNAME} && \
	export TV_VARS_DB_PASSWORD=${DB_PASSWORD} && \
	cd iac/aws/terraform/environments/dev || exit 1 && \
	terraform init --reconfigure \
	-backend-config='profile=${AWS_PROFILE}' \
	-backend-config='bucket=${service}-terraform-state' \
	-backend-config='key=${service}/terraform.tfstate' \
	-backend-config='region=${AWS_REGION}' \
	-var-file=${tfvars_file}"

refresh: ##@terraform Refreshes the terraform state file
	$(info ********** Refreshing the Terraform State File **********)
	@doppler run --token ${DOPPLER_TOKEN} --command "cd iac/aws/terraform/environments/dev || exit 1 && terraform refresh -var='profile=${AWS_PROFILE}'"

validate: ##@terraform Validates the terraform files
	$(info ********** Validating Terraform Files **********)
	@doppler run --token ${DOPPLER_TOKEN} --command "cd iac/aws/terraform/environments/dev || exit 1 && terraform validate"

plan: ##@terraform Plans the terraform changes to be applied
	$(info ********** Planning Terraform Changes **********)
	@doppler run --token ${DOPPLER_TOKEN} --command "cd iac/aws/terraform/environments/dev || exit 1 && \
	terraform plan -out=tfplan \
	-var-file=${tfvars_file} \
	-var='profile=${AWS_PROFILE}'"

apply: ##@terraform Applies the terraform changes to be applied
	$(info ********** Applying Terraform Changes **********)
	@doppler run --token ${DOPPLER_TOKEN} --command "cd iac/aws/terraform/environments/dev || exit 1 && terraform apply tfplan"
	@echo "[INFO] - Terraform Apply Complete!"

destroy: ##@terraform Destroys all terraform-managed infrastructure
	$(info ********** Destroying All Terraform-Managed Infrastructure **********)
	@doppler run --token ${DOPPLER_TOKEN} --command "cd iac/aws/terraform/environments/dev || exit 1 && terraform destroy -var='profile=${AWS_PROFILE}'"

help: ##@misc Show this help.
	@echo $(MAKEFILE_LIST)
	@perl -e '$(HELP_FUNC)' $(MAKEFILE_LIST)

# helper function for printing target annotations
# ripped from https://gist.github.com/prwhite/8168133
HELP_FUNC = \
	%help; \
	while(<>) { \
		if(/^([a-z0-9_-]+):.*\#\#(?:@(\w+))?\s(.*)$$/) { \
			push(@{$$help{$$2}}, [$$1, $$3]); \
		} \
	}; \
	print "usage: make [target]\n\n"; \
	for ( sort keys %help ) { \
		print "$$_:\n"; \
		printf("  %-20s %s\n", $$_->[0], $$_->[1]) for @{$$help{$$_}}; \
		print "\n"; \
	}
