# =============== GRAFANA & PROMETHEUS =============== #

# Install - Kube Prometheus Stack
resource "helm_release" "prometheus" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "55.5.0"
  namespace        = kubernetes_namespace.monitoring.metadata[0].name
  create_namespace = false

  values = [<<-EOF
    grafana:
      enabled: true
      ingress:
        enabled: true
        annotations: 
          kubernetes.io/ingress.class: nginx
        hosts: 
          - grafana.${var.environment}.local
        path: /
        pathType: Prefix

    prometheus:
      enabled: true
      prometheusSpec:
        retention: 15d
        storageSpec:
          volumeClaimTemplate:
            spec:
              accessModes: ["ReadWriteOnce"]
              resources:
                requests:
                  storage: 8Gi
        resources:
          limits:
            cpu: 1000m
            memory: 1024Mi
          requests:
            cpu: 500m
            memory: 512Mi
      ingress:
        enabled: true
        annotations: 
          kubernetes.io/ingress.class: nginx
        hosts: 
          - prometheus.${var.environment}.local
        path: /
        pathType: Prefix

    alertmanager:
      enabled: true
      alertmanagerSpec:
        storage:
          volumeClaimTemplate:
            spec:
              accessModes: ["ReadWriteOnce"]
              resources:
                requests:
                  storage: 2Gi
        resources:
          limits:
            cpu: 200m
            memory: 256Mi
          requests:
            cpu: 100m
            memory: 128Mi
      ingress:
        enabled: true
        annotations: 
          kubernetes.io/ingress.class: nginx
        hosts: 
          - alertmanager.${var.environment}.local
        path: /
        pathType: Prefix

    nodeExporter:
      enabled: true
      resources:
        limits:
          cpu: 200m
          memory: 256Mi
        requests:
          cpu: 100m
          memory: 128Mi

    kubeStateMetrics:
      enabled: true
      resources:
        limits:
          cpu: 200m
          memory: 256Mi
        requests:
          cpu: 100m
          memory: 128Mi

    prometheusOperator:
      resources:
        limits:
          cpu: 200m
          memory: 256Mi
        requests:
          cpu: 100m
          memory: 128Mi
  EOF
  ]

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}

# Create - monitoring Namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      name        = "monitoring"
      environment = var.environment
      managed-by  = "terraform"
    }
  }
}

# ==================================================== #
