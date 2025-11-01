# Elros

# matiin dulu server nginx default
[ -L /etc/nginx/sites-enabled/default ] && rm /etc/nginx/sites-enabled/default

cat > /etc/nginx/conf.d/upstream_laravel.conf <<'EOF'
upstream kesatria_numenor {
    server elendil.K34.com:8001 max_fails=2 fail_timeout=10s;
    server isildur.K34.com:8002 max_fails=2 fail_timeout=10s;
    server anarion.K34.com:8003 max_fails=2 fail_timeout=10s;
}

server {
    listen 80;
    server_name elros.K34.com;

    location / {
        proxy_pass http://kesatria_numenor;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;

        proxy_connect_timeout 3s;
        proxy_read_timeout    15s;
        proxy_send_timeout    15s;
        proxy_next_upstream error timeout http_502 http_503 http_504;
    }
}

server {
    listen 80 default_server;
    server_name _;
    return 444;
}
EOF

service nginx restart
