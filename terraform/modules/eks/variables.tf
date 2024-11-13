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

# ============ EKS CLUSTER CONFIGURATION ============= #

variable "cluster_configuration" {
  description = "EKS cluster configuration"
  type = object({
    version        = string
    min_size       = number
    max_size       = number
    disk_size      = number
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
