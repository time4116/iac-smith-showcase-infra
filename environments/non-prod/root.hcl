locals {
  environment = "non-prod"
  aws_region  = "us-west-2"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "iac-smith-state-non-prod-iac-smith-showcase-infra"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "iac-smith-lock-non-prod"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
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
