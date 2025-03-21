data "aws_availability_zones" "available" {}

################################################################################
# VPC Module
################################################################################

module "vpc" {

  providers = { aws = aws }
  source    = "terraform-aws-modules/vpc/aws"
  version   = "~> 5.7.0"

  # Specify whether to create VPC or not
  create_vpc = true

  # VPC Settings
  name = var.identifier
  cidr = var.vpc_cidr
  azs  = local.azs

  # Subnets
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 52)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = local.public_subnet_tags

  private_subnet_tags = local.private_subnet_tags

  tags = local.tags
}
