# ==================================================== #
# =========== S3 Bucket for Backend of RDS =========== #
# ==================================================== #

# "S3 Bucket" - Backend:
terraform {
  backend "s3" {
    bucket         = "alexsuff"
    key            = "project/develop/rds.tfstate"
    region         = "us-east-2"
    dynamodb_table = "alexsuff-locks"
    encrypt        = true
  }
}

# ==================================================== #
