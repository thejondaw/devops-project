# ==================================================== #
# ================ OUTPUT OF BACKEND ================= #
# ==================================================== #

# Output of "S3 Bucket" name:
output "bucket_name" {
  description = "Name of the used S3 bucket"
  value       = var.backend_bucket_rv
}

# Output of "DynamoDB Table" name:
output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = data.aws_dynamodb_table.terraform_locks.name
}

# Output of "S3 Bucket" ARN:
output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = data.aws_s3_bucket.terraform_state.arn
}

# ==================================================== #