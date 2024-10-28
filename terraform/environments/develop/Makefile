# Root path
TERRAFORM_ROOT := terraform

# Variables with the path to Modules
VPC_MODULE_PATH := $(TERRAFORM_ROOT)/modules/vpc
RDS_MODULE_PATH := $(TERRAFORM_ROOT)/modules/rds
ECS_MODULE_PATH := $(TERRAFORM_ROOT)/modules/ecs

# ==================== Terraform ===================== #

# Terraform install:
terraform:
	sudo yum install -y yum-utils
	sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
	sudo yum -y install terraform

# ======================= Root ======================= #

# Copy ".terraformrc" into /root:
rc:
	cp .terraformrc ~/.terraformrc

# ====================== Modules ===================== #

# Clean up temporal and cache files:
cache:
	find / -type d  -name ".terraform" -exec rm -rf {} \;
	[ -d "$HOME/.terraform.d/plugin-cache" ] && rm -rf $HOME/.terraform.d/plugin-cache/*

# Update repository, dependencies and validate:
init:
	git pull
	cd $(VPC_MODULE_PATH) && terraform init -var-file=../../environments/develop/terraform.tfvars
	cd $(VPC_MODULE_PATH) && terraform validate
	cd $(RDS_MODULE_PATH) && terraform init -var-file=../../environments/develop/terraform.tfvars
	cd $(RDS_MODULE_PATH) && terraform validate
	cd $(ECS_MODULE_PATH) && terraform init -var-file=../../environments/develop/terraform.tfvars
	cd $(ECS_MODULE_PATH) && terraform validate

# Target for planning changes:
plan:
	cd $(TERRAFORM_ROOT)/environments/develop && terraform plan -var-file=terraform.tfvars

# Target for applying:
apply:
	cd $(TERRAFORM_ROOT)/environments/develop && terraform apply --auto-approve -var-file=terraform.tfvars

# Target for destroying:
destroy:
	cd $(TERRAFORM_ROOT)/environments/develop && terraform destroy --auto-approve -var-file=terraform.tfvars

# ======================== VPC ======================= #

# Clean up temporal and cache files in VPC Module:
cache-vpc:
	cd $(VPC_MODULE_PATH) && find / -type d -name ".terraform" -exec rm -rf {} \;

# Update repository, dependencies and validate in VPC Module:
init-vpc:
	git pull
	cd $(VPC_MODULE_PATH) && terraform init -var-file=../../environments/develop/terraform.tfvars
	cd $(VPC_MODULE_PATH) && terraform validate

# Target for planning changes only in VPC Module:
plan-vpc:
	cd $(VPC_MODULE_PATH) && terraform plan -var-file=../../environments/develop/terraform.tfvars

# Target for applying only VPC Module:
apply-vpc:
	cd $(VPC_MODULE_PATH) && terraform apply --auto-approve -var-file=../../environments/develop/terraform.tfvars

# Target for destroying only VPC Module:
destroy-vpc:
	cd $(VPC_MODULE_PATH) && terraform destroy --auto-approve -var-file=../../environments/develop/terraform.tfvars

# ======================== RDS ======================= #

# Clean up temporal and cache files in RDS Module:
cache-rds:
	cd $(RDS_MODULE_PATH) && find / -type d -name ".terraform" -exec rm -rf {} \;

# Update repository, dependencies and validate in RDS Module:
init-rds:
	git pull
	cd $(RDS_MODULE_PATH) && terraform init -var-file=../../environments/develop/terraform.tfvars
	cd $(RDS_MODULE_PATH) && terraform validate

# Target for planning changes only in RDS Module:
plan-rds:
	cd $(RDS_MODULE_PATH) && terraform plan -var-file=../../environments/develop/terraform.tfvars

# Target for applying only RDS Module:
apply-rds:
	cd $(RDS_MODULE_PATH) && terraform apply --auto-approve -var-file=../../environments/develop/terraform.tfvars

# Target for destroying only RDS Module:
destroy-rds:
	cd $(RDS_MODULE_PATH) && terraform destroy --auto-approve -var-file=../../environments/develop/terraform.tfvars

# ======================== ECS ======================= #

# Clean up temporal and cache files in ECS Module:
cache-ecs:
	cd $(ECS_MODULE_PATH) && find / -type d -name ".terraform" -exec rm -rf {} \;

# Update repository, dependencies and validate in ECS Module:
init-ecs:
	git pull
	cd $(ECS_MODULE_PATH) && terraform init -var-file=../../environments/develop/terraform.tfvars
	cd $(ECS_MODULE_PATH) && terraform validate

# Target for planning changes only in ECS Module:
plan-ecs:
	cd $(ECS_MODULE_PATH) && terraform plan -var-file=../../environments/develop/terraform.tfvars

# Target for applying only ECS Module:
apply-ecs:
	cd $(ECS_MODULE_PATH) && terraform apply --auto-approve -var-file=../../environments/develop/terraform.tfvars

# Target for destroying only ECS Module:
destroy-ecs:
	cd $(ECS_MODULE_PATH) && terraform destroy --auto-approve -var-file=../../environments/develop/terraform.tfvars

# ==================================================== #
