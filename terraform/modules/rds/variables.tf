# ==================================================== #
# ============== Variables of RDS Module ============= #
# ==================================================== #

# Variable for "Taggs":
variable "environment" {
  description = "Environment name (e.g., develop, stage, prod)"
  type        = string
  default     = "develop" # Default to "develop" as it's most common use case
}

# ==================================================== #

# Variable for "AWS Region":
variable "region" {
  description = "AWS Region"
  type        = string
}

# =================  VPC and Subnets ================= #

# Variable for CIDR Block of "VPC":
variable "vpc_cidr" {
  description = "CIDR Block for VPC"
}

# Variable for CIDR Block of "Private Subnet #3 (API)":
variable "subnet_api_cidr" {
  description = "CIDR Block for Private Subnet #3 (API)"
}

# Variable for CIDR Block of "Private Subnet #4 (DB)":
variable "subnet_db_cidr" {
  description = "CIDR Block for Private Subnet #4 (DB)"
}

# ==================================================== #
