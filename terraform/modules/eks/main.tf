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

# Fetch existing "IAM User":
data "aws_iam_user" "existing_user" {
  user_name = "devops-project"
}

# =================== EKS CLUSTER ==================== #

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "thejondaw-devops-project"
  cluster_version = "1.31"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  enable_irsa = true

  create_aws_access_entry = false

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
      principal_arn    = data.aws_iam_user.existing_user.arn  # Use existing user's ARN
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