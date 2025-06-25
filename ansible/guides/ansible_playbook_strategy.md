Final Project - Serpent Surge 
--  
🚩 Ansible Playbook Strategy for Serpent Surge
--

## Overview

We split Ansible automation into two distinct phases/playbooks:

1. **Base Setup Playbook**  
   - Install system dependencies: Docker, MySQL, nginx, Node.js, Express
   - Configure MySQL database and user  
   - Install nginx without reverse proxy config  
   - Prepare environment for later app deployment

2. **App Deployment Playbook**  
   - Build and deploy frontend/backend Docker containers  
   - Deploy `docker-compose.yml`  
   - Configure nginx reverse proxy to container ports  
   - Start and enable app services

---

## Why split?

- Base setup prepares the server with all core services installed and configured.  
- At this point, no app containers exist, so nginx reverse proxy cannot route traffic properly.  
- App deployment is done after Docker images are ready, ensuring nginx proxy config points to live services.  
- This separation avoids misconfigurations and allows testing core setup independently.

---

## Suggested folder & file structure


ansible/
├── group_vars/
│   └── all.yml     # shared variables: db credentials, paths, ports, etc.
├── roles/
│   ├── system_dependencies/
│   ├── nginx_install/
│   ├── ...
├── playbooks/
│   ├── base_setup.yml    # installs Docker, MySQL, nginx (no proxy)
│   └── app_deploy.yml    # builds containers, runs docker-compose, configures nginx proxy
├── j2/
│   ├── nginx.conf.j2
│   └── app_config.j2
└── guides/



---

## Notes

- Run `base_setup.yml` first on fresh server/VM.  
- Verify MySQL and nginx basic service availability.  
- Build Docker images manually or via separate script before running `app_deploy.yml`.  
- Run `app_deploy.yml` to start app containers and enable nginx reverse proxy.

---

This structure helps maintain clarity and ensures incremental, testable progress.
