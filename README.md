# aws-basic-setup

A simple Terraform project that sets up a VPC with:

- 10.10.0.0/16 CIDR - You can change this in the Makefile to a different Network ID if desired.
- Internet Gateway
- NAT
- Security Group
- Route Tables

## Prerequisites

## AWS CLI Configure

#### _This presumes the Doppler project with the same name as the repo, and configs exist._

We need to configure our AWS CLI - `make configure`

There are some prerequisites that will allow the developer to interact with this repo much easier, with
greater efficiency.

This just keeps it simple...

- [asdf](https://asdf-vm.com/)
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Python 3.13+](https://www.python.org/)
- [Kubectl 1.34.1](https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/)

## _TL;DR Developer Experience_

For a better developer experience, a Makefile _(for MacOS only)_ has been provided in the repo root, you can quickly install these with the following command:

```bash
make setup
```

## IaC Documentation

In order to build the Helium application, there are some extra pieces that are needed - this are all available after running
`make init` but you will need to add an aws profile _(a profile in the AWS account you would like to use to install and run the infrastructure)_.

See the [IaC Documentation](./iac/README.md)

## Doppler Configuration

The following variables are needed in the sync'd configuration from Doppler.

Project Name: `<name-of-github-repo>` 
Configs: `dev`, `stg`, `prd`  
Variables:

```yaml
AWS_ACCOUNT_ID: <aws-account-id>
AWS_REGION: <aws-region> # Kept secret to add another layer of complexity for potential bad actors
```

Create your `.doppler`, and `.aws_profile` files in the root - see [Bootstrapping](./iac/README.md#bootstrapping----s3-remote-state-bucket-backend)
