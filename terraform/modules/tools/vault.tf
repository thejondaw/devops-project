# ==================================================== #
# ================= HASHICORP VAULT ================== #
# ==================================================== #

resource "helm_release" "vault" {
  name             = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  version          = "0.25.0"
  namespace        = "vault"
  create_namespace = true

  values = [<<-EOF
    server:
      affinity: ""
      ha:
        enabled: false
        
      dataStorage:
        size: 1Gi
      
      resources:
        requests:
          memory: "128Mi"
          cpu: "100m"
        limits:
          memory: "256Mi"
          cpu: "200m"

      auditStorage:
        enabled: true
        size: 1Gi

      serviceAccount:
        create: false
        name: "vault"
        annotations: {}

      extraEnvironmentVars:
        VAULT_ADDR: "http://127.0.0.1:8200"
        VAULT_API_ADDR: "http://127.0.0.1:8200"
        AWS_REGION: "${var.region}"
    
    ui:
      enabled: true
      serviceType: LoadBalancer
      externalPort: 8200
    
    injector:
      enabled: true
      replicas: 1
      resources:       
        requests:
          memory: "64Mi"
          cpu: "50m"
        limits:
          memory: "128Mi"
          cpu: "100m"
  EOF
  ]

  depends_on = [kubernetes_service_account.vault]
}

# Namespace - Vault
resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
    
    labels = {
      environment = var.environment
      service     = "vault"
      managed-by  = "terraform"
    }
  }
}

# Service Account - Vault
resource "kubernetes_service_account" "vault" {
  metadata {
    name      = "vault"
    namespace = kubernetes_namespace.vault.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.vault.arn
    }
  }
  depends_on = [kubernetes_namespace.vault]
}

# =============== IAM ROLES & POLICIES =============== #

# IAM Role - Vault
resource "aws_iam_role" "vault" {
  name = "${var.environment}-vault-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = var.environment
    Service     = "vault"
  }
}

# IAM Policy - Secrets Manager
resource "aws_iam_role_policy" "vault_secrets" {
  name = "${var.environment}-vault-secrets-policy"
  role = aws_iam_role.vault.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = ["arn:aws:secretsmanager:${var.region}:*:secret:${var.environment}-aurora-*"]
      }
    ]
  })
}

# ==================================================== #
