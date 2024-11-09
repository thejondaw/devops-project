```shell
# Alias for Kubernetes:

echo 'alias k="kubectl" && alias kc="kubectl config" && alias kcc="kubectl config current-context" && alias kcg="kubectl config get-contexts" && alias kcs="kubectl config set-context" && alias kcu="kubectl config use-context" && alias ka="kubectl apply -f" && alias kd="kubectl delete" && alias kdf="kubectl delete -f" && alias kdp="kubectl delete pod" && alias kg="kubectl get" && alias kga="kubectl get all" && alias kgaa="kubectl get all --all-namespaces" && alias kgn="kubectl get nodes" && alias kgno="kubectl get nodes -o wide" && alias kgp="kubectl get pods" && alias kgpa="kubectl get pods --all-namespaces" && alias kgpo="kubectl get pods -o wide" && alias kgs="kubectl get services" && alias kgsa="kubectl get services --all-namespaces" && alias kl="kubectl logs" && alias klf="kubectl logs -f" && alias kpf="kubectl port-forward" && alias kex="kubectl exec -it" && alias kdesc="kubectl describe" && alias ktp="kubectl top pod" && alias ktn="kubectl top node"' >> ~/.zshrc && source ~/.zshrc
```

```shell
# AWS Authorization:

aws configure
- AWS Access Key ID:
- AWS Secret Access Key:
- Default region name: us-east-2
- Default output format: json
```

```shell
# Configure k for work with Cluster:

aws eks update-kubeconfig --name study-cluster --region us-east-2
```

```shell
# Show HOST of Databases:

aws rds describe-db-instances --query 'DBInstances[*].[Endpoint.Address,Endpoint.Port,DBInstanceIdentifier]' --output table
```

```shell
# Install Ingress

k apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/cloud/deploy.yaml
```

```shell
# Change HOST of Databese in api/db-config.yaml

# Run manifests:

# API
k apply -f db-secret.yaml && k apply -f db-config.yaml
k apply -f api-service.yaml && k apply -f api-deployment.yaml

# WEB
k apply -f web-config.yaml && k apply -f web-service.yaml
k apply -f web-ingress.yaml && k apply -f web-deployment.yaml

# To show ADDRESS of website:
k get ingress
```

```shell
# Delete all:
k delete deployment api-deployment web-deployment
k delete service api-service web-service
k delete configmap db-config web-config
k delete secret db-credentials
k delete ingress web-ingress
```