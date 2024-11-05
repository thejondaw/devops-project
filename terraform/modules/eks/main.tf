# ==================================================== #
# ==================== EKS CLUSTER =================== #
# ==================================================== #

# Fetch VPC info:
data "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

# Fetch subnets:
data "aws_subnet" "web" {
  vpc_id     = data.aws_vpc.main.id
  cidr_block = var.subnet_web_cidr
}

data "aws_subnet" "alb" {
  vpc_id     = data.aws_vpc.main.id
  cidr_block = var.subnet_alb_cidr
}

data "aws_subnet" "api" {
  vpc_id     = data.aws_vpc.main.id
  cidr_block = var.subnet_api_cidr
}

# Fetch existing user:
data "aws_iam_user" "existing_user" {
  user_name = "devops-project"
}

# ==================== IAM Role for EKS ==================== #

# Trust policy for EKS
data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# EKS Cluster Role
resource "aws_iam_role" "eks_cluster" {
  name               = "study-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json

  tags = {
    Name = "study-eks-cluster-role"
    Environment = "study"
  }
}

# Attach required policies
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# ==================== Node Group IAM ==================== #

# Trust policy for node group
data "aws_iam_policy_document" "node_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Node group role
resource "aws_iam_role" "node_group" {
  name               = "study-eks-node-group-role"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json

  tags = {
    Name = "study-eks-node-group-role"
    Environment = "study"
  }
}

# Attach minimum required policies for node group
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

# Create log group beforehand to avoid naming conflicts
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/mrjondaw-devops-project-a/cluster"
  retention_in_days = 7  # Минимальное время хранения для экономии

  tags = {
    Name = "study-eks-logs"
    Environment = "study"
  }
}

# ==================== EKS Cluster ==================== #

resource "aws_eks_cluster" "study" {
  name     = "mrjondaw-devops-project-a"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.28"  # Стабильная версия

  # Минимальная конфигурация VPC
  vpc_config {
    subnet_ids = [
      data.aws_subnet.web.id,
      data.aws_subnet.alb.id,
      data.aws_subnet.api.id
    ]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  # Минимальные, но необходимые логи
  enabled_cluster_log_types = ["api"]  # Только критические API логи

  # Важно: явные зависимости
  depends_on = [
    aws_cloudwatch_log_group.eks,
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name = "mrjondaw-devops-project-a"
    Environment = "study"
  }
}

# ==================== EKS Node Group ==================== #

resource "aws_eks_node_group" "study" {
  cluster_name    = aws_eks_cluster.study.name
  node_group_name = "study-nodes"
  node_role_arn   = aws_iam_role.node_group.arn

  # Используем только одну подсеть для экономии
  subnet_ids      = [data.aws_subnet.web.id]

  # Минимальная конфигурация
  scaling_config {
    desired_size = 1  # ВНИМАНИЕ: уменьшил до 1 ноды!
    max_size     = 1
    min_size     = 1
  }

  # Самый дешевый инстанс, поддерживающий EKS
  instance_types = ["t3.small"]
  disk_size = 20

  # Отключаем автообновление
  update_config {
    max_unavailable = 1
  }

  # Важные зависимости
  depends_on = [
    aws_iam_role_policy_attachment.node_group_minimum_policies
  ]

  tags = {
    Name = "study-node-group"
    Environment = "study"
  }
}

# ==================================================== #