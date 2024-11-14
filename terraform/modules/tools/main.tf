# ==================================================== #
# =================== TOOLS MODULE =================== #
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

# =================== HELM CHARTS ==================== #

# Install - ArgoCD
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.51.6"
  namespace        = "argocd"
  create_namespace = true

  values = [
    file("${path.module}/values/argocd-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

# =================== NAMESPACES ==================== #

# ArgoCD - Namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      name = "argocd"
      type = "system"
    }
  }
}

# Application - Namespaces
resource "kubernetes_namespace" "applications" {
  for_each = toset(var.environment_configuration.namespaces)

  metadata {
    name = each.key
    labels = {
      environment = each.key
      managed-by  = "terraform"
    }
  }
}

# =============== NETWORK POLICIES ================== #

# Network Policies - Default
resource "kubernetes_network_policy" "default" {
  for_each = kubernetes_namespace.applications

  metadata {
    name      = "default-deny"
    namespace = each.value.metadata[0].name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]

    ingress {
      from {
        namespace_selector {
          match_labels = {
            environment = each.value.metadata[0].name
          }
        }
      }
    }

    egress {
      to {
        ip_block {
          cidr = "0.0.0.0/0"
        }
      }
    }
  }
}

# ================= RBAC Resources ================== #

#  ArgoCD Admin - ClusterRole
resource "kubernetes_cluster_role" "argocd_admin" {
  metadata {
    name = "argocd-admin-role"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

# ArgoCD Admin - ClusterRoleBinding
resource "kubernetes_cluster_role_binding" "argocd_admin" {
  metadata {
    name = "argocd-admin-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.argocd_admin.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "argocd-application-controller"
    namespace = "argocd"
  }
}

# ==================================================== #
