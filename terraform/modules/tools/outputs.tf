# ==================================================== #
# ================= OUTPUTS OF HELM ================== #
# ==================================================== #

# Output of "ArgoCD Host":
output "argocd_host" {
  description = "ArgoCD server hostname"
  value       = try(helm_release.argocd.status[0].resources[0], null)
}

# Output of Created "Namespaces":
output "namespaces" {
  description = "Created namespace names"
  value       = [for ns in kubernetes_namespace.applications : ns.metadata[0].name]
}

# ==================================================== #
