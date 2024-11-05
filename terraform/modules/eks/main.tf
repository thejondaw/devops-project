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

# Current "AWS User":
data "aws_caller_identity" "current" {}

# =================== IAM USER ==================== #

# Create "IAM User":
resource "aws_iam_user" "eks_user" {
  name = "kuber-user"
  path = "/"

  tags = {
    Name = "EKS Admin User"
  }
}

# Create "Access Policy" to EKS:
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

# Create "Access Keys":
resource "aws_iam_access_key" "eks_user" {
  user = aws_iam_user.eks_user.name
}

# =================== EKS CLUSTER ==================== #

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "devops-project"
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

  # Access control via "Authentication Mode":
  authentication_mode = "API_AND_CONFIG_MAP"

  access_entries = {
    admin = {
      kubernetes_groups = ["admin"]
      principal_arn    = aws_iam_user.eks_user.arn  # Use ARN of created User
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
}

# ==================================================== #