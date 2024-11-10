# ==================================================== #
# ==================== EKS Module ==================== #
# ==================================================== #

# ================== Time Provider =================== #

# Add timestamp for unique naming:
resource "time_static" "cluster_timestamp" {}

# =================== Local Values =================== #

locals {
  # Format: env-clustername-YYYYMMDDHHMMSS
  cluster_name = "${var.environment}-cluster-${formatdate("YYYYMMDDHHmmss", time_static.cluster_timestamp.rfc3339)}"

  # Common tags for all resources:
  common_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "devops-project"
    CreatedAt   = time_static.cluster_timestamp.rfc3339
    Owner       = "DevOps"
    Service     = "EKS"
  }

  # Tags specific for network resources:
  network_tags = {
    NetworkType = "EKS-Network"
    VPCName     = data.aws_vpc.main.tags["Name"]
  }

  # Tags specific for security resources:
  security_tags = {
    SecurityType = "EKS-Security"
    Compliance   = "HIPAA"  # Если требуется
    Encryption   = "AES256"
  }

  # Tags specific for compute resources:
  compute_tags = {
    ComputeType = "EKS-Compute"
    Scheduler   = "kubernetes"
  }
}

# =================== Data Sources ================== #

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

# ================== IAM Resources ================== #

# "EKS Cluster Role":
resource "aws_iam_role" "eks_cluster" {
  name = "${local.cluster_name}-role"

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

  tags = merge(local.common_tags, local.security_tags, {
    Name = "${local.cluster_name}-role"
    Role = "EKS-Cluster"
  })
}

# Attach required policy:
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# "Node Group Role":
resource "aws_iam_role" "node_group" {
  name = "${local.cluster_name}-node-group-role"

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

  tags = merge(local.common_tags, local.security_tags, {
    Name = "${local.cluster_name}-node-group-role"
    Role = "EKS-NodeGroup"
  })
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

# ================ CloudWatch Logs ================== #

# "CloudWatch Log Group" for EKS:
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${local.cluster_name}/cluster"
  retention_in_days = 7

  tags = merge(local.common_tags, {
    Name        = "${local.cluster_name}-logs"
    LogType     = "EKS-Cluster-Logs"
    Retention   = "7-days"
  })
}

# ================== EKS Cluster =================== #

# "EKS Cluster":
resource "aws_eks_cluster" "study" {
  name     = local.cluster_name
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

  tags = merge(local.common_tags, local.network_tags, {
    Name         = local.cluster_name
    ClusterType  = "EKS"
    Version      = "1.28"
    Architecture = "Multi-AZ"
  })
}

# ================= Node Group ===================== #

# "EKS Node Group":
resource "aws_eks_node_group" "study" {
  cluster_name    = aws_eks_cluster.study.name
  node_group_name = "${local.cluster_name}-nodes"
  node_role_arn   = aws_iam_role.node_group.arn

  subnet_ids = [data.aws_subnet.web.id]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t3.small"]
  disk_size      = 20

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_group_minimum_policies
  ]

  tags = merge(local.common_tags, local.compute_tags, {
    Name           = "${local.cluster_name}-node-group"
    NodeGroupType  = "Application"
    InstanceType   = "t3.small"
    DiskSize       = "20GB"
    AutoScaling    = "Enabled"
  })
}

# ==================================================== #