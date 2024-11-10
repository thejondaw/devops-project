# ==================================================== #
# ================= OUTPUTS Of ROOT ================== #
# ==================================================== #

# Output of "ArgoCD Host":
output "argocd_host" {
  description = "ArgoCD server hostname"
  value       = module.tools.argocd_host
}

# Output of Created "Namespaces":
output "namespaces" {
  description = "Created namespaces"
  value       = module.tools.namespaces
}

# ==================================================== #
