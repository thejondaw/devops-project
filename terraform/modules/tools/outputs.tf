# ==================================================== #
# ================= OUTPUTS OF HELM ================== #
# ==================================================== #

# Output - ArgoCD - Host
output "argocd_host" {
  description = "ArgoCD server hostname"
  value       = kubernetes_service.argocd_server.status.0.load_balancer.ingress.0.hostname
}

# Output - Created Namespaces
output "namespaces" {
  description = "Created namespace names"
  value       = [for ns in kubernetes_namespace.applications : ns.metadata[0].name]
}

# ==================================================== #
