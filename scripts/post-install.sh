#!/bin/bash

# Enable error handling
set -e

# Get environment from argument or use default
ENVIRONMENT=${1:-develop}

echo "Starting post-install configuration for $ENVIRONMENT environment..."

# Check requirements
echo "Checking required tools..."
for tool in kubectl aws helm; do
    if ! command -v "$tool" &> /dev/null; then
        echo "$tool is required but not installed. Aborting."
        exit 1
    fi
done

# Get cluster info from AWS
echo "Getting cluster info..."
CLUSTER_NAME=$(aws eks list-clusters --query "clusters[?contains(@, '$ENVIRONMENT')]" --output text)
AWS_REGION=$(aws configure get region)
if [ -z "$CLUSTER_NAME" ]; then
    echo "Failed to find cluster for environment $ENVIRONMENT"
    exit 1
fi

# Configure cluster access
echo "Configuring cluster access..."
aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$AWS_REGION"

# Install NGINX Ingress Controller
echo "Installing NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/cloud/deploy.yaml

# Wait for NGINX Ingress Controller to be ready
echo "Waiting for NGINX Ingress Controller to be ready..."
kubectl -n ingress-nginx wait --for=condition=Ready pod -l app.kubernetes.io/component=controller --timeout=300s

# Wait for ArgoCD readiness
echo "Waiting for ArgoCD pods to be ready..."
kubectl -n argocd wait --for=condition=Ready pods --all --timeout=300s

# Get ArgoCD admin password
echo "Retrieving ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Get ArgoCD URL
ARGOCD_HOST=$(kubectl -n argocd get svc argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Deploy initial applications if they exist
APPS_DIR="k8s/argocd/applications/$ENVIRONMENT"
if [ -d "$APPS_DIR" ]; then
    echo "Deploying initial applications..."
    kubectl apply -f "$APPS_DIR"
    echo "Checking application status..."
    kubectl -n argocd get applications
fi

# Print access information
echo "Setup completed successfully!"
echo "----------------------------------------"
echo "ArgoCD Access Information:"
echo "URL: https://$ARGOCD_HOST"
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"
echo "----------------------------------------"
echo "NGINX Ingress Controller is installed and running"
