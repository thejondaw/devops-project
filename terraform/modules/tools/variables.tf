# ==================================================== #
# ================ VARIABLES Of HELM ================= #
# ==================================================== #

# Variable - EKS Cluster - Configuration
variable "cluster_configuration" {
  description = "EKS cluster configuration"
  type = object({
    name        = string
    endpoint    = string
    certificate = string
  })
}

# Variable - Environment Configuration - Namespaces
variable "environment_configuration" {
  description = "Environment configuration for namespaces"
  type = object({
    namespaces = list(string)
  })
  default = {
    namespaces = ["develop", "stage", "prod"]
  }
  validation {
    condition     = length(var.environment_configuration.namespaces) > 0
    error_message = "At least one namespace must be specified."
  }
}

# ==================================================== #
