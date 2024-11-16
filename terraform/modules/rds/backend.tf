# ==================================================== #
# =========== S3 BUCKET FOR BACKEND OF RDS =========== #
# ==================================================== #

# S3 Bucket - Backend
terraform {
  backend "s3" {
    bucket  = "alexsuff"
    key     = "project/develop/rds.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}

# ==================================================== #
