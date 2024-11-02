# ==================================================== #
# ==================== EKS Module ==================== #
# ==================================================== #

# Fetch "VPC" info:
data "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

# Fetch "Private Subnet #1 (WEB)" info:
data "aws_subnet" "web" {
  vpc_id     = data.aws_vpc.main.id
  cidr_block = var.subnet_web_cidr
}

# Fetch "Private Subnet #2 (ALB)" info:
data "aws_subnet" "alb" {
  vpc_id     = data.aws_vpc.main.id
  cidr_block = var.subnet_alb_cidr
}

# Fetch "Private Subnet #3 (web)" info:
data "aws_subnet" "api" {
  vpc_id     = data.aws_vpc.main.id
  cidr_block = var.subnet_api_cidr
}

# =================== EKS CLUSTER ==================== #

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "devops-project"
  cluster_version = "1.31"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  enable_irsa = true # Enables IAM Roles for Service Accounts

  # Минимальный набор аддонов
  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  # Используем data для получения VPC и подсетей
  vpc_id = data.aws_vpc.main.id
  subnet_ids = [
    data.aws_subnet.web.id,
    data.aws_subnet.alb.id,
    data.aws_subnet.api.id
  ]

  # aws-auth configmap
  manage_aws_auth_configmap = false

  aws_auth_roles = [
    {
      rolearn  = aws_iam_role.eks_cluster.arn
      username = "role1"
      groups   = ["system:masters"]
    }
  ]

  # Self Managed Node Group(s)
  eks_managed_node_groups = {
    main = {
      instance_types = ["t3.small"]
      iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }

      min_size     = 2
      max_size     = 2
      desired_size = 2

      disk_size = 20
    }
  }

  # Базовый доступ
  enable_cluster_creator_admin_permissions = true
}
