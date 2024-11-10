# ==================================================== #
# =============== VARIABLES OF BACKEND =============== #
# ==================================================== #

# Variable for "S3 Bucket" name:
variable "bucket_name" {
  description = "Name of the S3 bucket for terraform state"
  type        = string
}

# Variable for "Environment":
variable "environment" {
  description = "Environment name (e.g., develop, stage, prod)"
  type        = string
}

# Variable for "AWS Region":
variable "region" {
  description = "AWS Region for backend resources"
  type        = string
  default     = "us-east-2"
}

# ==================================================== #
