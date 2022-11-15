module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr_block

  azs = var.azs
  private_subnets  = var.private_subnet_ips
  public_subnets   = var.public_subnet_ips
  database_subnets = var.database_subnet_ips

  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_vpn_gateway     = false
  one_nat_gateway_per_az = false


  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = var.db_subnet_public

  enable_dns_hostnames = true
  enable_dns_support   = true

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  tags = local.tags
}