output "spec_summary" {
  description = "Human-readable summary of the rendered infrastructure spec."
  value       = "Rendered deterministic IaC Smith structure for ${var.environment}"
}

output "vpc_id" {
  description = "`vpc_id` from `terraform-aws-modules/vpc/aws`."
  value       = module.this.vpc_id
}

output "vpc_cidr_block" {
  description = "`vpc_cidr_block` from `terraform-aws-modules/vpc/aws`."
  value       = module.this.vpc_cidr_block
}

output "private_subnets" {
  description = "`private_subnets` from `terraform-aws-modules/vpc/aws`."
  value       = module.this.private_subnets
}

output "public_subnets" {
  description = "`public_subnets` from `terraform-aws-modules/vpc/aws`."
  value       = module.this.public_subnets
}
