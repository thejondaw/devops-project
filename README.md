# DevOps Project. CI/CD/CD Pipeline

> 1. CI via GitHub Actions with linter, scanners and containerization
>    - ESLint
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

## Stadia I - Local tests

Developers gave me the code of applications without documentation:

Applications require PostgreSQL database to function correctly
- Setting up a Linux environment through Docker/VirtualBox
- Installing PostgreSQL and successfully running applications within this setup

## Stadia II - CI (Continuous Integration)

Workflows for **API** & **WEB** applications:

- Added **ESLint** linter
- _Node.js_ **dependencies** 
- Run **tests**
- Build via **Docker**
- **Trivy** vulnerability scann
- **SonarQube** code scan

## Stadia III - CD (Continuous Delivery)

1. Workflows for _creating/updating_ and _deleting_ of **VPC** module with Terraform
2. Workflows for _creating/updating_ and _deleting_ of **EKS** module with Terraform
3. Workflows for _creating/updating_ and _deleting_ of **RDS** module with Terraform

### Map of Project

```markdown
devops-project/
│
├── apps/                   # Web Application
│   ├── api/                # API Application
│   │    ├── src/           # Source code of API
│   │    ├── tests/         # Tests for API
│   │    └── Dockerfile     # Dockerfile for API
│   │
│   └── web/
│       ├── src/            # Source code of Web
│       ├── tests/          # Tests for Web
│       └── Dockerfile      # Dockerfile for Web
│
├── k8s/                    # Kubernetes manifests
│   ├── api/                # Manifests для API
│   ├── web/                # Manifests для Web
│   └── infra/              # Manifests for infrastructure components
│
├── terraform/              # Terraform configuration
│   ├── modules/            # Terraform modules
│   └── environments/       # Configuration for other envs
│
├── .github/workflows/      # GitHub Actions Workflow files
│
│
├── docs/                   # Documentation of Project
│
├── .gitignore
├── README.md
└── docker-compose.yml      # For Local development
```

### Diagram

```markdown
                +----------------------------------------------------+
                |                         VPC                        |
                | +------------------------------------------------+ |
                | |               (3 Private Subnets)              | |
                | |   +----------------------------------------+   | |
                | |   |             Tier 1: DATABASE           |   | |
                | |   +---+----------+----------+----------+---+   | |
                | |       |          |          |          |       | |
                | |       |          |          |          |       | |
                | |    DB_NAME    DB_PORT    DB_USER    DB_PASS    | |
                | |       |          |          |          |       | |
                | |       v          v          v          v       | |
                | |   +---+----------+----------+----------+---+   | |
                | |   |              Tier 2: API               |   | |
                | |   +-------+-----------------------+--------+   | |
                | |           ^                       ^            | |
                | |           |                       |            | |
                | +-----------|-----------------------|------------+ |
                |             |                       |              |
                |         API_HOST                API_PORT           |
                |             |                       |              |
                | +-----------|-----------------------|------------+ |
                | |           |  (3 Public Subnets)   |            | |
                | |   +-------+-----------------------+--------+   | |
                | |   |              Tier 3: WEB               |   | |
                | |   +-------------------+--------------------+   | |
                | |                       |                        | |
                | +---------------------+ | +----------------------+ |
                |                       | | |                        |
                +-----------------------+ | +------------------------+
                                          v
                                        CLIENT
```

### Variables for .TFVars

``` Shell
# Set "AWS Region"
region = "us-east-2" # Ohio

# Set "IP Range" of "VPC"
vpc_cidr = "10.0.0.0/16"

# Set "CIDR Blocks" for "Public Subnets"
subnet_web_1_cidr = "10.0.1.0/24"
subnet_web_2_cidr = "10.0.2.0/24"
subnet_web_3_cidr = "10.0.3.0/24"

# Set "CIDR Blocks" for "Private Subnets"
subnet_db_1_cidr = "10.0.11.0/24"
subnet_db_2_cidr = "10.0.12.0/24"
subnet_db_3_cidr = "10.0.13.0/24"

# Set details of "Database"
db_name            = "DB_NAME"
db_username        = "DB_USER"
db_password        = "DB_PASSWORD"
aurora_secret_name = "SECRET_NAME"
```

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=thejondaw_devops-project&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=thejondaw_devops-project)