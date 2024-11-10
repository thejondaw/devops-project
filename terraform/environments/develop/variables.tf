# ==================================================== #
# ================ VARIABLES of ROOT ================= #
# ==================================================== #

# Variable of "AWS Provider" - Region:
variable "region_rv" {
  description = "Please provide a region information"
  type        = string
}

# Variable for "Backend":
variable "backend_bucket_rv" {
  description = "Name of the S3 bucket for terraform state"
  type        = string
}

# Variable for "Environment":
variable "environment_rv" {
  description = "Environment name (develop, stage, prod)"
  type        = string
}

# ============= CIDR for VPC and Subnets ============= #

# Variable of CIDR Block for "VPC":
variable "vpc_cidr_rv" {
  description = "CIDR Block for VPC"
  type        = string
}

# Variable of CIDR Block for "Public Subnet #1 (WEB)":
variable "subnet_web_cidr_rv" {
  description = "CIDR Block for Public Subnet #1 (WEB)"
  type        = string
}

# Variable of CIDR Block for "Public Subnet #2 (ALB)":
variable "subnet_alb_cidr_rv" {
  description = "CIDR Block for Public Subnet #2 (ALB)"
  type        = string
}

# Variable of CIDR Block for "Private Subnet #3 (API)":
variable "subnet_api_cidr_rv" {
  description = "CIDR Block for Private Subnet #3 (API)"
  type        = string
}

# Variable of CIDR Block for "Private Subnet #4 (DB)":
variable "subnet_db_cidr_rv" {
  description = "CIDR Block for Private Subnet #4 (DB)"
  type        = string
}

# ==================================================== #
