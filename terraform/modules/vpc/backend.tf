# ==================================================== #
# =========== S3 Bucket for Backend of VPC =========== #
# ==================================================== #

# "S3 Bucket" - Backend:
terraform {
  backend "s3" {
    region = "us-east-2"
    bucket = "mrjondaw"
    key    = "toptal/VPC/terraform.tfstate"
  }
}

# ==================================================== #