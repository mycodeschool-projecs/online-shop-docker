#!/usr/bin/env bash
set -euo pipefail

echo "=== Installing Nginx on Ubuntu/Debian ==="
sudo apt-get update -y
sudo apt-get install -y nginx

echo "=== Creating a custom Nginx reverse proxy config ==="
sudo tee /etc/nginx/sites-available/myapp.conf > /dev/null << 'EOF'
server {
    listen 80;
    server_name _;

    # Proxy /api to Spring Boot (service-container) on port 8080
    location /api/ {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # Proxy /client to React client (client-container) on port 3000
    location /{
        proxy_pass http://127.0.0.1:3000/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

echo "=== Enabling our site and removing the default site ==="
sudo ln -sf /etc/nginx/sites-available/myapp.conf /etc/nginx/sites-enabled/myapp.conf
sudo rm -f /etc/nginx/sites-enabled/default

echo "=== Testing Nginx config syntax ==="
sudo nginx -t

echo "=== Restarting Nginx ==="
sudo systemctl enable nginx
sudo systemctl restart nginx

echo "=== Nginx installed and configured! ==="
echo "You can now visit:"
echo "  http://<your-server>/api/...    -> proxies to http://127.0.0.1:8080/"
echo "  http://<your-server>/client/... -> proxies to http://127.0.0.1:3000/"
