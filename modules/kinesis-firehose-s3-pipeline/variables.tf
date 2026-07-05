variable "environment" {
  description = "Spec-rendered input environment."
  type        = string
}

variable "aws_region" {
  description = "Spec-rendered input aws_region."
  type        = string
}

variable "spec_summary" {
  description = "Spec-rendered input spec_summary."
  type        = string
}

variable "vpc_id" {
  description = "Spec-rendered input vpc_id."
  type        = string
}

variable "vpc_cidr_block" {
  description = "Spec-rendered input vpc_cidr_block."
  type        = string
}

variable "private_subnets" {
  description = "Spec-rendered input private_subnets."
  type        = list(string)
}

variable "public_subnets" {
  description = "Spec-rendered input public_subnets."
  type        = list(string)
}
