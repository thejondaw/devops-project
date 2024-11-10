# DevOps Project. CI/CD/CD Pipeline

## TODO List

```markdown
### 1. Security (CRITICAL)
- [ ] Vault (бесплатная версия)
  - [ ] Перенести все креды из RDS
  - [ ] Настроить rotation secrets
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
  - [ ] Добавить теги для всех ресурсов
  - [ ] Автоматизация имен (кластера, ресурсов)
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
|
├── .github/workflows/        # GitHub Actions Workflow files
│
├── ansible/                  # Ansible configurations
│   ├── inventory/            # Inventory files
│   ├── playbooks/            # Playbook files
│   │
│   ├── roles/                # Ansible roles
│   │   ├── common/           # Common settings for all
│   │   ├── monitoring/       # Prometheus/Node Exporter
│   │   └── security/         # AppArmor, IPtables etc
│   │
│   └── ansible.cfg           # Ansible config
│
├── apps/
│   ├── api/                  # API Application
│   │   ├── src/              # Source code of API
│   │   ├── tests/            # Tests for API
│   │   └── Dockerfile        # Dockerfile for API
│   │
│   └── web/                  # WEB Application
│       ├── src/              # Source code of WEB
│       ├── tests/            # Tests for WEB
│       └── Dockerfile        # Dockerfile for WEB
│
├── terraform/                # Terraform configuration
│   ├── modules/              # Terraform modules
│   └── environments/         # Configuration for other envs
│
├── k8s/                      # Kubernetes manifests
│   ├── api/                  # Manifests для API
│   ├── infra/                # Manifests for infrastructure components
│   └── web/                  # Manifests для WEB
│
├── docs/                     # Documentation of Project
│
├── .gitignore
├── Makefile
├── README.md
└── sonar-project.properties  # Config file for SonarQube
```

### Diagram

```markdown
                +----------------------------------------------------------+
                |                           "VPC"                          |
                | +------------------------------------------------------+ |
                | |                  (2 Private Subnets)                 | |
                | |   +----------------------------------------------+   | |
                | |   |               "Tier 1: DATABASE"             |   | |
                | |   +----+-----------+------------+----------+----+    | |
                | |        |           |            |          |         | |
                | |        |           |            |          |         | |
                | |     DB_NAME     DB_PORT      DB_USER    DB_PASS      | |
                | |        |           |            |          |         | |
                | |        v           v            v          v         | |
                | | +══════════════════════════════════════════════════+ | |
                | | ║  +---+-----------+------------+-----------+---+  ║ | |
                | | ║  |               "Tier 2: API"                |  ║ | |
                | | ║  +----------+----------------------+----------+  ║ | |
                | | ║             ^                      ^             ║ | |
                | | ║             | (KUBERNETES CLUSTER) |             ║ | |
                | +-║-------------|----------------------|-------------║-+ |
                |   ║             |                      |             ║   |
                |   ║          API_HOST               API_PORT         ║   |
                |   ║             |                      |             ║   |
                | +-║-------------|----------------------|-------------║-+ |
                | | ║             |  (2 Public Subnets)  |             ║ | |
                | | ║  +----------+----------------------+----------+  ║ | |
                | | ║  |                "Tier 3: WEB"               |  ║ | |
                | | ║  +----------------------+---------------------+  ║ | |
                | | ║                                                  ║ | |
                | | +═══════════════════════\   /══════════════════════+ | |
                | +------------------------+ \ / +-----------------------+ |
                |                          |  |  |                         |
                +--------------------------+  |  +-------------------------+
                                              V
                                            CLIENT
```

### Variables for .TFVars

```shell
# Set "AWS Region"
region_rv         = "your-region-number"

# Set "S3 Bucket" name:
backend_bucket_rv = "your-bucket-name"

# Set "Environment" name:
environment_rv    = "develop"

# Set your "IP Range" for "VPC" and "Subnets":
vpc_cidr_rv        = "10.0.0.0/16"
subnet_web_cidr_rv = "10.0.1.0/24"
subnet_alb_cidr_rv = "10.0.2.0/24"
subnet_api_cidr_rv = "10.0.3.0/24"
subnet_db_cidr_rv  = "10.0.4.0/24"
```

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project═thejondaw_devops-project&metric═alert_status)](https://sonarcloud.io/summary/new_code?id═thejondaw_devops-project)