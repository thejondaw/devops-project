# ==================================================== #
# ==================== ROOT Main ===================== #
# ==================================================== #

# AWS Region
provider "aws" {
  region = var.region
}

# ================== CUSTOM MODULES ================== #

# BACKEND - Module
module "backend" {
  source = "../terraform/modules/backend"

  environment = var.environment
  region      = var.region
  bucket_name = var.backend_bucket
}

# VPC - Module
module "vpc" {
  source = "../terraform/modules/vpc"

  environment       = var.environment
  region            = var.region
  vpc_configuration = var.vpc_configuration

  depends_on = [module.backend]
}

# RDS - Module
module "rds" {
  source = "../terraform/modules/rds"

  environment = var.environment
  network_configuration = {
    vpc_id = module.vpc.vpc_id
    subnets = {
      api = {
        id         = module.vpc.subnet_ids["api"]
        cidr_block = var.vpc_configuration.subnets.api.cidr_block
      }
      db = {
        id         = module.vpc.subnet_ids["db"]
        cidr_block = var.vpc_configuration.subnets.db.cidr_block
      }
    }
  }
  db_configuration = var.db_configuration

  depends_on = [module.vpc]
}

# EKS - Module
module "eks" {
  source = "../terraform/modules/eks"

  environment           = var.environment
  network_configuration = module.vpc.network_configuration
  cluster_configuration = var.eks_configuration

  depends_on = [module.vpc]
}

# TOOLS - Module
module "tools" {
  source = "../../modules/tools"

  cluster_configuration = {
    name        = module.eks.cluster_name
    endpoint    = module.eks.cluster_endpoint
    certificate = module.eks.cluster_certificate_authority
  }

  environment_configuration = {
    namespaces = ["develop", "stage", "prod"]
  }

  depends_on = [module.eks]
}

# ==================================================== #
