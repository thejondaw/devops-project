# ==================================================== #
# ================== BACKEND MODULE ================== #
# ==================================================== #

# "S3 Bucket" - Terraform State:
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
    Project     = "devops-project"
    ManagedBy   = "terraform"
    Type        = "terraform-backend"
  }
}

# ============== S3 Bucket Settings ================= #

# Enable "Versioning" for State Files:
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable Server-Side "Encryption":
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block "Public Access":
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ================ DynamoDB Table =================== #

# "DynamoDB Table" - State Locking:
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.bucket_name}-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "${var.bucket_name}-locks"
    Environment = var.environment
    Project     = "devops-project"
    ManagedBy   = "terraform"
    Type        = "terraform-backend-lock"
  }
}

# ==================================================== #

# После создания бэкенда, используйте такой блок в других модулях:
#

#
# ==================================================== #