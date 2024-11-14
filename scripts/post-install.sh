#!/bin/bash
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

# Check AWS configuration and list clusters
echo "Checking AWS configuration..."
AWS_REGION=$(aws configure get region)
echo "AWS Region: $AWS_REGION"

echo "Available EKS clusters:"
aws eks list-clusters

# Get cluster info with more specific pattern matching
echo "Looking for cluster for $ENVIRONMENT environment..."
CLUSTER_NAME=$(aws eks list-clusters --query "clusters[?contains(@, 'cluster')]|[0]" --output text)
echo "Found cluster: $CLUSTER_NAME"

if [ -z "$CLUSTER_NAME" ]; then
    echo "Error: No EKS cluster found"
    exit 1
fi

# Configure cluster access
echo "Configuring cluster access..."
aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$AWS_REGION"

# Verify cluster access
echo "Verifying cluster access..."
kubectl cluster-info

# Install NGINX Ingress Controller
echo "Installing NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/cloud/deploy.yaml

# Wait for NGINX Ingress Controller to be ready
echo "Waiting for NGINX Ingress Controller namespace to be created..."
kubectl wait --for=condition=Available=True --timeout=60s namespace/ingress-nginx

echo "Waiting for NGINX Ingress Controller to be ready..."
kubectl -n ingress-nginx wait --for=condition=Ready pod -l app.kubernetes.io/component=controller --timeout=300s

# Verify ArgoCD namespace exists
echo "Verifying ArgoCD installation..."
if ! kubectl get namespace argocd &>/dev/null; then
    echo "Error: ArgoCD namespace not found. Please check if ArgoCD was installed correctly."
    exit 1
fi

# Wait for ArgoCD readiness
echo "Waiting for ArgoCD pods to be ready..."
kubectl -n argocd wait --for=condition=Ready pods --all --timeout=300s

# Get ArgoCD admin password
echo "Retrieving ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
if [ -z "$ARGOCD_PASSWORD" ]; then
    echo "Error: Could not retrieve ArgoCD password"
    exit 1
fi

# Get ArgoCD URL
echo "Getting ArgoCD URL..."
ARGOCD_HOST=$(kubectl -n argocd get svc argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
if [ -z "$ARGOCD_HOST" ]; then
    echo "Error: Could not retrieve ArgoCD URL"
    exit 1
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