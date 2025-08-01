module "networking" {
  source = "../../modules/networking"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr

  # Use 3 AZs for the 6 subnets of each type
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = "${var.project_name}-cluster"
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  allowed_admin_ips  = var.eks_admin_whitelisted
  node_group_config  = var.node_group_config
}
