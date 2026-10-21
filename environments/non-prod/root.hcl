locals {
  environment = "non-prod"
  aws_region  = "us-west-2"
}

# Generate Terraform backend configuration only. Unlike remote_state, this does
# not let Terragrunt create or update S3/DynamoDB during plan/init. The existing
# backend must be provisioned by the approval-gated bootstrap apply workflow.
# Supported by the workflow's pinned Terragrunt v0.57.0.
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "s3" {
    bucket         = "iac-smith-state-non-prod-iac-smith-showcase-infra"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "iac-smith-lock-non-prod"
  }
}
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
}
EOF
}
