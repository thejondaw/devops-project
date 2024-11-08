# ==================================================== #
# ==================== EKS MODULE ==================== #
# ==================================================== #

# Fetch VPC info:
data "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

# Fetch Data of "WEB Subnet":
data "aws_subnet" "web" {
  vpc_id     = data.aws_vpc.main.id
  cidr_block = var.subnet_web_cidr
}

# Fetch Data of "ALB Subnet":
data "aws_subnet" "alb" {
  vpc_id     = data.aws_vpc.main.id
  cidr_block = var.subnet_alb_cidr
}

# Fetch Data of "API Subnet":
data "aws_subnet" "api" {
  vpc_id     = data.aws_vpc.main.id
  cidr_block = var.subnet_api_cidr
}

# Fetch existing User:
data "aws_iam_user" "existing_user" {
  user_name = "devops-project"
}

# Get current Region:
data "aws_region" "current" {}

# # "Secrets Manager" with "Database" credentials:
# data "aws_secretsmanager_secret" "aurora_secret" {
#   name = "aurora-secret-project"
#   # arn = var.aurora_secret.arn
# }

# ==================== IAM Role for EKS ==================== #

# EKS Cluster Role:
resource "aws_iam_role" "eks_cluster" {
  name = "study-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "study-eks-cluster-role"
    Environment = "study"
  }
}

# Attach required policy:
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# ==================== Node Group IAM ==================== #

# Node group role:
resource "aws_iam_role" "node_group" {
  name = "study-eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "study-eks-node-group-role"
    Environment = "study"
  }
}

# Attach minimum required policies for node group:
resource "aws_iam_role_policy_attachment" "node_group_minimum_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])

  policy_arn = each.value
  role       = aws_iam_role.node_group.name
}

# ==================== CloudWatch Log Group ==================== #

resource "aws_cloudwatch_log_group" "eks" {
  name              = "studycluster"
  retention_in_days = 7 # Minimum time for storage

  tags = {
    Name        = "study-eks-logs"
    Environment = "study"
  }
}

# ==================== EKS Cluster ==================== #

resource "aws_eks_cluster" "study" {
  name     = "study-cluster-с"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.28"

  vpc_config {
    subnet_ids = [
      data.aws_subnet.web.id,
      data.aws_subnet.alb.id,
      data.aws_subnet.api.id
    ]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = ["api"]

  depends_on = [
    aws_cloudwatch_log_group.eks,
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name        = "study-cluster-с"
    Environment = "study"
  }
}

# ==================== EKS Node Group ==================== #

resource "aws_eks_node_group" "study" {
  cluster_name    = aws_eks_cluster.study.name
  node_group_name = "study-nodes"
  node_role_arn   = aws_iam_role.node_group.arn

  # One subnet for cost economy:
  subnet_ids = [data.aws_subnet.web.id]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t3.small"]
  disk_size      = 20

  # Disable auto-update:
  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_group_minimum_policies
  ]

  tags = {
    Name        = "study-node-group"
    Environment = "study"
  }
}

# ==================================================== #