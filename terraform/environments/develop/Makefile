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
	find / -type d -name ".terraform" -exec rm -rf {} \;
	[ -d "$HOME/.terraform.d/plugin-cache" ] && rm -rf $HOME/.terraform.d/plugin-cache/*

# Update repository, dependencies, and validate:
init:
	git pull
	cd terraform/modules/vpc && terraform init -var-file=../../environments/develop/terraform.tfvars
	cd terraform/modules/vpc && terraform validate
	cd terraform/modules/rds && terraform init -var-file=../../environments/develop/terraform.tfvars
	cd terraform/modules/rds && terraform validate
	cd terraform/modules/ecs && terraform init -var-file=../../environments/develop/terraform.tfvars
	cd terraform/modules/ecs && terraform validate

# Target for planning changes:
plan:
	cd terraform/environments/develop && terraform plan -var-file=terraform.tfvars

# Target for applying:
apply:
	cd terraform/environments/develop && terraform apply --auto-approve -var-file=terraform.tfvars

# Target for destroying:
destroy:
	cd terraform/environments/develop && terraform destroy --auto-approve -var-file=terraform.tfvars

# ======================== VPC ======================= #

# Clean up temporal and cache files in VPC Module:
cache-vpc:
	cd terraform/modules/vpc && find / -type d -name ".terraform" -exec rm -rf {} \;

# Update repository, dependencies, and validate in VPC Module:
init-vpc:
	git pull
	cd terraform/modules/vpc && terraform init -var-file=../../environments/develop/terraform.tfvars
	cd terraform/modules/vpc && terraform validate

# Target for planning changes only in VPC Module:
plan-vpc:
	cd terraform/modules/vpc && terraform plan -var-file=../../environments/develop/terraform.tfvars

# Target for applying only VPC Module:
apply-vpc:
	cd terraform/modules/vpc && terraform apply --auto-approve -var-file=../../environments/develop/terraform.tfvars

# Target for destroying only VPC Module:
destroy-vpc:
	cd terraform/modules/vpc && terraform destroy --auto-approve -var-file=../../environments/develop/terraform.tfvars

# ======================== RDS ======================= #

# Clean up temporal and cache files in RDS Module:
cache-rds:
	cd terraform/modules/rds && find / -type d -name ".terraform" -exec rm -rf {} \;

# Update repository, dependencies, and validate in RDS Module:
init-rds:
	git pull
	cd terraform/modules/rds && terraform init -var-file=../../environments/develop/terraform.tfvars
	cd terraform/modules/rds && terraform validate

# Target for planning changes only in RDS Module:
plan-rds:
	cd terraform/modules/rds && terraform plan -var-file=../../environments/develop/terraform.tfvars

# Target for applying only RDS Module:
apply-rds:
	cd terraform/modules/rds && terraform apply --auto-approve -var-file=../../environments/develop/terraform.tfvars

# Target for destroying only RDS Module:
destroy-rds:
	cd terraform/modules/rds && terraform destroy --auto-approve -var-file=../../environments/develop/terraform.tfvars

# ======================== ECS ======================= #

# Clean up temporal and cache files in ECS Module:
cache-ecs:
	cd terraform/modules/ecs && find / -type d -name ".terraform" -exec rm -rf {} \;

# Update repository, dependencies, and validate in ECS Module:
init-ecs:
	git pull
	cd terraform/modules/ecs && terraform init -var-file=../../environments/develop/terraform.tfvars
	cd terraform/modules/ecs && terraform validate

# Target for planning changes only in ECS Module:
plan-ecs:
	cd terraform/modules/ecs && terraform plan -var-file=../../environments/develop/terraform.tfvars

# Target for applying only ECS Module:
apply-ecs:
	cd terraform/modules/ecs && terraform apply --auto-approve -var-file=../../environments/develop/terraform.tfvars

# Target for destroying only ECS Module:
destroy-ecs:
	cd terraform/modules/ecs && terraform destroy --auto-approve -var-file=../../environments/develop/terraform.tfvars

# ==================================================== #
