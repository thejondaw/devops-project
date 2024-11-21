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

# Waiting for ArgoCD Pods
kubectl -n argocd wait --for=condition=Ready pods --all --timeout=300s

# Apply Namespaces
kubectl apply -f k8s/infra/namespaces.yaml

# Get Database endpoint
DB_ENDPOINT=$(aws rds describe-db-instances --query 'DBInstances[0].Endpoint.Address' --output text)
if [ -z "$DB_ENDPOINT" ]; then
  echo "Error: Database endpoint not found!"
  exit 1
fi

# Install API Сhart
helm upgrade --install develop-api ./helm/charts/api \
  --namespace develop \
  --values ./helm/environments/develop/values.yaml \
  --set database.host=$DB_ENDPOINT \
  --atomic

# Install Web Сhart
helm upgrade --install develop-web ./helm/charts/web \
  --namespace develop \
  --values ./helm/environments/develop/values.yaml \
  --set api.host="http://develop-api" \
  --atomic
