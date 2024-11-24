#!/bin/bash

# Connecting to EKS Cluster
CLUSTER_NAME=$(aws eks list-clusters --region us-east-2 --query "clusters[?contains(@, 'develop')]|[0]" --output text)
if [ -z "$CLUSTER_NAME" ]; then
  echo "Error: Cluster not found!"
  exit 1
fi
aws eks update-kubeconfig --name $CLUSTER_NAME --region us-east-2

# Installing NGINX Ingress Controller via ArgoCD
kubectl apply -f k8s/argocd/applications/develop/ingress-nginx.yaml

# Create Namespaces & Network Policies
kubectl apply -f k8s/infrastructure/namespaces.yaml
kubectl apply -f k8s/infrastructure/network-policies.yaml

# Install Applications via ArgoCD
kubectl apply -f k8s/argocd/applications/develop/api.yaml
kubectl apply -f k8s/argocd/applications/develop/web.yaml
kubectl apply -f k8s/argocd/applications/develop/monitoring.yaml
kubectl apply -f k8s/argocd/applications/develop/logging.yaml
kubectl apply -f k8s/argocd/applications/develop/apparmor.yaml
