# ==================================================== #
# ===================== MAKEFILE ===================== #
# ==================================================== #

# Path to variables file for development:
TFVARS_PATH = terraform/environments/develop/terraform.tfvars

# Install Terraform:
terraform:
	sudo yum install -y yum-utils
	sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
	sudo yum -y install terraform

# ================== ROOT Commands =================== #

# Copy ".terraformrc" to home directory:
rc:
	cp .terraformrc ~/.terraformrc

# ================ General Commands ================== #

# Clean temporary and cached files:
cache:
	find / -type d -name ".terraform" -exec rm -rf {} \;
	[ -d "$HOME/.terraform.d/plugin-cache" ] && rm -rf $HOME/.terraform.d/plugin-cache/*

# Initialize and validate all modules:
init:
	git pull
	cd terraform/modules/backend && terraform init
	cd terraform/modules/backend && terraform validate
	cd terraform/modules/vpc && terraform init -var-file=../../environments/develop/terraform.tfvars
	cd terraform/modules/vpc && terraform validate
	cd terraform/modules/rds && terraform init -var-file=../../environments/develop/terraform.tfvars
	cd terraform/modules/rds && terraform validate
	cd terraform/modules/eks && terraform init -var-file=../../environments/develop/terraform.tfvars
	cd terraform/modules/eks && terraform validate
	cd terraform/modules/tools && terraform init -var-file=../../environments/develop/terraform.tfvars
	cd terraform/modules/tools && terraform validate

# Plan changes for all modules:
plan:
	cd terraform/modules/backend && terraform plan -var-file=$(abspath $(TFVARS_PATH))

# Apply changes for all modules:
apply:
	cd terraform/modules/backend && terraform apply --auto-approve -var-file=$(abspath $(TFVARS_PATH))

# Destroy all resources:
destroy:
	cd terraform/modules/backend && terraform destroy --auto-approve -var-file=$(abspath $(TFVARS_PATH))

# ================== Backend Module ================== #

# Clean temporary files for "Backend" module:
cache-backend:
	cd terraform/modules/backend && find / -type d -name ".terraform" -exec rm -rf {} \;

# Initialize and validate "Backend" module:
init-backend:
	git pull
	cd terraform/modules/backend && terraform init
	cd terraform/modules/backend && terraform validate

# Plan changes for "Backend" module:
plan-backend:
	cd terraform/modules/backend && terraform plan -var-file=../../environments/develop/terraform.tfvars

# Apply changes for "Backend" module:
apply-backend:
	cd terraform/modules/backend && terraform apply --auto-approve -var-file=../../environments/develop/terraform.tfvars

# Destroy resources for "Backend" module:
destroy-backend:
	cd terraform/modules/backend && terraform destroy --auto-approve -var-file=../../environments/develop/terraform.tfvars

# =================== VPC Module ==================== #

# Clean temporary files for "VPC" module:
cache-vpc:
	cd terraform/modules/vpc && find / -type d -name ".terraform" -exec rm -rf {} \;

# Initialize and validate "VPC" module:
init-vpc:
	git pull
	cd terraform/modules/vpc && terraform init -var-file=../../environments/develop/terraform.tfvars
	cd terraform/modules/vpc && terraform validate

# Plan changes for "VPC" module:
plan-vpc:
	cd terraform/modules/vpc && terraform plan -var-file=../../environments/develop/terraform.tfvars

# Apply changes for "VPC" module:
apply-vpc:
	cd terraform/modules/vpc && terraform apply --auto-approve -var-file=../../environments/develop/terraform.tfvars

# Destroy resources for "VPC" module:
destroy-vpc:
	cd terraform/modules/vpc && terraform destroy --auto-approve -var-file=../../environments/develop/terraform.tfvars

# =================== RDS Module ==================== #

# Clean temporary files for "RDS" module:
cache-rds:
	cd terraform/modules/rds && find / -type d -name ".terraform" -exec rm -rf {} \;

# Initialize and validate "RDS" module:
init-rds:
	git pull
	cd terraform/modules/rds && terraform init -var-file=../../environments/develop/terraform.tfvars
	cd terraform/modules/rds && terraform validate

# Plan changes for "RDS" module:
plan-rds:
	cd terraform/modules/rds && terraform plan -var-file=../../environments/develop/terraform.tfvars

# Apply changes for "RDS" module:
apply-rds:
	cd terraform/modules/rds && terraform apply --auto-approve -var-file=../../environments/develop/terraform.tfvars

# Destroy resources for "RDS" module:
destroy-rds:
	cd terraform/modules/rds && terraform destroy --auto-approve -var-file=../../environments/develop/terraform.tfvars

# =================== EKS Module ==================== #

# Clean temporary files for "EKS" module:
cache-eks:
	cd terraform/modules/eks && find / -type d -name ".terraform" -exec rm -rf {} \;

# Initialize and validate "EKS" module:
init-eks:
	git pull
	cd terraform/modules/eks && terraform init -var-file=../../environments/develop/terraform.tfvars
	cd terraform/modules/eks && terraform validate

# Plan changes for "EKS" module:
plan-eks:
	cd terraform/modules/eks && terraform plan -var-file=../../environments/develop/terraform.tfvars

# Apply changes for "EKS" module:
apply-eks:
	cd terraform/modules/eks && terraform apply --auto-approve -var-file=../../environments/develop/terraform.tfvars

# Destroy resources for "EKS" module:
destroy-eks:
	cd terraform/modules/eks && terraform destroy --auto-approve -var-file=../../environments/develop/terraform.tfvars

# =================== Tools Module ==================== #

# Clean temporary files for "Tools" module:
cache-tools:
	cd terraform/modules/tools && find / -type d -name ".terraform" -exec rm -rf {} \;

# Initialize and validate "Tools" module:
init-tools:
	git pull
	cd terraform/modules/tools && terraform init -var-file=../../environments/develop/terraform.tfvars
	cd terraform/modules/tools && terraform validate

# Plan changes for "Tools" module:
plan-tools:
	cd terraform/modules/tools && terraform plan -var-file=../../environments/develop/terraform.tfvars

# Apply changes for "Tools" module:
apply-tools:
	cd terraform/modules/tools && terraform apply --auto-approve -var-file=../../environments/develop/terraform.tfvars

# Destroy resources for "Tools" module:
destroy-tools:
	cd terraform/modules/tools && terraform destroy --auto-approve -var-file=../../environments/develop/terraform.tfvars

# Post-installation setup:
post-install:
	chmod +x scripts/post-install.sh
	./scripts/post-install.sh

# ==================================================== #