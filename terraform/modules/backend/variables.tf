# ==================================================== #
# =============== VARIABLES OF BACKEND =============== #
# ==================================================== #

# Variable for "S3 Bucket" name:
variable "backend_bucket_rv" {
  description = "Name of the S3 bucket for terraform state"
  type        = string
}
# Variable for "Environment":
variable "environment_rv" {
  description = "Environment name (e.g., develop, stage, prod)"
  type        = string
}

# Variable for "AWS Region":
variable "region_rv" {
  description = "AWS Region for backend resources"
  type        = string
  default     = "us-east-2"
}

# ==================================================== #
