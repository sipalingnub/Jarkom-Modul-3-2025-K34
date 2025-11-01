# Dijalankan di Elendil, Isildur, dan Anarion
cd /opt
git clone https://github.com/elshiraphine/laravel-simple-rest-api laravel-app
cd laravel-app
apt -y install php8.4-xml php8.4-mysql php8.4-mbstring php8.4-curl php8.4-zip php8.4-intl
rm -rf vendor composer.lock
composer update --with-all-dependencies
cp .env.example .env
php artisan key:generate

mkdir -p storage/logs bootstrap/cache
touch storage/logs/laravel.log

# kasih hak tulis ke www-data
chown -R www-data:www-data storage bootstrap/cache
chmod -R ug+rwX storage bootstrap/cache

cat >/etc/nginx/sites-available/laravel <<'EOF'
server {
    listen 8001; # atau 8002, 8003 sesuai host
    server_name <hostname>.K34.com <hostname>;

    root /opt/laravel-app/public;
    index index.php index.html;

    # Laravel front controller
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # PHP handler
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        # pastikan ini 8.4:
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    # Security/opsional
    location ~ /\.(?!well-known).* { deny all; }
    client_max_body_size 20m;

    access_log /var/log/nginx/elnd_access.log;
    error_log  /var/log/nginx/elnd_error.log;
}
EOF
ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/laravel
service php8.4-fpm restart
service nginx restart
