# ==================================================== #
# ============== VARIABLES OF ECS MODULE ============= #
# ==================================================== #

# Variable for "AWS Region":
variable "region" {
  description = "AWS Region"
  type        = string
}

# Variable for "Environment" name:
variable "environment" {
  description = "Environment name (develop, stage, prod)"
  type        = string
  default     = "develop"
}

# ============= CIDR for VPC and Subnets ============= #

# Variable for CIDR Block of "VPC":
variable "vpc_cidr" {
  description = "CIDR Block for VPC"
}

# Variable for CIDR Block of "Public Subnet #1 (WEB)":
variable "subnet_web_cidr" {
  description = "CIDR Block for Public Subnet #1 (WEB)"
}

# Variable for CIDR Block of "Public Subnet #2 (ALB)":
variable "subnet_alb_cidr" {
  description = "CIDR Block for Public Subnet #2 (ALB)"
}

# Variable for CIDR Block of "Private Subnet #3 (API)":
variable "subnet_api_cidr" {
  description = "CIDR Block for Private Subnet #3 (API)"
}

# ==================================================== #
