#!/bin/bash

# Run with: ./setup.sh from project root.
# This will install Ansible + collections on the control node (dev-ubuntu) and 
# run the full pipeline targeting prod.
set -e

# Ensure .env is loaded before running (or inject into shell)
set -a
source .env
export $(grep '^TF_VAR_' .env | xargs)
set +a

# Run bootstrap to install Ansible and collections
cd terraform
dos2unix bootstrap.sh
chmod +x bootstrap.sh
./bootstrap.sh

# Run Terraform for infra (EFS, RDS, etc)
dos2unix import.sh
chmod +x import.sh
terraform init -migrate-state
./import.sh
terraform apply -auto-approve

# Run Ansible playbooks
cd ../ansible

# Swap and disk setup
ansible-playbook -i hosts playbooks/playbooks_swap_disk.yml -l prod

# EFS setup
ansible-playbook -i hosts playbooks/playbook_efs_mount.yml -l prod

# Base setup
ansible-playbook -i hosts playbooks/playbook_base_setup.yml -l prod

# POC MySQL on dev (optional)
# ansible-playbook -i hosts playbooks/playbook_poc_mysql.yml -l dev

# RDS MySQL
ansible-playbook -i hosts playbooks/playbook_rds_mysql.yml -l prod

# Images are always built locally on dev-ubuntu, just switch vars.
# Build dev images (local MySQL host)
ansible-playbook playbooks/playbook_app_build.yml --extra-vars "build_env=dev" --tags build-dev

# Build prod images (RDS, ECR push)
ansible-playbook playbooks/playbook_app_build.yml --extra-vars "build_env=prod" --tags build-prod

# App deploy
ansible-playbook -i hosts playbooks/playbook_app_deploy.yml -l dev
ansible-playbook -i hosts playbooks/playbook_app_deploy.yml -l prod

# Nginx config + SSL
ansible-playbook -i hosts playbooks/playbook_config_deploy.yml -l dev
ansible-playbook -i hosts playbooks/playbook_config_deploy.yml -l prod
