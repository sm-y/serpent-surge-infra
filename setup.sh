#!/bin/bash

# Run with: ./setup.sh from project root.
cd /data/serpent-surge-infra/ansible
# This will install Ansible + collections on the control node (dev-ubuntu) and 
# run the full pipeline targeting prod.
set -e

# Run bootstrap to install Ansible and collections
cd ../terraform
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
ansible-playbook -i hosts playbooks/playbook_base_setup.yml -l dev
ansible-playbook -i hosts playbooks/playbook_base_setup.yml -l prod

# POC MySQL on dev (optional)
ansible-playbook -i hosts playbooks/playbook_poc_mysql.yml -l dev

# RDS MySQL
ansible-playbook -i hosts playbooks/playbook_rds_mysql.yml -l prod

# Images are always built locally on dev-ubuntu, just switch vars.
# Build dev images (local MySQL host) & prod images (RDS, ECR push)
ansible-playbook playbooks/playbook_app_build.yml -l dev
# To build & push prod images, run on dev host (-l dev) with build_env=prod.
ansible-playbook playbooks/playbook_app_build.yml --extra-vars "build_env=prod" -l dev

# Cleanup tasks run on prod hosts only if build_env=prod is set.
# Running with -l prod without build_env=prod means cleanup tasks usually skip.
ansible-playbook playbooks/playbook_app_build.yml -l prod
ansible-playbook playbooks/playbook_app_build.yml --extra-vars "build_env=prod" -l prod

# App deploy
ansible-playbook -i hosts playbooks/playbook_app_deploy.yml -l dev
ansible-playbook -i hosts playbooks/playbook_app_deploy.yml -l prod

# Nginx config + SSL
ansible-playbook -i hosts playbooks/playbook_config_deploy.yml -l dev
ansible-playbook -i hosts playbooks/playbook_config_deploy.yml -l prod

