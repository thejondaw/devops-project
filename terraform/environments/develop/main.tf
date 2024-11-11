# ==================================================== #
# ==================== ROOT Main ===================== #
# ==================================================== #

# "AWS Provider" - Region:
provider "aws" {
  region = var.region_rv
}

# ================== Custom Modules ================== #

# "BACKEND" Module:
module "backend" {
  source = "../../modules/backend"

  region_rv         = var.region_rv
  backend_bucket_rv = var.backend_bucket_rv
  environment_rv    = var.environment_rv
}

# "VPC" Module:
module "vpc" {
  source          = "../terraform/modules/vpc"
  region          = var.region_rv
  vpc_cidr        = var.vpc_cidr_rv
  subnet_web_cidr = var.subnet_web_cidr_rv
  subnet_alb_cidr = var.subnet_alb_cidr_rv
  subnet_api_cidr = var.subnet_api_cidr_rv
  subnet_db_cidr  = var.subnet_db_cidr_rv
  depends_on      = [module.backend]
}

# "EKS" Module:
module "eks" {
  source          = "../terraform/modules/eks"
  region          = var.region_rv
  vpc_cidr        = module.vpc.vpc_arn
  subnet_web_cidr = module.vpc.subnet_web_cidr_rv
  subnet_alb_cidr = module.vpc.subnet_alb_cidr_rv
  subnet_api_cidr = module.vpc.subnet_api_cidr_rv
  depends_on      = [module.backend]
}

# "RDS" Module:
module "rds" {
  source          = "../terraform/modules/rds"
  region          = var.region_rv
  vpc_cidr        = module.vpc.vpc_arn
  subnet_api_cidr = var.subnet_api_cidr_rv
  subnet_db_cidr  = var.subnet_db_cidr_rv
  depends_on      = [module.backend]
}

# "TOOLS" Module:
module "tools" {
  source = "../../modules/tools"

  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_name           = module.eks.cluster_name
  cluster_ca_certificate = module.eks.cluster_certificate_authority
  depends_on             = [module.eks]
}

# ==================================================== #
