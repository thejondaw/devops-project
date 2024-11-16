# DevOps Project. CI/CD/CD Pipeline

## TODO List

```markdown
### 1. Security (CRITICAL)
- [ ] Vault (бесплатная версия)
  - [ ] Перенести все креды из RDS
  - [ ] Интеграция с K8s через ServiceAccount
- [ ] Security Hardening
  - [ ] AppArmor базовые профили для подов
  - [ ] Network Policies в K8s
  - [ ] Базовые iptables правила
  - [ ] Pod Security Context

### 2. Monitoring (HIGH)
- [ ] Prometheus Stack
  - [ ] Prometheus Operator через helm
  - [ ] Node Exporter для метрик нод
  - [ ] kube-state-metrics для K8s метрик
- [ ] Grafana
  - [ ] Дашборд для Node metrics
  - [ ] Дашборд для K8s metrics
  - [ ] Дашборд для RDS metrics
  - [ ] Алерты на критические метрики

### 3. Helm (HIGH)
- [ ] Базовые чарты для:
  - [ ] API app
  - [ ] Web app
  - [ ] Prometheus stack
  - [ ] Vault

### 4. Security Scanning (MEDIUM)
- [ ] Trivy в CI/CD для:
  - [v] Сканирования контейнеров
  - [v] Сканирования кода
  - [ ] Сканирования IaC

### 5. Automation & IaC
- [ ] Рефакторинг Terraform
  - [ ] Вынести все переменные в tfvars
  - [v] Добавить теги для всех ресурсов
  - [v] Автоматизация имен (кластера, ресурсов)
```

> 1. CI via GitHub Actions with linter, scanners and containerization
>    - ESLint
>    - Prettier
>    - Docker
>    - Trivy
>    - SonarQube
> 2. Applications based on Node.js
>    - API
>    - WEB
> 3. CD/CD with Three-Tier Architecture on AWS, using Terraform
>    - VPC: 3 Public, 3 Private subnets
>    - EKS (Kubernetes)
>      - Helm Charts
>      - Prometheus + Grafana
>      - ArgoCD
>      - AWS Secret Manager
>    - RDS: Aurora PostgreSQL 15.3 (Serverless v2)
---

## Step I - Local testst

Developers gave me the code of applications without documentation:

- Applications require **PostgreSQL** database to function correctly
- Setting up a _Linux_ environment through **Docker**/**VirtualBox**
- Installing **PostgreSQL** and successfully running applications within this setup **LOCALLY**


## Step II - CI (Continuous Integration)

Workflows for **API** & **WEB** applications:

```shell
# For Linters. Locally:
cd apps/api

# Creating and configuring files:
touch .eslintignore .eslintrc.json .gitignore

# Installation of Linter:
npm install -D eslint eslint-config-airbnb-base eslint-plugin-import

# Installation of Prettier:
npm install -D prettier eslint-config-prettier eslint-plugin-prettier
```

- Run **ESLint** linter
- Run **Prettier**
- _Node.js_ **dependencies**
- Run **tests**
- Build via **Docker**
- **Trivy** vulnerability scann
- **SonarQube** code scan

## Step III - CD (Continuous Delivery)

1. Workflows for _creating/updating_ and _deleting_ of **VPC** module with Terraform
2. Workflows for _creating/updating_ and _deleting_ of **EKS** module with Terraform
3. Workflows for _creating/updating_ and _deleting_ of **RDS** module with Terraform

### Map of Project

```markdown
devops-project/
├── .github/workflows/                # GitHub Actions Workflow files
│   ├── ci-api.yaml                   # CI for API
│   ├── ci-web.yaml                   # CI for WEB
│   ├── cd-infrastructure.yaml        # CD for infrastructure
│   └── cd-applications.yaml          # CD for tools (Helm/ArgoCD)
│
├── apps/
│   ├── api/                          # API Application
│   │   ├── src/                      # Source code of API
│   │   ├── tests/                    # Tests for API
│   │   └── Dockerfile                # Dockerfile for API
│   │
│   └── web/                          # WEB Application
│       ├── src/                      # Source code of WEB
│       ├── tests/                    # Tests for WEB
│       └── Dockerfile                # Dockerfile for WEB
│
├── helm/                             # Helm
│   ├── charts/                       # Helm Charts
│   │   ├── api/                      # API Chart
│   │   │   ├── Chart.yaml
│   │   │   ├── values.yaml
│   │   │   ├── values-develop.yaml
│   │   │   ├── values-stage.yaml
│   │   │   ├── values-prod.yaml
│   │   │   └── templates/            # Templates K8s manifests
│   │   │
│   │   └── web/                      # WEB Chart
│   │       ├── Chart.yaml
│   │       ├── values.yaml
│   │       ├── values-develop.yaml
│   │       ├── values-stage.yaml
│   │       ├── values-prod.yaml
│   │       └── templates/
│   │
│   └── environments/                # Configs Environments
│       ├── develop/
│       │   └── values.yaml
│       ├── stage/
│       │   └── values.yaml
│       └── prod/
│           └── values.yaml
│
├── k8s/                             # Kubernetes manifests
│   ├── argocd/                      # ArgoCD configurations
│   │   ├── install.yaml             # Installation ArgoCD
│   │   └── applications/
│   │       ├── develop/
│   │       │   ├── api.yaml
│   │       │   └── web.yaml
│   │       ├── stage/
│   │       │   ├── api.yaml
│   │       │   └── web.yaml
│   │       └── prod/
│   │           ├── api.yaml
│   │           └── web.yaml
│   │
│   └── infrastructure/              # General K8s resources
│       ├── namespaces.yaml
│       └── network-policies.yaml
│
├── terraform/                       # Terraform configs
│   ├── modules/
│   │   ├── backend/                 # Module S3 Backend
│   │   ├── vpc/                     # Module VPC
│   │   ├── eks/                     # Module EKS
│   │   ├── rds/                     # Module RDS
│   │   └── tools/                   # Module for Tools installation
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       └── values/              # Values for Helm Charts
│   │
│   └── environments/                # Configurations of Environments
│       ├── develop/
│       │   ├── main.tf
│       │   └── terraform.tfvars
│       ├── stage/
│       └── prod/
│
├── ansible/                         # Ansible configurations
│   ├── inventory/                   # Inventory files
│   ├── playbooks/                   # Playbook files
│   └── roles/                       # Ansible roles
│
├── scripts/                         # Automatization Scripts
│   └── post-install.sh              # Post install of Tools
│
├── docs/                            # Documentation of Project
│
├── .gitignore
├── Makefile
├── README.md
└── sonar-project.properties         # Configuration of SonarQube
```

### Diagram

```markdown
                +----------------------------------------------------------+
                |                           "VPC"                          |
                | +------------------------------------------------------+ |
                | |                  (2 Private Subnets)                 | |
                | |   +----------------------------------------------+   | |
                | |   |               "Tier 1: DATABASE"             |   | |
                | |   +----+-----------+------------+-----------+----+   | |
                | |        |           |            |           |        | |
                | |        |           |            |           |        | |
                | |     DB_NAME     DB_PORT      DB_USER     DB_PASS     | |
                | |        |           |            |           |        | |
                | |        v           v            v           v        | |
                | | +====== =========== ============ =========== ======+ | |
                | | ║                                                  ║ | |
                | | ║               (KUBERNETES CLUSTER)               ║ | |
                | | ║                                                  ║ | |
                | | ║  +---+-----------+------------+-----------+---+  ║ | |
                | | ║  |               "Tier 2: API"                |  ║ | |
                | | ║  +----------+----------------------+----------+  ║ | |
                | | ║             ^                      ^             ║ | |
                | | ║             |                      |             ║ | |
                | +-║-------------|----------------------|-------------║-+ |
                |   ║             |                      |             ║   |
                |   ║          API_HOST               API_PORT         ║   |
                |   ║             |                      |             ║   |
                | +-║-------------|----------------------|-------------║-+ |
                | | ║             |  (2 Public Subnets)  |             ║ | |
                | | ║  +----------+----------------------+----------+  ║ | |
                | | ║  |                "Tier 3: WEB"               |  ║ | |
                | | ║  +----------------------+---------------------+  ║ | |
                | | ║                         |                        ║ | |
                | | +=======================  |  ======================+ | |
                | +------------------------+  |  +-----------------------+ |
                |                          |  |  |                         |
                +--------------------------+  |  +-------------------------+
                                              V
                                            CLIENT
```

### Variables for .TFVars

```shell
# Set - AWS Region
region         = "your-region-number"

# Set - S3 Bucket Name
backend_bucket = "your-bucket-name"

# Set - Environment - Name
environment    = "develop"

# Set - IP Range of VPC & Subnets
vpc_configuration = {
  cidr = "10.0.0.0/16"
  subnets = {
    web = {
      cidr_block = "10.0.1.0/24"
      az         = "us-east-2a"
    }
    alb = {
      cidr_block = "10.0.2.0/24"
      az         = "us-east-2b"
    }
    api = {
      cidr_block = "10.0.3.0/24"
      az         = "us-east-2a"
    }
    db = {
      cidr_block = "10.0.4.0/24"
      az         = "us-east-2c"
    }
  }
}

# Set - Database - Configuration
db_configuration = {
  name     = "name-of-db"
  username = "username"
  password = "password"
  port     = 5432
}
```

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project═thejondaw_devops-project&metric═alert_status)](https://sonarcloud.io/summary/new_code?id═thejondaw_devops-project)