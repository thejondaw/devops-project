# =================== OUTPUTS ==================== #

# Output for setting "kubectl":
output "configure_kubectl" {
  description = "Configure kubectl: run the following command to update your kubeconfig"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

# Output for "Cluster Name":
output "cluster_name" {
  value = module.eks.cluster_name
}

# Output for "Cluster Endpoint":
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

# Output for "Cluster ID":
output "cluster_id" {
  value = module.eks.cluster_id
}

# Command for Token receiving:
output "get_token_command" {
  value = "aws eks get-token --cluster-name ${module.eks.cluster_name} --region ${var.region}"
}

# ==================================================== #