# Notes of Post-Install process

## POST-INSTALL.SH

```shell
# Alias of Kubernetes for Bash
echo 'alias k="kubectl" && alias kc="kubectl config" && alias kcc="kubectl config current-context" && alias kcg="kubectl config get-contexts" && alias kcs="kubectl config set-context" && alias kcu="kubectl config use-context" && alias ka="kubectl apply -f" && alias kd="kubectl delete" && alias kdf="kubectl delete -f" && alias kdp="kubectl delete pod" && alias kg="kubectl get" && alias kga="kubectl get all" && alias kgaa="kubectl get all --all-namespaces" && alias kgn="kubectl get nodes" && alias kgno="kubectl get nodes -o wide" && alias kgp="kubectl get pods" && alias kgpa="kubectl get pods --all-namespaces" && alias kgpo="kubectl get pods -o wide" && alias kgs="kubectl get services" && alias kgsa="kubectl get services --all-namespaces" && alias kl="kubectl logs" && alias klf="kubectl logs -f" && alias kpf="kubectl port-forward" && alias kex="kubectl exec -it" && alias kdesc="kubectl describe" && alias ktp="kubectl top pod" && alias ktn="kubectl top node"' >> ~/.bashrc && source ~/.bashrc

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== #

# Show Name of Cluster and Login
CLUSTER_NAME=$(aws eks list-clusters --region us-east-2 --query "clusters[?contains(@, 'develop')]|[0]" --output text)
aws eks update-kubeconfig --name $CLUSTER_NAME --region us-east-2

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== #

# Install NGINX-CONTROLLER
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/cloud/deploy.yaml

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== #

# Show - ArgoCD - URL
kubectl -n argocd get svc argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Show - ArgoCD - PASSWORD
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== #

# Find DB Name & Patch 
DB_ENDPOINT=$(aws rds describe-db-instances --query 'DBInstances[0].Endpoint.Address' --output text)
kubectl patch configmap db-cm -p "{\"data\":{\"DB_HOST\":\"$DB_ENDPOINT\"}}"

```

## HELM Install

```shell
# Download script of installation
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

# Access to script
chmod 700 get_helm.sh

# Run script
./get_helm.sh
```

## ALIASES.SH

Для быстрой настройки рабочего окружения (алиасы kubectl, AWS, Terraform, Git):

```bash
./scripts/aliases.sh
```

## Grafana & Prometheus (CLI)

```shell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/prometheus \
  --namespace monitoring \
  --create-namespace \
  --set server.persistentVolume.enabled=false \
  --set alertmanager.persistentVolume.enabled=false \
  --set alertmanager.enabled=false \
  --set pushgateway.enabled=false \
  --set server.resources.requests.cpu=100m \
  --set server.resources.requests.memory=256Mi \
  --set server.resources.limits.cpu=200m \
  --set server.resources.limits.memory=512Mi
  
helm install grafana grafana/grafana \
  --namespace monitoring \
  --set persistence.enabled=false \
  --set service.type=LoadBalancer \
  --set resources.requests.cpu=100m \
  --set resources.requests.memory=128Mi \
  --set resources.limits.cpu=200m \
  --set resources.limits.memory=256Mi
  
# URL - Grafana
kubectl get svc -n monitoring grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'  

# PASSWORD - Grafana (Login: admin)
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# Inside - Endpoint
http://prometheus-server.monitoring.svc.cluster.local
```

## Grafana & Prometheus (Helm Chart)

```shell
cd helm/charts/monitoring && helm dependency build && cd ../../..
k apply -f k8s/argocd/applications/develop/monitoring.yaml

k get -all -n monitoring

# URL
k get svc -n monitoring develop-monitoring-grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname

# Password
k get secret -n monitoring develop-monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

================================================
Connect to Prometheus:
URL: http://develop-monitoring-prometheus-server
Skip TLS Verify: ON

Dashboards -> Import
ID: 1860 (Node Exporter Full)
Datasource: Prometheus
Import
================================================

```shell
# URL - Prometheus (Optional)
k patch svc develop-monitoring-prometheus-server -n monitoring -p '{"spec": {"type": "LoadBalancer"}}'

k get svc -n monitoring develop-monitoring-prometheus-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# P.S. In real work environment, better not create Load Balancer for Prometheus, but for test it's ok.
```
