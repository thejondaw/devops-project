#!/bin/bash

# Setting up "kubectl" aliases
echo 'alias k="kubectl" && alias kc="kubectl config" && alias kcc="kubectl config current-context" && alias kcg="kubectl config get-contexts" && alias kcs="kubectl config set-context" && alias kcu="kubectl config use-context" && alias ka="kubectl apply -f" && alias kd="kubectl delete" && alias kdf="kubectl delete -f" && alias kdp="kubectl delete pod" && alias kg="kubectl get" && alias kga="kubectl get all" && alias kgaa="kubectl get all --all-namespaces" && alias kgn="kubectl get nodes" && alias kgno="kubectl get nodes -o wide" && alias kgp="kubectl get pods" && alias kgpa="kubectl get pods --all-namespaces" && alias kgpo="kubectl get pods -o wide" && alias kgs="kubectl get services" && alias kgsa="kubectl get services --all-namespaces" && alias kl="kubectl logs" && alias klf="kubectl logs -f" && alias kpf="kubectl port-forward" && alias kex="kubectl exec -it" && alias kdesc="kubectl describe" && alias ktp="kubectl top pod" && alias ktn="kubectl top node"' >> ~/.bashrc
source ~/.bashrc

# Connecting to EKS Cluster
CLUSTER_NAME=$(aws eks list-clusters --region us-east-2 --query "clusters[?contains(@, 'develop')]|[0]" --output text)
if [ -z "$CLUSTER_NAME" ]; then
  echo "Error: Cluster not found!"
  exit 1
fi
aws eks update-kubeconfig --name $CLUSTER_NAME --region us-east-2

# Installing NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/cloud/deploy.yaml

# Waiting for NGINX controller to be ready
kubectl -n ingress-nginx wait --for=condition=Ready pod -l app.kubernetes.io/component=controller --timeout=300s

# Waiting for ArgoCD pods to be ready
kubectl -n argocd wait --for=condition=Ready pods --all --timeout=300s

# Retrieving ArgoCD server URL
ARGOCD_URL=$(kubectl -n argocd get svc argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "ArgoCD is accessible at URL: $ARGOCD_URL"

# Retrieving ArgoCD admin password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD password: $ARGOCD_PASSWORD"

# Applying infrastructure manifests
kubectl apply -f k8s/infra/namespaces.yaml

# Get Database endpoint
DB_ENDPOINT=$(aws rds describe-db-instances --query 'DBInstances[0].Endpoint.Address' --output text)
if [ -z "$DB_ENDPOINT" ]; then
  echo "Error: Database endpoint not found!"
  exit 1
fi

# Install API chart
echo "Installing API chart..."
helm upgrade --install develop-api ./helm/charts/api \
  --namespace develop \
  --values ./helm/environments/develop/values.yaml \
  --set database.host=$DB_ENDPOINT

echo "Waiting for API deployment..."
kubectl -n develop rollout status deployment/develop-api-api --timeout=300s

# Install Web chart
echo "Installing Web chart..."
helm upgrade --install develop-web ./helm/charts/web \
  --namespace develop \
  --values ./helm/environments/develop/values.yaml \
  --set api.host="http://develop-api-svc"

echo "Waiting for Web deployment..."
kubectl -n develop rollout status deployment/develop-web-web --timeout=300s

echo "Post-installation completed successfully!"
