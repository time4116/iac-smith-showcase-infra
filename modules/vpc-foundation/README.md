# vpc-foundation

Wraps the community module [`terraform-aws-modules/vpc/aws`](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws) pinned to `6.6.1`; the committed `.terraform.lock.hcl` pins the resolved provider versions.

Configured module inputs: `azs`, `cidr`, `create_igw`, `enable_dns_hostnames`, `enable_dns_support`, `enable_nat_gateway`, `name`, `private_subnets`, `public_subnets`, `single_nat_gateway`, `tags`

## Inputs

| Name | Type |
|---|---|
| `aws_region` | `string` |
| `environment` | `string` |

## Outputs

| Name | Description |
|---|---|
| `spec_summary` | Human-readable summary of the rendered infrastructure spec. |
| `vpc_id` | `vpc_id` from `terraform-aws-modules/vpc/aws`. |
| `vpc_cidr_block` | `vpc_cidr_block` from `terraform-aws-modules/vpc/aws`. |
| `private_subnets` | `private_subnets` from `terraform-aws-modules/vpc/aws`. |
| `public_subnets` | `public_subnets` from `terraform-aws-modules/vpc/aws`. |
