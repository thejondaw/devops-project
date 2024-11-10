# ==================================================== #
# =================== HELM Module ==================== #
# ==================================================== #

# "Helm Provider" - Configure Kubernetes Connection:
provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}

# =================== Helm Charts ==================== #

# "ArgoCD" - Continuous Delivery Tool:
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

# ================== Namespaces ===================== #

# "ArgoCD Namespace":
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"

    labels = {
      name = "argocd"
      type = "system"
    }
  }
}

# "Application Namespaces" for Different Environments:
resource "kubernetes_namespace" "applications" {
  for_each = toset(["develop", "stage", "prod"])

  metadata {
    name = each.key

    labels = {
      environment = each.key
      managed-by  = "terraform"
    }
  }
}

# =============== Network Policies ================== #

# Default "Network Policies" for Each Namespace:
resource "kubernetes_network_policy" "default" {
  for_each = kubernetes_namespace.applications

  metadata {
    name      = "default-deny"
    namespace = each.value.metadata[0].name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]

    # Ingress Rules:
    ingress {
      from {
        namespace_selector {
          match_labels = {
            environment = each.value.metadata[0].name
          }
        }
      }
    }

    # Egress Rules:
    egress {
      to {
        ip_block {
          cidr = "0.0.0.0/0"
          except = [
            "169.254.0.0/16", # Link-local addresses
            "172.16.0.0/12",  # Private network
            "192.168.0.0/16", # Private network
          ]
        }
      }
    }
  }
}

# ==================================================== #
