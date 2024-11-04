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

# Fetch "Private Subnet #3 (API)" info:
data "aws_subnet" "api" {
  vpc_id     = data.aws_vpc.main.id
  cidr_block = var.subnet_api_cidr
}

# Получаем текущего пользователя AWS
data "aws_caller_identity" "current" {}

# =================== EKS CLUSTER ==================== #

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "devops-project"
  cluster_version = "1.31"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  enable_irsa = true # Enables IAM Roles for Service Accounts

  # Базовые аддоны
  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
    aws-ebs-csi-driver = {} # Для работы с volumes
    metrics-server = {      # Базовый мониторинг
      most_recent = true
    }
  }

  vpc_id = data.aws_vpc.main.id
  subnet_ids = [
    data.aws_subnet.web.id,
    data.aws_subnet.alb.id,
    data.aws_subnet.api.id
  ]

  # Управление доступом через authentication_mode
  authentication_mode = "API_AND_CONFIG_MAP"

  access_entries = {
    # Доступ для пользователя
    admin = {
      kubernetes_groups = ["system:masters"]
      principal_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/your-username"
      type            = "STANDARD"
    }
  }

  # Self Managed Node Group(s)
  eks_managed_node_groups = {
    main = {
      instance_types = ["t3.small"]

      # Необходимые политики для работы узлов
      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
        AmazonEKSWorkerNodePolicy    = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
        AmazonEKS_CNI_Policy         = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      }

      min_size     = 2
      max_size     = 2
      desired_size = 2

      disk_size = 20

      # Labels для нод
      labels = {
        Environment = "learning"
        Type       = "managed"
      }
    }
  }

  # Базовый доступ
  enable_cluster_creator_admin_permissions = true
}

# Output для настройки kubectl
output "configure_kubectl" {
  description = "Configure kubectl: run the following command to update your kubeconfig"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}