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

# =================== IAM USER ==================== #

# Создание IAM пользователя
resource "aws_iam_user" "eks_user" {
  name = "mrjondaw"
  path = "/"

  tags = {
    Name = "EKS Admin User"
  }
}

# Создание политики доступа к EKS
resource "aws_iam_user_policy" "eks_user_policy" {
  name = "eks-user-policy"
  user = aws_iam_user.eks_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:*",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "iam:GetRole",
          "iam:ListRoles",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfiles",
          "iam:ListRolePolicies",
          "iam:GetInstanceProfile",
          "iam:GetPolicy",
          "iam:GetPolicyVersion"
        ]
        Resource = "*"
      }
    ]
  })
}

# Создание access keys
resource "aws_iam_access_key" "eks_user" {
  user = aws_iam_user.eks_user.name
}

# =================== EKS CLUSTER ==================== #

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "mrjondaw-devops-project"
  cluster_version = "1.31"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  enable_irsa = true

  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
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
    admin = {
      kubernetes_groups = ["admin"]
      principal_arn    = aws_iam_user.eks_user.arn  # используем ARN созданного пользователя
      type            = "STANDARD"
    }
  }

  eks_managed_node_groups = {
    main = {
      instance_types = ["t3.small"]

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

      labels = {
        Environment = "learning"
        Type       = "managed"
      }
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "learning"
    Terraform   = "true"
  }
}

# =================== OUTPUTS ==================== #

# Output для настройки kubectl
output "configure_kubectl" {
  description = "Configure kubectl: run the following command to update your kubeconfig"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

# Output для access key
output "access_key_id" {
  value = aws_iam_access_key.eks_user.id
}

# Output для secret key (sensitive)
output "secret_access_key" {
  value     = aws_iam_access_key.eks_user.secret
  sensitive = true
}

# Output для ARN пользователя
output "user_arn" {
  value = aws_iam_user.eks_user.arn
}

# Output для имени кластера
output "cluster_name" {
  value = module.eks.cluster_name
}

# Output для endpoint кластера
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

# Output для ID кластера
output "cluster_id" {
  value = module.eks.cluster_id
}

# Показываем команду для получения токена
output "get_token_command" {
  value = "aws eks get-token --cluster-name ${module.eks.cluster_name} --region ${var.region}"
}