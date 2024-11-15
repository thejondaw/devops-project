# Пост-скрипт для DEVELOP

```shell

# Ебашим алаясы в кубернетис
echo 'alias k="kubectl" && alias kc="kubectl config" && alias kcc="kubectl config current-context" && alias kcg="kubectl config get-contexts" && alias kcs="kubectl config set-context" && alias kcu="kubectl config use-context" && alias ka="kubectl apply -f" && alias kd="kubectl delete" && alias kdf="kubectl delete -f" && alias kdp="kubectl delete pod" && alias kg="kubectl get" && alias kga="kubectl get all" && alias kgaa="kubectl get all --all-namespaces" && alias kgn="kubectl get nodes" && alias kgno="kubectl get nodes -o wide" && alias kgp="kubectl get pods" && alias kgpa="kubectl get pods --all-namespaces" && alias kgpo="kubectl get pods -o wide" && alias kgs="kubectl get services" && alias kgsa="kubectl get services --all-namespaces" && alias kl="kubectl logs" && alias klf="kubectl logs -f" && alias kpf="kubectl port-forward" && alias kex="kubectl exec -it" && alias kdesc="kubectl describe" && alias ktp="kubectl top pod" && alias ktn="kubectl top node"' >> ~/.bashrc && source ~/.bashrc


# Выясняем название кластера
CLUSTER_NAME=$(aws eks list-clusters --region us-east-2 --query "clusters[?contains(@, 'develop')]|[0]" --output text)

# Подключаемся к кластеру
aws eks update-kubeconfig --name $CLUSTER_NAME --region us-east-2

# Устанавливаем NGINX-CONTROLLER, типа круто
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/cloud/deploy.yaml

# Ждём пока предыдущая хуета установится
kubectl -n ingress-nginx wait --for=condition=Ready pod -l app.kubernetes.io/component=controller --timeout=300s

# Проверяем готовность подов
kubectl -n argocd wait --for=condition=Ready pods --all --timeout=300s

# Получаем пароль
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Получаем URL аргосиди, и не выёбывайся
kubectl -n argocd get svc argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Заебуриваем манифесты инфры
kubectl apply -f k8s/infra/namespaces.yaml

# Узнаем название датабазы - наверно нахуй не нужно
aws rds describe-db-instances --query 'DBInstances[*].[Endpoint.Address,Endpoint.Port,DBInstanceIdentifier]' --output table

# Заебуриваем манифесты апи
kubectl apply -f k8s/api/db-secret.yaml
kubectl apply -f k8s/api/db-cm.yaml

# Целая хуйня для патча конфигмапа с нужным хостом и портом по приколу
DB_ENDPOINT=$(aws rds describe-db-instances --query 'DBInstances[0].Endpoint.Address' --output text)
DB_PORT=$(aws rds describe-db-instances --query 'DBInstances[0].Endpoint.Port' --output text)

kubectl patch configmap db-cm -p "{\"data\":{\"DB_HOST\":\"$DB_ENDPOINT\",\"DB_PORT\":\"$DB_PORT\"}}"

kubectl apply -f k8s/api/api-svc.yaml
kubectl apply -f k8s/api/api-deploy.yaml





# Заебуриваем манифесты веба
kubectl apply -f k8s/web/web-cm.yaml
kubectl apply -f k8s/web/web-svc.yaml
kubectl apply -f k8s/web/web-ingress.yaml
kubectl apply -f k8s/web/web-deploy.yaml














```