#!/bin/bash

# ==================================================== #
# =============== Post-Install Script ================ #
# ==================================================== #

# Enable error handling:
set -e

# ================ Check Requirements ================= #

echo "Checking required tools..."

REQUIRED_TOOLS=(
    "kubectl:kubectl is required but not installed"
    "aws:AWS CLI is required but not installed"
    "helm:Helm is required but not installed"
)

for tool in "${REQUIRED_TOOLS[@]}"; do
    name="${tool%%:*}"
    message="${tool#*:}"
    command -v "$name" >/dev/null 2>&1 || {
        echo "$message. Aborting." >&2
        exit 1
    }
done

# ============== Get Terraform Outputs =============== #

echo "Fetching Terraform outputs..."

TERRAFORM_DIR="terraform/environments/develop"
CLUSTER_NAME=$(terraform -chdir="$TERRAFORM_DIR" output -raw cluster_name)
AWS_REGION=$(terraform -chdir="$TERRAFORM_DIR" output -raw region)

# ================ Configure Cluster ================= #

echo "Configuring Kubernetes cluster..."

# Update kubeconfig:
echo "Updating kubeconfig..."
aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$AWS_REGION"

# ================= Setup ArgoCD ==================== #

echo "Setting up ArgoCD..."

# Wait for ArgoCD readiness:
echo "Waiting for ArgoCD pods to be ready..."
kubectl -n argocd wait --for=condition=Ready pods --all --timeout=300s

# Get admin password:
echo "Retrieving ArgoCD credentials..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD initial admin password: $ARGOCD_PASSWORD"

# Install ArgoCD CLI if needed:
if ! command -v argocd >/dev/null 2>&1; then
    echo "Installing ArgoCD CLI..."
    curl -sSL -o argocd-linux-amd64 \
        https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    rm argocd-linux-amd64
fi

# Get ArgoCD URL:
ARGOCD_HOST=$(terraform -chdir="$TERRAFORM_DIR" output -raw argocd_host)
echo "ArgoCD is available at: https://$ARGOCD_HOST"

# ============= Deploy Applications ================= #

echo "Deploying applications..."

# Create initial applications:
echo "Creating ArgoCD applications..."
kubectl apply -f k8s/argocd/applications/develop/

# Check deployment status:
echo "Checking application status..."
kubectl -n argocd get applications

# ================== Final Output =================== #

echo "Setup completed successfully!"
echo "----------------------------------------"
echo "Important Information:"
echo "ArgoCD URL: https://$ARGOCD_HOST"
echo "Admin Password: $ARGOCD_PASSWORD"
echo "----------------------------------------"
echo "Please save these credentials in a secure location."

# ==================================================== #