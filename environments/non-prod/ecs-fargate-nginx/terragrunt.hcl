include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment = "non-prod"
  aws_region  = "us-west-2"
}

terraform {
  source = "../../../modules/ecs-fargate-nginx"
}

dependency "vpc-foundation" {
  config_path = "../vpc-foundation"

  mock_outputs = {
    spec_summary    = "mock-value"
    vpc_id          = "mock-id"
    vpc_cidr_block  = "mock-value"
    private_subnets = ["mock-id"]
    public_subnets  = ["mock-id"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  environment     = local.environment
  aws_region      = local.aws_region
  spec_summary    = dependency.vpc-foundation.outputs.spec_summary
  vpc_id          = dependency.vpc-foundation.outputs.vpc_id
  vpc_cidr_block  = dependency.vpc-foundation.outputs.vpc_cidr_block
  private_subnets = dependency.vpc-foundation.outputs.private_subnets
  public_subnets  = dependency.vpc-foundation.outputs.public_subnets
}
