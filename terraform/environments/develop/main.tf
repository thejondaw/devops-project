# ==================================================== #
# ==================== ROOT Main ===================== #
# ==================================================== #

# "AWS Provider" - Region:
provider "aws" {
  region = var.region_rv
}

# ================== Custom Modules ================== #

# "VPC" Module:
module "vpc" {
  source          = "../modules/vpc"
  region          = var.region_rv
  vpc_cidr        = var.vpc_cidr_rv
  subnet_web_cidr = var.subnet_web_cidr_rv
  subnet_alb_cidr = var.subnet_alb_cidr_rv
  subnet_api_cidr = var.subnet_api_cidr_rv
  subnet_db_cidr  = var.subnet_db_cidr_rv
}

# "RDS" Module:
module "rds" {
  source          = "../modules/rds"
  region          = var.region_rv
  vpc_cidr        = module.vpc.vpc_arn
  subnet_api_cidr = var.subnet_api_cidr_rv
  subnet_db_cidr  = var.subnet_db_cidr_rv
}

# "ECS" Module:
module "ecs" {
  source          = "../modules/ecs"
  region          = var.region_rv
  vpc_cidr        = module.vpc.vpc_arn
  subnet_web_cidr = module.vpc.subnet_web_cidr_rv
  subnet_alb_cidr = module.vpc.subnet_alb_cidr_rv
  subnet_api_cidr = module.vpc.subnet_api_cidr_rv
}

# ==================================================== #