# serpent-surge-infra

Infra automation for Serpent Surge using Ansible, Terraform, and Docker.

Live app: [https://serpent-surge.ddns.net]

---

## Usage

- Ubuntu 24.04 LTS
- Control node: Dev-Ubuntu (local build and orchestration)
- Production node: Prod-Ubuntu (AWS EC2 provisioned by Terraform + Ansible)

From project root:

```bash
chmod +x setup.sh
./setup.sh
```

Flow: root setup.sh → imports Terraform state → runs Terraform → then Ansible (ordered roles)

1. Install Ansible and dependencies
2. Run Terraform to provision AWS infra (VPC, RDS, EFS, ECR)
3. Use Ansible to:
   - Setup disk, swap, and EFS mount
   - Install Docker, Nginx, and MySQL (RDS)
   - Build and push Docker images to AWS ECR
     - Built with unique digests (timestamps)
     - Control node (Dev-Ubuntu) builds and pushes
     - Prod node pulls images by digest
     - Old images cleaned via lifecycle policies
   - Deploy containers
   - Configure Nginx with SSL

You can also run individual playbooks from `ansible/playbooks/` if needed.

---

## Key Updates

- Docker images are tagged and pulled by digest, ensuring immutable deployment and avoiding "latest" tag issues.
- Added Ansible cleanup role to remove unused Docker images, containers, and prune system.
- Use of `community.docker` modules for image management and pruning.
- Deployment uses `docker-compose` on prod node for container orchestration, but images managed explicitly by Ansible modules.
- ECR lifecycle policies configured to auto-clean untagged images.
- Next to do: AWS credentials and secrets managed securely via Ansible vault or environment variables.

---

## Architecture

- Dev-Ubuntu: Local build, Docker image creation, pushes to ECR.
- Prod-Ubuntu: AWS EC2 instance provisioned with Terraform + Ansible, runs containers via docker-compose using immutable digests.
- Dev builds app containers, pushes to ECR
- Prod pulls from ECR, runs containers
- nginx reverse proxy configured after app is live
- Ansible roles structured by concern: system setup, docker install, app build, app run, backup service, secrets.

---

## Repo Structure (summary)

- `terraform/`: AWS infra provisioning
- `ansible/`: playbooks, roles, templates for setup, build, deploy, cleanup
- `docker/`: Dockerfiles, docker-compose templates with digest tagging
- `bash/`: backup scripts
- `mysql/`: DB schema and user scripts
