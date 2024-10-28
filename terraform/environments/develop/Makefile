# ==================== Terraform ===================== #

# Установка Terraform:
terraform:
	sudo yum install -y yum-utils
	sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
	sudo yum -y install terraform

# ======================== Root ======================= #

# Копирование ".terraformrc" в домашний каталог:
rc:
	cp .terraformrc ~/.terraformrc

# ====================== Modules ====================== #

# Очистка временных и кэшированных файлов:
cache:
	find / -type d -name ".terraform" -exec rm -rf {} \;
	[ -d "$HOME/.terraform.d/plugin-cache" ] && rm -rf $HOME/.terraform.d/plugin-cache/*

# Инициализация и валидация всех модулей:
init:
	git pull
	cd terraform/modules/vpc && terraform init -var-file=$(pwd)/terraform/environments/develop/terraform.tfvars
	cd terraform/modules/vpc && terraform validate
	cd terraform/modules/rds && terraform init -var-file=$(pwd)/terraform/environments/develop/terraform.tfvars
	cd terraform/modules/rds && terraform validate
	cd terraform/modules/ecs && terraform init -var-file=$(pwd)/terraform/environments/develop/terraform.tfvars
	cd terraform/modules/ecs && terraform validate

# Планирование изменений:
plan:
	cd terraform/environments/develop && terraform plan -var-file=terraform.tfvars

# Применение изменений:
apply:
	cd terraform/environments/develop && terraform apply --auto-approve -var-file=terraform.tfvars

# Удаление ресурсов:
destroy:
	cd terraform/environments/develop && terraform destroy --auto-approve -var-file=terraform.tfvars

# ======================== VPC ======================== #

# Очистка временных и кэшированных файлов для VPC модуля:
cache-vpc:
	cd terraform/modules/vpc && find / -type d -name ".terraform" -exec rm -rf {} \;

# Инициализация и валидация VPC модуля:
init-vpc:
	git pull
	cd terraform/modules/vpc && terraform init -var-file=$(pwd)/terraform/environments/develop/terraform.tfvars
	cd terraform/modules/vpc && terraform validate

# Планирование изменений только для VPC модуля:
plan-vpc:
	cd terraform/modules/vpc && terraform plan -var-file=$(pwd)./terraform/environments/develop/terraform.tfvars

# Применение изменений только для VPC модуля:
apply-vpc:
	cd terraform/modules/vpc && terraform apply --auto-approve -var-file=$(pwd)./terraform/environments/develop/terraform.tfvars

# Удаление ресурсов только для VPC модуля:
destroy-vpc:
	cd terraform/modules/vpc && terraform destroy --auto-approve -var-file=$(pwd)./terraform/environments/develop/terraform.tfvars

# ======================== RDS ======================== #

# Очистка временных и кэшированных файлов для RDS модуля:
cache-rds:
	cd terraform/modules/rds && find / -type d -name ".terraform" -exec rm -rf {} \;

# Инициализация и валидация RDS модуля:
init-rds:
	git pull
	cd terraform/modules/rds && terraform init -var-file=$(pwd)/terraform/environments/develop/terraform.tfvars
	cd terraform/modules/rds && terraform validate

# Планирование изменений только для RDS модуля:
plan-rds:
	cd terraform/modules/rds && terraform plan -var-file=$(pwd)/terraform/environments/develop/terraform.tfvars

# Применение изменений только для RDS модуля:
apply-rds:
	cd terraform/modules/rds && terraform apply --auto-approve -var-file=$(pwd)/terraform/environments/develop/terraform.tfvars

# Удаление ресурсов только для RDS модуля:
destroy-rds:
	cd terraform/modules/rds && terraform destroy --auto-approve -var-file=$(pwd)/terraform/environments/develop/terraform.tfvars

# ======================== ECS ======================== #

# Очистка временных и кэшированных файлов для ECS модуля:
cache-ecs:
	cd terraform/modules/ecs && find / -type d -name ".terraform" -exec rm -rf {} \;

# Инициализация и валидация ECS модуля:
init-ecs:
	git pull
	cd terraform/modules/ecs && terraform init -var-file=$(pwd)/terraform/environments/develop/terraform.tfvars
	cd terraform/modules/ecs && terraform validate

# Планирование изменений только для ECS модуля:
plan-ecs:
	cd terraform/modules/ecs && terraform plan -var-file=$(pwd)/terraform/environments/develop/terraform.tfvars

# Применение изменений только для ECS модуля:
apply-ecs:
	cd terraform/modules/ecs && terraform apply --auto-approve -var-file=$(pwd)/terraform/environments/develop/terraform.tfvars

# Удаление ресурсов только для ECS модуля:
destroy-ecs:
	cd terraform/modules/ecs && terraform destroy --auto-approve -var-file=$(pwd)/terraform/environments/develop/terraform.tfvars

# ===================================================== #
