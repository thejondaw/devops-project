# ==================================================== #
# ===================== ARGO-CD ====================== #
# ==================================================== #

# Install - ArgoCD
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.51.6"
  namespace        = "argocd"
  create_namespace = true

  values = [<<-EOF
    server:
      extraArgs:
        - --insecure
      service:
        type: LoadBalancer
        annotations:
          service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
          service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
          service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
          service.beta.kubernetes.io/aws-load-balancer-name: "argocd-${var.environment}-lb"
        labels:
          app: argocd
          managedBy: terraform
          service: argocd
          component: server
          environment: ${var.environment}
        loadBalancerSourceRanges:
          - "0.0.0.0/0"

      config:
        rbac:
          defaultPolicy: role:readonly
          policy.default: role:readonly
          policy.csv: |
            p, role:org-admin, applications, *, */*, allow
            p, role:org-admin, clusters, get, *, allow
            p, role:org-admin, projects, get, *, allow

        repositories: |
          - type: git
            url: https://github.com/thejondaw/devops-project.git
            name: infrastructure

    controller:
      replicas: 1
      resources:
        limits:
          cpu: 500m
          memory: 512Mi
        requests:
          cpu: 250m
          memory: 256Mi

    redis:
      resources:
        limits:
          cpu: 200m
          memory: 256Mi
        requests:
          cpu: 100m
          memory: 128Mi
  EOF
  ]

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

# ==================== NAMESPACE ==================== #

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

# ================= RBAC RESOURCES ================== #

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
