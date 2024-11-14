# ==================================================== #
# ================= OUTPUTS OF HELM ================== #
# ==================================================== #

# Output - Created Namespaces
output "namespaces" {
  description = "Created namespace names"
  value       = [for ns in kubernetes_namespace.applications : ns.metadata[0].name]
}

# ==================================================== #
