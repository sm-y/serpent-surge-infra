# serpent-surge-infra

Infra automation for Serpent Surge using Ansible, Terraform, and Docker.

Live app: [https://serpent-surge.ddns.net]

---

## Usage

- Ubuntu 24.04 LTS

From project root:

```bash
chmod +x setup.sh
./setup.sh
```

This will: root → setup.sh → Terraform → Ansible playbooks (in order)

1. Install Ansible and dependencies
2. Run Terraform to provision AWS (RDS, EFS, ECR)
3. Use Ansible to:
   - Setup disk, swap, and EFS mount
   - Install Docker, nginx, MySQL (RDS)
   - Build and push Docker images
   - Deploy containers
   - Configure nginx + SSL

You can also run individual playbooks from `ansible/playbooks/` if needed.

---

## Architecture

- Dev-Ubuntu = local test box
- Prod-Ubuntu = AWS EC2 set up by Terraform + Ansible
- Dev builds app containers, pushes to ECR
- Prod pulls from ECR, runs containers
- nginx reverse proxy configured after app is live

---

## Repo Structure

- `ansible/`: roles, playbooks, templates
- `terraform/`: AWS infra (VPC, RDS, etc.)
- `docker/`: Dockerfiles, compose
- `bash/`: DB backup scripts
- `mysql/`: schema.sql, create_user.sql
