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

# Run - INFRA - Namespaces
kubectl apply -f k8s/infra/namespaces.yaml

# Find DB Name & Patch 
DB_ENDPOINT=$(aws rds describe-db-instances --query 'DBInstances[0].Endpoint.Address' --output text)
kubectl patch configmap db-cm -p "{\"data\":{\"DB_HOST\":\"$DB_ENDPOINT\"}}"

```

## HELM

```shell
# Скачиваем скрипт установки
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

# Делаем скрипт исполняемым
chmod 700 get_helm.sh

# Запускаем установку
./get_helm.sh

# Добавляем репозиторий prometheus-community
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Обновляем списки репозиториев
helm repo update


cd helm/charts/monitoring

# Соберите зависимости
helm dependency build

```

## ALIASES.SH

Для быстрой настройки рабочего окружения (алиасы kubectl, AWS, Terraform, Git):

```bash
./scripts/aliases.sh
```

k delete -f k8s/infra/monitoring-ingress.yaml
helm uninstall monitoring -n monitoring || true
k delete namespace monitoring || true

k apply -f k8s/infra/monitoring-ingress.yaml

cd helm/charts/monitoring && helm dependency build && cd ../../..
helm install monitoring ./helm/charts/monitoring \
  --namespace monitoring \
  --create-namespace \
  --values ./helm/charts/monitoring/values.yaml \
  --timeout 10m

k get all -n monitoring-ingress

k get pods,svc -n monitoring && k get ing -A



## Grafana & Prometheus (Простой и рабочий)

```shell
# Добавляем репы
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Ставим заново Prometheus с отключенным хранилищем и меньшими ресурсами
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
  
# Ставим Grafana полегче
helm install grafana grafana/grafana \
  --namespace monitoring \
  --set persistence.enabled=false \
  --set service.type=LoadBalancer \
  --set resources.requests.cpu=100m \
  --set resources.requests.memory=128Mi \
  --set resources.limits.cpu=200m \
  --set resources.limits.memory=256Mi
  
# Получаем URL Grafana
kubectl get svc -n monitoring grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'  

# Пароль от Grafana (логин: admin)
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# Внутренний эндпоинт будет такой:
http://prometheus-server.monitoring.svc.cluster.local
```

## Grafana & Prometheus (Сложный и не рабочий)

```
k delete -f k8s/infra/monitoring-ingress.yaml
helm uninstall monitoring -n monitoring || true
k delete namespace monitoring || true

k apply -f k8s/infra/monitoring-ingress.yaml

cd helm/charts/monitoring && helm dependency build && cd ../../..
helm install monitoring ./helm/charts/monitoring \
  --namespace monitoring \
  --create-namespace \
  --values ./helm/charts/monitoring/values.yaml

k get all -n monitoring-ingress

k get pods,svc -n monitoring && k get ing -A
```
