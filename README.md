# DevOps Project. CI/CD/CD Pipeline

> 1. CI via GitHub Actions with linter, scanners and containerization
>    ─ ESLint
>    ─ Prettier
>    ─ Docker
>    ─ Trivy
>    ─ SonarQube
> 2. Applications based on Node.js
>    ─ API
>    ─ WEB
> 3. CD/CD with Three─Tier Architecture on AWS, using Terraform
>    ─ VPC
>    ─ EKS
>      ─ ArgoCD
>      ─ Helm Charts
>      ─ Prometheus + Grafana
>    ─ RDS: Aurora PostgreSQL 15.3 (Serverless v2)
───

## Step I ─ Local testst

Developers gave me the code of applications without documentation:

─ Applications require **PostgreSQL** database to function correctly
─ Setting up a _Linux_ environment through **Docker**/**VirtualBox**
─ Installing **PostgreSQL** and successfully running applications within this setup **LOCALLY**


## Step II ─ CI (Continuous Integration)

Workflows for **API** & **WEB** applications:

─ Run **ESLint** linter
─ Run **Prettier**
─ _Node.js_ **dependencies**
─ Run **tests**
─ Build via **Docker**
─ **Trivy** vulnerability scann
─ **SonarQube** code scan

## Step III ─ CD (Continuous Delivery)

1. Workflows for _creating/updating_ and _deleting_ of **VPC** module with Terraform
2. Workflows for _creating/updating_ and _deleting_ of **EKS** module with Terraform
3. Workflows for _creating/updating_ and _deleting_ of **RDS** module with Terraform

### Map of Project

```markdown
devops─project/
├── .github/workflows/                # GitHub Actions Workflow files
│   ├── ci─api.yaml                   # CI for API
│   ├── ci─web.yaml                   # CI for WEB
│   ├── post─install.yaml             # CD sh─script
│   ├── cd─infrastructure.yaml        # CD for infrastructure
│   └── cd─applications.yaml          # CD for tools (Helm/ArgoCD)
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
│   ├── charts/
│   │   ├── api/                      # API Chart
│   │   │   ├── Chart.yaml
│   │   │   ├── values.yaml
│   │   │   ├── templates/configmap.yaml
│   │   │   ├── templates/deployment.yaml
│   │   │   ├── templates/secret.yaml
│   │   │   └── templates/service.yaml
│   │   │
│   │   ├── web/                      # WEB Chart
│   │   │   ├── Chart.yaml
│   │   │   ├── values.yaml
│   │   │   ├── templates/configmap.yaml
│   │   │   ├── templates/deployment.yaml
│   │   │   ├── templates/ingress.yaml
│   │   │   └── templates/service.yaml
│   │   │
│   │   └── monitoring/               # Grafana & Prometheus Chart
│   │       ├── Chart.yaml
│   │       └── values.yaml
│   │
│   │
│   └── environments/                # Configs Environments
│       ├── develop/
│       │   └── values.yaml
│       ├── stage/
│       │   └── values.yaml
│       └── prod/
│           └── values.yaml
│
│
├── terraform/                       # Terraform configs
│   ├── modules/
│   │   ├── backend/                 # Module S3 Backend
│   │   ├── vpc/                     # Module VPC
│   │   ├── eks/                     # Module EKS
│   │   ├── rds/                     # Module RDS
│   │   └── tools/                   # Module TOOLS
│   │
│   └── environments/                # Configurations of Environments
│       ├── develop/
│       │   ├── main.tf
│       │   └── terraform.tfvars
│       ├── stage/
│       └── prod/
│
├── k8s
│   ├── infra/
│   │   ├── namespaces.yaml          # Namespaces manifest
│   │   └── monitoring─ingress.yaml  # Grafana & Prometheus manifest
│   │
│   └── argocd/applications          # # Apps manifests for ArgoCD dashboard
│              └── develop/
│                  ├── api.yaml
│                  ├── web.yaml
│                  └── monitoring.yaml
│
├── ansible/                         # Ansible configurations
│   ├── inventory/                   # Inventory files
│   ├── playbooks/                   # Playbook files
│   └── roles/                       # Ansible roles
│
├── scripts/                         # Automatization Scripts
│   └── post─install.sh              # Post install of Tools
│
├── docs/                            # Documentation of Project
│
├── .gitignore
├── Makefile
├── README.md
└── sonar─project.properties         # Configuration of SonarQube
```

### Diagram

```
                ┌──────────────────────────────────────────────────────────┐
                │                            VPC                           │
                │ ┌──────────────────────────────────────────────────────┐ │
                │ │                 (2x PRIVATE SUBNETS)                 │ │
                │ │   ┌──────────────────────────────────────────────┐   │ │
                │ │   │               TIER I ─ DATABASE              │   │ │
                │ │   └───┐ ┌─────────┐ ┌──────────┐ ┌─────────┐ ┌───┘   │ │
                │ │        │           │            │           │        │ │
                │ │     DB_NAME     DB_PORT      DB_USER     DB_PASS     │ │
                │ │        │           │            │           │        │ │
                │ │        ▼           ▼            ▼           ▼        │ │
                │ │ ╔=====╣ ╠=========╣ ╠==========╣ ╠=========╣ ╠=====╗ │ │
                │ │ ║                                                  ║ │ │
                │ │ ║               (KUBERNETES CLUSTER)               ║ │ │
                │ │ ║                                                  ║ │ │
                │ │ ║  ┌──┘ └─────────┘ └──────────┘ └─────────┘ └──┐  ║ │ │
                │ │ ║  │               TIER II ─ API                │  ║ │ │
                │ │ ║  └─────────┐ ┌────────────────────┐ ┌─────────┘  ║ │ │
                │ │ ║             ▲                      ▲             ║ │ │
                │ │ ║             │                      │             ║ │ │
                │ └─║───────────┤ │ ├──────────────────┤ │ ├───────────║─┘ │
                │   ║             │                      │             ║   │
                │   ║          API_HOST               API_PORT         ║   │
                │   ║             │                      │             ║   │
                │ ┌─║───────────┤ │ ├──────────────────┤ │ ├───────────║─┐ │
                │ │ ║             │ (2x PUBLIC  SUBNETS) │             ║ │ │
                │ │ ║  ┌─────────┘ └────────────────────┘ └─────────┐  ║ │ │
                │ │ ║  │                TIER III ─ WEB              │  ║ │ │
                │ │ ║  └─────────────────────┐ ┌────────────────────┘  ║ │ │
                │ │ ║                         │                        ║ │ │
                │ │ ╚======================╣  │  ╠=====================╝ │ │
                │ └────────────────────────┐  │  ┌───────────────────────┘ │
                │                          │  │  │                         │
                └──────────────────────────┘  │  └─────────────────────────┘
                                              ▼
                                            CLIENT
```

### Variables for .TFVars

```
# Set ─ AWS Region
region         = "your─region─number"

# Set ─ S3 Bucket Name
backend_bucket = "your─bucket─name"

# Set ─ Environment ─ Name
environment    = "develop"

# Set ─ IP Range of VPC & Subnets
vpc_configuration = {
  cidr = "10.0.0.0/16"
  subnets = {
    web = {
      cidr_block = "10.0.1.0/24"
      az         = "us─east─2a"
    }
    alb = {
      cidr_block = "10.0.2.0/24"
      az         = "us─east─2b"
    }
    api = {
      cidr_block = "10.0.3.0/24"
      az         = "us─east─2a"
    }
    db = {
      cidr_block = "10.0.4.0/24"
      az         = "us─east─2c"
    }
  }
}

# Set ─ Database ─ Configuration
db_configuration = {
  name     = "name─of─db"
  username = "username"
  password = "password"
  port     = 5432
}
```

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project═thejondaw_devops─project&metric═alert_status)](https://sonarcloud.io/summary/new_code?id═thejondaw_devops─project)