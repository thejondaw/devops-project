# ==================================================== #
# =========== S3 Bucket for Backend of VPC =========== #
# ==================================================== #

# # "S3 Bucket" - Backend:
# terraform {
#   backend "s3" {
#     region = "us-east-2"
#     bucket = "alexsuff"
#     key    = "vpc/terraform.tfstate"
#   }
# }

# ==================================================== #

# "S3 Bucket" - Backend:
terraform {
  backend "s3" {
    bucket         = "alexsuff"
    key            = "project/develop/vpc.tfstate"
    region         = "us-east-2"
    dynamodb_table = "alexsuff-locks"
    encrypt        = true
  }
}

# ==================================================== #
