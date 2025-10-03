# NOTE: make help uses a special comment format to group targets.
# If you'd like your target to show up use the following:
#
# my_target: ##@category_name sample description for my_target
# This is set as PROJECT from the Makefile outward; i.e. ~> export PROJECT=${service}
service := "aws-eks"
service_title := "AWS EKS Cluster"
service_author := "Philip DeLorenzo"
env := "dev"
repo := "${service}-setup"
state_bucket := "${service}-terraform-state"
tfvars_file := "$(shell pwd)"/iac/aws/terraform/environments/dev/env.auto.tfvars
AWS_PROFILE := $(shell cat .aws_profile)

# This is the Subnet for the EKS Cluster -
NETWORK_ID := 10.10.1
CIDR_NOTATION := 24
SUBNET := "${NETWORK_ID}.0.0/${CIDR_NOTATION}"
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
_export_vars:
	@echo "DOPPLER_TOKEN is ${DOPPLER_TOKEN}"

configure:
	$(info ********** Configure the AWS CLI **********)
	@if [[ ${IS_TOKEN} == '[CRITICAL] - The .doppler file is missing, please set the Doppler token in this file.' ]]; then echo "${IS_TOKEN}" && exit 1; fi
	@doppler run --token ${DOPPLER_TOKEN} --command "bash scripts/configure.sh"
	@echo "[INFO] - AWS CLI Configuration Complete!"

prereqs:
	@if [[ ${IS_TOKEN} == '[CRITICAL] - The .doppler file is missing, please set the Doppler token in this file.' ]]; then echo "${IS_TOKEN}" && exit 1; fi
	@export PROJECT=${service} && \
	export BUCKET=${state_bucket} && \
	export NETWORK_ID=${NETWORK_ID} && \
	export SUBNET=${SUBNET} && \
	export ENVIRONMENT=${env} && \
	export tfvars_file=${tfvars_file} && \
	doppler run --token ${DOPPLER_TOKEN} --command "bash -l scripts/prereqs.sh"

setup: ##@development Installs needed prerequisites and software to develop the project
	$(info ********** Installing Developer Tooling Prerequisites **********)
	@bash -l scripts/init.sh -a
	@bash -l scripts/init.sh -p
	@asdf install
	@asdf reshim
	@echo "[INFO] - Installation Complete!"

fmt: ##@development Formats the terraform files
	$(info ********** Formatting Terraform Files **********)
	@bash iac/scripts/iac.sh -f
	@echo "[INFO] - Terraform Format Complete!"

.PHONY: bootstrap init refresh validate plan apply destroy
bootstrap: ##@terraform Bootstraps the development environment
	$(info ********** Bootstrapping Development Environment (Creating AWS s3 Backend) **********)
	@$(MAKE) prereqs
	@export PROJECT=${service} && \
	export tfvars_file=${tfvars_file} && \
	doppler run --token ${DOPPLER_TOKEN} --command "bash iac/scripts/iac.sh -b"
	@echo "[INFO] - Bootstrap Complete!"

init: ##@terraform Installs needed providers and initializes the terraform files
	$(info ********** Initializing the Terraform Environment/Providers **********)
	@$(MAKE) prereqs
	@export PROJECT=${service} && \
	export tfvars_file=${tfvars_file} && \
	doppler run --token ${DOPPLER_TOKEN} --command "bash iac/scripts/iac.sh -i"
	@echo "[INFO] - Initialization Complete!"

reconfig: ##@terraform Reconfigures and refreshes the terraform state file
	$(info ********** Initializing (reconfigure) the Terraform Environment/Providers **********)
	@$(MAKE) prereqs
	@export PROJECT=${service} && \
	export tfvars_file=${tfvars_file} && \
	doppler run --token ${DOPPLER_TOKEN} --command "bash iac/scripts/iac.sh -r"
	@echo "[INFO] - Reconfiguration Complete!"

validate: ##@terraform Validates the terraform files
	$(info ********** Validating Terraform Files **********)
	@bash iac/scripts/iac.sh -v
	@echo "[INFO] - Terraform Validation Complete!"

plan: ##@terraform Plans the terraform changes to be applied
	$(info ********** Planning Terraform Changes **********)
	@export tfvars_file=${tfvars_file} && \
	doppler run --token ${DOPPLER_TOKEN} --command "bash iac/scripts/iac.sh -p"

apply: ##@terraform Applies the terraform changes to be applied
	$(info ********** Applying Terraform Changes **********)
	@doppler run --token ${DOPPLER_TOKEN} --command "bash iac/scripts/iac.sh -a"
	@echo "[INFO] - Terraform Apply Complete!"

destroy: ##@terraform Destroys all terraform-managed infrastructure
	$(info ********** Destroying All Terraform-Managed Infrastructure **********)
	@doppler run --token ${DOPPLER_TOKEN} --command "bash iac/scripts/iac.sh -d"
	@echo "[INFO] - Terraform Destroy Complete!"

upgrade: ##@terraform Upgrades the terraform providers to the latest allowed versions
	$(info ********** Upgrading Terraform Providers **********)
	@export PROJECT=${service} && \
	export tfvars_file=${tfvars_file} && \
	doppler run --token ${DOPPLER_TOKEN} --command "bash iac/scripts/iac.sh -u"
	@echo "[INFO] - Terraform Upgrade Complete!"

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
