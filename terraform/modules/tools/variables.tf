# ==================================================== #
# =============== VARIABLES Of HELM ================== #
# ==================================================== #

# Variable for "Cluster Endpoint":
variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

# Variable for "Cluster Name":
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

# Variable for "Cluster CA Certificate":
variable "cluster_ca_certificate" {
  description = "EKS cluster CA certificate"
  type        = string
}

# ==================================================== #
