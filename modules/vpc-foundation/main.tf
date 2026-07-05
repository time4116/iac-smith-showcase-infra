module "this" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.1"

  name = "foundation"
  cidr = "10.0.0.0/16"
  azs = [
    "us-west-2a",
    "us-west-2b"
  ]
  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
  public_subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]
  enable_dns_hostnames = true
  enable_dns_support   = true
  create_igw           = true
  enable_nat_gateway   = false
  single_nat_gateway   = false
  tags = {
    Environment = var.environment
    Stack       = "foundation"
  }
}
