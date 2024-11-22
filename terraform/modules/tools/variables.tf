# ==================================================== #
# ================ VARIABLES Of TOOLS ================ #
# ==================================================== #

# Variable - Environment
variable "environment" {
  description = "Environment name (develop, stage, prod)"
  type        = string
  validation {
    condition     = contains(["develop", "stage", "prod"], var.environment)
    error_message = "Environment must be develop, stage, or prod."
  }
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
