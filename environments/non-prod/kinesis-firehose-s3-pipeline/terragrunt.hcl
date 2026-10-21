include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment = "non-prod"
}

terraform {
  source = "../../../modules/kinesis-firehose-s3-pipeline"
}

inputs = {
  environment = local.environment
}
