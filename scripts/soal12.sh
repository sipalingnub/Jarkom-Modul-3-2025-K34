# PHP Worker Galadriel/Celeborn/Oropher
# note (masi di galadriel)
mkdir -p /var/www/html

cat >/var/www/html/index.php <<'PHP'
<?php
echo "Hello from " . gethostname();
PHP

chown -R www-data:www-data /var/www/html

# Galadriel (port 8004)
cat > /etc/nginx/conf.d/php-worker.conf <<'EOF'
server {
  listen 8004;
  server_name galadriel.K34.com;

  root /var/www/html;
  index index.php;

  location / {
    try_files $uri $uri/ /index.php?$query_string;
  }

  location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/run/php/php8.4-fpm.sock;
  }
}
EOF


ln -sf /etc/nginx/sites-available/php-worker /etc/nginx/sites-enabled/php-worker
[ -L /etc/nginx/sites-enabled/default ] && rm /etc/nginx/sites-enabled/default

nginx -t && service nginx reload
service php8.4-fpm restart
