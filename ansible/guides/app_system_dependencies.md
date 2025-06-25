Final Project - Serpent Surge 
--  
🚩 It documents the required system dependencies and setup steps.
--

🗻[ ] Final Project; look at 

  [1] - PoC demo: manual EC2 + local DB + Compose + nginx is enough. 
  [2] - Parallerly: Ansible script automation
  [3] - 


Stepwise commands to install each tool on Ubuntu (dev-ubuntu for most, prod-ubuntu for Docker/nginx):

1. mysql-server (latest official repo):

```bash
sudo apt update
sudo apt install -y wget lsb-release gnupg
wget https://dev.mysql.com/get/mysql-apt-config_0.8.26-1_all.deb
sudo dpkg -i mysql-apt-config_0.8.26-1_all.deb
sudo apt update
sudo apt install -y mysql-server mysql-client
sudo systemctl enable --now mysql
```

2. nodejs (latest LTS):

```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
node -v
npm -v
```

3. ansible:

```bash
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
ansible --version
```

4. git:

```bash
sudo apt update
sudo apt install -y git
git --version
```

5. curl, wget:

```bash
sudo apt update
sudo apt install -y curl wget
```

6. docker-ce and docker-compose (on prod-ubuntu):

```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable --now docker

# Install docker-compose plugin
sudo apt install -y docker-compose-plugin
docker compose version

```

7. nginx (on prod-ubuntu):

```bash
sudo apt update
sudo apt install -y nginx
sudo systemctl enable --now nginx
nginx -v
```

Pause. Ready for execution or modification.






App Micro Awareness Summary

Stack:

* **Frontend:** HTML + CSS + JS → browser-based
* **Backend:** Node.js + Express
* **Database:** MySQL (via `mysql2`)

Ports:

* **Frontend served by backend** → likely uses port `3000`
* **MySQL default port** → `3306`

Runtime:

* Requires:

  * `node`, `npm`, `express`, `mysql2`
  * `mysqld` running and reachable from Node

Networking:

* Node app listens on `0.0.0.0:3000` → needs **inbound TCP 3000 open** in security group
* MySQL may be local (same host) or remote → if remote, **inbound TCP 3306** open on DB host

System dependencies:

* Node.js runtime (16+ for full `mysql2` compat)
* MySQL Server
* Linux user with access to both services

Deployment implications:

* Needs EC2 (x86_64) instance
* Node+MySQL stack installed and running
* Reverse proxy optional (e.g., nginx)
* Static frontend can be served by Express or separately via S3/CloudFront if split

No action taken yet — this is passive prep only.

