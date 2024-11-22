# ==================================================== #
# ================ PROVIDERS OF TOOLS ================ #
# ==================================================== #

# Provider - Terraform
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl" # Было hashicorp/kubectl
      version = "~> 1.14.0"
    }
  }
}

# Prodiver - kubectl
provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.id]
  }
}

# Provider - Kubernetes
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.id]
  }
}

# Provider - Helm
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.id]
      command     = "aws"
    }
  }
}

# =================== DATA SOURCES =================== #

# Fetch - EKS Cluster
data "aws_eks_clusters" "available" {
}

data "aws_eks_cluster" "cluster" {
  name = [
    for cluster_name in data.aws_eks_clusters.available.names :
    cluster_name
    if can(regex("^${var.environment}-cluster-", cluster_name))
  ][0]
}

# Fetch - EKS Cluster - Auth
data "aws_eks_cluster_auth" "cluster" {
  name = data.aws_eks_cluster.cluster.name
}

# ==================================================== #
