# ==================================================== #
# ============== VARIABLES OF ECS MODULE ============= #
# ==================================================== #

# Variable - AWS Region
variable "region" {
  description = "AWS Region"
  type        = string
}

# Variable - Environment - Name
variable "environment" {
  description = "Environment name (develop, stage, prod)"
  type        = string
  validation {
    condition     = contains(["develop", "stage", "prod"], var.environment)
    error_message = "Environment must be develop, stage, or prod."
  }
}

# ===================== NETWORK ====================== #

# Variables - CIDR Block - VPC & Subnets
variable "network_configuration" {
  description = "Network configuration for EKS cluster"
  type = object({
    vpc_id = string
    subnets = object({
      web = object({
        id         = string
        cidr_block = string
      })
      alb = object({
        id         = string
        cidr_block = string
      })
      api = object({
        id         = string
        cidr_block = string
      })
    })
  })
}

# ============ EKS CLUSTER CONFIGURATION ============= #

variable "cluster_configuration" {
  description = "EKS cluster configuration"
  type = object({
    version      = string
    min_size     = number
    max_size     = number
    disk_size    = number
    instance_types = list(string)
  })
  default = {
    version        = "1.28"
    min_size       = 1
    max_size       = 3
    disk_size      = 20
    instance_types = ["t3.small"]
  }
  validation {
    condition     = can(regex("^1\\.(2[3-8])$", var.cluster_configuration.version))
    error_message = "Kubernetes version must be between 1.23 and 1.28."
  }
}

# ==================================================== #
