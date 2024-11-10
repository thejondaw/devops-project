# ==================================================== #
# =========== S3 Bucket for Backend of RDS =========== #
# ==================================================== #

# # "S3 Bucket" - Backend:
# terraform {
#   backend "s3" {
#     region = "us-east-2"
#     bucket = "alexsuff"
#     key    = "rds/terraform.tfstate"
#   }
# }

# ==================================================== #

# "S3 Bucket" - Backend:
terraform {
  backend "s3" {
    bucket         = "alexsuff"
    key            = "develop/rds/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "alexsuff-locks"
    encrypt        = true
  }
}

# ==================================================== #
