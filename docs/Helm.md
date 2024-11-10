# ==================================================== #

# Installing Helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Checking the installation
helm version

# Checking the current context
kubectl config current-context

# ==================================================== #

# Adding the ingress-nginx repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Installing ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer

# Verifying the installation
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx

# ==================================================== #

# Adding the cert-manager repository
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Installing cert-manager with CRDs
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \a
  --create-namespace \
  --version v1.13.0 \
  --set installCRDs=true

# Verifying the installation
kubectl get pods -n cert-manager

# ==================================================== #

# Adding the metrics-server repository
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update

# Installing with TLS verification disabled (for dev/test)
helm install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --set args={--kubelet-insecure-tls}

# Verifying the installation
kubectl get deployment metrics-server -n kube-system
```

# ==================================================== #