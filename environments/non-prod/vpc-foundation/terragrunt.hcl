include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment = "non-prod"
  aws_region  = "us-west-2"
}

terraform {
  source = "../../../modules/vpc-foundation"
}

inputs = {
  environment = local.environment
  aws_region  = local.aws_region
}
