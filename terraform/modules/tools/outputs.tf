# ==================================================== #
# ================= OUTPUTS OF HELM ================== #
# ==================================================== #

# Output of "ArgoCD Host":
output "argocd_host" {
  description = "ArgoCD server hostname"
  value       = try(helm_release.argocd.status[0].load_balancer_ingress[0].hostname, null)
}

# Output of Created "Namespaces":
output "namespaces" {
  description = "Created namespace names"
  value       = [for ns in kubernetes_namespace.applications : ns.metadata[0].name]
}

# Output of "ArgoCD Admin Password":
output "argocd_admin_password" {
  description = "ArgoCD admin password"
  value       = try(data.kubernetes_secret.argocd_secret[0].data["admin.password"], null)
  sensitive   = true
}

# ==================================================== #
