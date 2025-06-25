Final Project - Serpent Surge 
--  
🚩 Ansible Playbook Strategy for Serpent Surge
--

To serve in browser via nginx:

Place `frontend/` in `/data/www/serpent-surge-main/frontend/`

Update nginx config:

```
root /data/www/serpent-surge-main/frontend;
index index.html;
```

Backend (`index.js`) is Node.js app — run separately (port 3000), reverse proxy if needed.

