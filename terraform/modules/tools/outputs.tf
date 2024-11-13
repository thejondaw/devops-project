# ==================================================== #
# ================= OUTPUTS OF HELM ================== #
# ==================================================== #

# Output - ArgoCD - Host
output "argocd_host" {
  description = "ArgoCD server hostname"
  value       = try(helm_release.argocd.status[0].load_balancer_ingress[0].hostname, null)
}

# Output - Created Namespaces
output "namespaces" {
  description = "Created namespace names"
  value       = [for ns in kubernetes_namespace.applications : ns.metadata[0].name]
}

# ==================================================== #
