# Notes of Post-Install process

```shell
# Alias of Kubernetes for Bash
echo 'alias k="kubectl" && alias kc="kubectl config" && alias kcc="kubectl config current-context" && alias kcg="kubectl config get-contexts" && alias kcs="kubectl config set-context" && alias kcu="kubectl config use-context" && alias ka="kubectl apply -f" && alias kd="kubectl delete" && alias kdf="kubectl delete -f" && alias kdp="kubectl delete pod" && alias kg="kubectl get" && alias kga="kubectl get all" && alias kgaa="kubectl get all --all-namespaces" && alias kgn="kubectl get nodes" && alias kgno="kubectl get nodes -o wide" && alias kgp="kubectl get pods" && alias kgpa="kubectl get pods --all-namespaces" && alias kgpo="kubectl get pods -o wide" && alias kgs="kubectl get services" && alias kgsa="kubectl get services --all-namespaces" && alias kl="kubectl logs" && alias klf="kubectl logs -f" && alias kpf="kubectl port-forward" && alias kex="kubectl exec -it" && alias kdesc="kubectl describe" && alias ktp="kubectl top pod" && alias ktn="kubectl top node"' >> ~/.bashrc && source ~/.bashrc

# Aliases.sh
./scripts/aliases.sh

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== #

# Show Name of Cluster and Login
CLUSTER_NAME=$(aws eks list-clusters --region us-east-2 --query "clusters[?contains(@, 'develop')]|[0]" --output text)
aws eks update-kubeconfig --name $CLUSTER_NAME --region us-east-2

# Find DB Name & Patch 
DB_ENDPOINT=$(aws rds describe-db-instances --query 'DBInstances[0].Endpoint.Address' --output text)
kubectl patch configmap api-cm -n develop -p "{\"data\":{\"DB_HOST\":\"$DB_ENDPOINT\"}}"

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== #

# Show - ArgoCD - URL
kubectl -n argocd get svc argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Show - ArgoCD - PASSWORD
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== #

# If needs to delete
kubectl delete all --all -n develop
kubectl delete all --all -n monitoring
kubectl delete -f k8s/argocd/applications/develop/api.yaml
kubectl delete -f k8s/argocd/applications/develop/web.yaml
kubectl delete -f k8s/argocd/applications/develop/monitoring.yaml
kubectl delete -f k8s/argocd/applications/develop/logging.yaml
kubectl delete -f k8s/argocd/applications/develop/apparmor.yaml


# ПЕРЕД РЕАПЛАЕМ
# УДАЛИТЬ IAM ROLE ВОЛТА

helm uninstall argocd -n argocd
kubectl delete namespace argocd


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

## Grafana & Prometheus (Helm Chart)

```shell
k get all -n monitoring

# URL
k get svc -n monitoring grafana-prometheus -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Password
k get secret -n monitoring grafana-prometheus -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

╔================================================╗
║Connection to Prometheus:                       ║
║URL: http://grafana-prometheus-server           ║
║Skip TLS Verify: ON                             ║
║                                                ║
║Dashboards -> Import                            ║
║ID: 1860 (Node Exporter Full)                   ║
║Datasource: Prometheus                          ║
║Import                                          ║
╚================================================╝

# URL - Prometheus (Optional)
k patch svc grafana-prometheus-server -n monitoring -p '{"spec": {"type": "LoadBalancer"}}'

k get svc -n monitoring grafana-prometheus-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```
