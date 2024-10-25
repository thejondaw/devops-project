# DevOps Project

> Full DevOps Pipeline
> 
> CI/CD + Terraform architecture on AWS

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

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=thejondaw_devops-project&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=thejondaw_devops-project)