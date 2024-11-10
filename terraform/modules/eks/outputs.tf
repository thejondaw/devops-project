# ==================================================== #
# ================== OUTPUTS OF EKS ================== #
# ==================================================== #

# Output of "Cluster Endpoint":
output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = aws_eks_cluster.study.endpoint
}

# Output of "Cluster Name":
output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.study.name
}

# Output of "Cluster Certificate Authority":
output "cluster_certificate_authority" {
  description = "Certificate authority data for cluster authentication"
  value       = aws_eks_cluster.study.certificate_authority[0].data
}

# Output of configure "kubectl":
output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.study.name} --region ${data.aws_region.current.name}"
}

# ==================================================== #
