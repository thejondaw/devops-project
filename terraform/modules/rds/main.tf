# ==================================================== #
# ==================== RDS Module ==================== #
# ==================================================== #

# "Serverless v2 RDS cluster" - "Aurora PostgreSQL":
resource "aws_rds_cluster" "aurora_postgresql" {
  cluster_identifier     = "example"
  engine                 = "aurora-postgresql"
  engine_mode            = "provisioned"
  engine_version         = "15.3"
  database_name          = "toptal"   # VARS
  master_username        = "jondaw"     # VARS
  master_password        = "password"
  storage_encrypted      = true
  db_subnet_group_name   = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids = [aws_security_group.sg_aurora.id]
  skip_final_snapshot    = false

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
}

# Instance for "Serverless v2 RDS Cluster":
resource "aws_rds_cluster_instance" "rds_instance" {
  cluster_identifier = aws_rds_cluster.aurora_postgresql.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.aurora_postgresql.engine
  engine_version     = aws_rds_cluster.aurora_postgresql.engine_version
}

# ==================================================== #

# Fetch "VPC" info:
data "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

# Fetch "Private Subnet #3 (API)" info:
data "aws_subnet" "api" {
  vpc_id     = data.aws_vpc.main.id
  cidr_block = var.subnet_api_cidr
}

# Fetch "Private Subnet #4 (DB)" info:
data "aws_subnet" "db" {
  vpc_id     = data.aws_vpc.main.id
  cidr_block = var.subnet_db_cidr
}

# ==================================================== #

# "Subnet Group" for Database:
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = [data.aws_subnet.api.id, data.aws_subnet.db.id]
}

# ==================================================== #

# "Security Group" to "Aurora PostgreSQL" Database access:
resource "aws_security_group" "sg_aurora" {
  name        = "aurora-db"
  description = "Allow Aurora PostgreSQL access"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==================================================== #

# # Random "Password" for "Secret Manager":
# resource "random_password" "aurora_password" {
#   length  = 16
#   special = true
#   numeric = true
#   upper   = true
# }

# # "Secret Manager":
# resource "aws_secretsmanager_secret" "aurora_secret" {
#   name = "aurora-secret-project"
# }

# # Attach "Credentials" for "Secret Manager":
# resource "aws_secretsmanager_secret_version" "aurora_credentials" {
#   secret_id = aws_secretsmanager_secret.aurora_secret.id
#   secret_string = jsonencode({
#     username = aws_rds_cluster.aurora_postgresql.master_username
#     password = random_password.aurora_password.result
#     host     = aws_rds_cluster.aurora_postgresql.endpoint
#     port     = aws_rds_cluster.aurora_postgresql.port
#     dbname   = aws_rds_cluster.aurora_postgresql.database_name
#   })
# }


# ==================================================== #
