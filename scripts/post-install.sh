#!/bin/bash

# Connecting to EKS Cluster
CLUSTER_NAME=$(aws eks list-clusters --region us-east-2 --query "clusters[?contains(@, 'develop')]|[0]" --output text)
if [ -z "$CLUSTER_NAME" ]; then
  echo "Error: Cluster not found!"
  exit 1
fi
aws eks update-kubeconfig --name $CLUSTER_NAME --region us-east-2

# ==================================================== #

# Installing NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/cloud/deploy.yaml
kubectl -n ingress-nginx wait --for=condition=Ready pod -l app.kubernetes.io/component=controller --timeout=300s

# Install separate ingress controller for monitoring
kubectl apply -f k8s/infra/monitoring-ingress.yaml
kubectl -n ingress-nginx wait --for=condition=Ready pod -l app.kubernetes.io/instance=monitoring-ingress-nginx --timeout=300s

# ==================================================== #

# Waiting for ArgoCD pods
kubectl -n argocd wait --for=condition=Ready pods --all --timeout=300s

# Create namespaces and network policies
for ns in develop stage prod; do
  # Create namespace
  echo "Creating namespace: $ns"
  kubectl create namespace $ns --dry-run=client -o yaml | kubectl apply -f -

  # Apply network policy
  echo "Applying network policy for: $ns"
  cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: $ns
spec:
  podSelector: {}
  policyTypes: ["Ingress", "Egress"]
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              environment: $ns
  egress:
    - to:
        - ipBlock:
            cidr: 0.0.0.0/0
EOF
done

# ==================================================== #

# Get Database endpoint
DB_ENDPOINT=$(aws rds describe-db-instances --query 'DBInstances[0].Endpoint.Address' --output text)
if [ -z "$DB_ENDPOINT" ]; then
  echo "Error: Database endpoint not found!"
  exit 1
fi

# Cleanup existing resources in develop namespace
echo "Cleaning up existing resources in develop namespace..."
kubectl delete ingress,deployment,service,configmap --all -n develop --force --grace-period=0

# Wait for resources to be deleted
echo "Waiting for resources to be deleted..."
sleep 10

# ==================================================== #

# Install - API - Helm Chart
echo "Installing API chart..."
helm uninstall develop-api -n develop || true
helm install develop-api ./helm/charts/api \
  --namespace develop \
  --values ./helm/environments/develop/values.yaml \
  --set database.host=$DB_ENDPOINT \
  --wait \
  --timeout 5m

# Install - WEB - Helm Chart
echo "Installing Web chart..."
helm uninstall develop-web -n develop || true
helm install develop-web ./helm/charts/web \
  --namespace develop \
  --values ./helm/environments/develop/values.yaml \
  --set api.host="http://develop-api" \
  --wait \
  --timeout 5m

# Install - Grafana & Prometheus - Helm Chart
echo "Installing Monitoring chart..."
cd helm/charts/monitoring && helm dependency update && cd ../../..
helm install monitoring ./helm/charts/monitoring \
  --namespace monitoring \
  --values ./helm/environments/develop/values.yaml \
  --create-namespace \
  --timeout 10m

# ==================================================== #

# Install Applications to ArgoCD dashboard
echo "Installing ArgoCD applications..."
kubectl apply -f k8s/argocd/applications/develop/api.yaml
kubectl apply -f k8s/argocd/applications/develop/web.yaml
kubectl apply -f k8s/argocd/applications/develop/monitoring.yaml

# ==================================================== #

echo "Installation completed successfully!"