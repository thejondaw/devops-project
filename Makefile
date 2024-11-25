# Variables
ENV ?= develop
TFVARS_PATH = terraform/environments/$(ENV)/terraform.tfvars
TERRAFORM_CACHE = $(HOME)/.terraform.d/plugin-cache

# Module order is important!
MODULES_CREATE = backend vpc eks rds tools
MODULES_DESTROY = tools rds eks vpc backend

# Install required tools
.PHONY: setup
setup:
	sudo yum install -y yum-utils
	sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
	sudo yum -y install terraform
	cp .terraformrc ~/.terraformrc

# Clean terraform cache
.PHONY: clean
clean:
	find . -type d -name ".terraform" -exec rm -rf {} +
	[ -d "$(TERRAFORM_CACHE)" ] && rm -rf $(TERRAFORM_CACHE)/* || true

# Initialize all modules
.PHONY: init init-%
init:
	@for module in $(MODULES_CREATE); do \
		echo "Initializing $$module..."; \
		cd terraform/modules/$$module && \
		terraform init -var-file=../../environments/$(ENV)/terraform.tfvars && \
		terraform validate && \
		cd ../../../; \
	done

init-%:
	cd terraform/modules/$* && \
	terraform init -var-file=../../environments/$(ENV)/terraform.tfvars && \
	terraform validate

# Plan changes
.PHONY: plan plan-%
plan:
	@for module in $(MODULES_CREATE); do \
		echo "Planning $$module..."; \
		cd terraform/modules/$$module && \
		terraform plan -var-file=../../environments/$(ENV)/terraform.tfvars && \
		cd ../../../; \
	done

plan-%:
	cd terraform/modules/$* && \
	terraform plan -var-file=../../environments/$(ENV)/terraform.tfvars

# Apply changes in correct order
.PHONY: apply apply-%
apply:
	@for module in $(MODULES_CREATE); do \
		echo "Applying $$module..."; \
		cd terraform/modules/$$module && \
		terraform apply --auto-approve -var-file=../../environments/$(ENV)/terraform.tfvars && \
		cd ../../../; \
	done

apply-%:
	cd terraform/modules/$* && \
	terraform apply --auto-approve -var-file=../../environments/$(ENV)/terraform.tfvars

# Destroy resources in correct order
.PHONY: destroy destroy-%
destroy:
	@for module in $(MODULES_DESTROY); do \
		echo "Destroying $$module..."; \
		cd terraform/modules/$$module && \
		terraform destroy --auto-approve -var-file=../../environments/$(ENV)/terraform.tfvars && \
		cd ../../../; \
	done

destroy-%:
	cd terraform/modules/$* && \
	terraform destroy --auto-approve -var-file=../../environments/$(ENV)/terraform.tfvars

# Post-installation setup
.PHONY: post-install
post-install:
	chmod +x scripts/post-install.sh && ./scripts/post-install.sh

# ALiases Script
.PHONY: aliases
aliases:
	chmod +x scripts/aliases.sh
	./scripts/aliases.sh

# Helper to configure backend
.PHONY: configure-backend
configure-backend:
	@for module in vpc eks rds tools; do \
		echo "Configuring backend for $$module..."; \
		cd terraform/modules/$$module && \
		terraform init \
			-backend-config="bucket=$(TF_BACKEND_BUCKET)" \
			-backend-config="key=environments/$(ENV)/$$module.tfstate" \
			-backend-config="region=$(AWS_REGION)" && \
		cd ../../../; \
	done
