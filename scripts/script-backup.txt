#!/bin/bash

# Connecting to EKS Cluster
CLUSTER_NAME=$(aws eks list-clusters --region us-east-2 --query "clusters[?contains(@, 'develop')]|[0]" --output text)
if [ -z "$CLUSTER_NAME" ]; then
  echo "Error: Cluster not found!"
  exit 1
fi
aws eks update-kubeconfig --name $CLUSTER_NAME --region us-east-2

# Installing NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/cloud/deploy.yaml
kubectl -n ingress-nginx wait --for=condition=Ready pod -l app.kubernetes.io/component=controller --timeout=300s

# Waiting for ArgoCD pods
kubectl -n argocd wait --for=condition=Ready pods --all --timeout=300s

# Create namespaces
kubectl create namespace develop --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace stage --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -

# Get Database endpoint
DB_ENDPOINT=$(aws rds describe-db-instances --query 'DBInstances[0].Endpoint.Address' --output text)
if [ -z "$DB_ENDPOINT" ]; then
  echo "Error: Database endpoint not found!"
  exit 1
fi

# Cleanup existing resources
echo "Cleaning up existing resources..."
kubectl delete ingress --all -n develop --force --grace-period=0
kubectl delete deployment --all -n develop --force --grace-period=0
kubectl delete service --all -n develop --force --grace-period=0
kubectl delete configmap --all -n develop --force --grace-period=0

# Wait for resources to be deleted
echo "Waiting for resources to be deleted..."
sleep 10

# Install API chart
echo "Installing API chart..."
helm uninstall develop-api -n develop || true
helm install develop-api ./helm/charts/api \
  --namespace develop \
  --values ./helm/environments/develop/values.yaml \
  --set database.host=$DB_ENDPOINT \
  --wait \
  --timeout 5m

# Install Web chart
echo "Installing Web chart..."
helm uninstall develop-web -n develop || true
helm install develop-web ./helm/charts/web \
  --namespace develop \
  --values ./helm/environments/develop/values.yaml \
  --set api.host="http://develop-api" \
  --wait \
  --timeout 5m

# Install Monitoring chart
echo "Installing Monitoring chart..."
cd helm/charts/monitoring && helm dependency update && cd ../../..
helm uninstall monitoring -n monitoring || true
helm install monitoring ./helm/charts/monitoring \
  --namespace monitoring \
  --values ./helm/environments/develop/values.yaml \
  --wait \
  --timeout 10m

# Install Applications to ArgoCD dashboard
kubectl apply -f k8s/argocd/applications/develop/api.yaml
kubectl apply -f k8s/argocd/applications/develop/web.yaml
kubectl apply -f k8s/argocd/applications/develop/monitoring.yaml

# ===== OUTPUTS ===== #

# Print access information
echo "Getting access information..."

echo "Grafana endpoint:"
kubectl get ingress -n monitoring monitoring-grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' || echo "Not available yet"

echo "Prometheus endpoint:"
kubectl get ingress -n monitoring monitoring-prometheus -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' || echo "Not available yet"

echo "AlertManager endpoint:"
kubectl get ingress -n monitoring monitoring-alertmanager -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' || echo "Not available yet"

# Get initial Grafana admin password
echo "Grafana admin password:"
kubectl get secret -n monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode || echo "Not available yet"