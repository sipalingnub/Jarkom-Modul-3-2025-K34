#!/bin/bash
# FILE: soal8.sh
# Dijalankan di Palantir, Elendil, Isildur, dan Anarion

HOST=$(hostname)
DOMAIN="k34.com"
PROJECT_DIR="/var/www/laravel-simple-rest-api"
DB_IP="192.228.4.3" # IP Palantir
DB_NAME="laravel_db"
DB_USER="laravel_user"
DB_PASS="password123"

# --- BAGIAN PALANTIR (DATABASE SERVER) ---
if [[ "$HOST" == "Palantir" ]]; then
    echo "--- Menyiapkan PALANTIR (Database) ---"
    
    # Atur Proxy (Wajib untuk apt)
    echo 'Acquire::http::Proxy "http://192.228.5.2:3128";' > /etc/apt/apt.conf.d/01proxy
    echo 'Acquire::https::Proxy "http://192.228.5.2:3128";' >> /etc/apt/apt.conf.d/01proxy
    
    apt-get update && apt-get install -y mariadb-server
    service mariadb start # (Ganti ke 'mysql start' jika mariadb gagal)
    
    mysql -e "CREATE DATABASE $DB_NAME;"
    mysql -e "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';"
    mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';"
    mysql -e "FLUSH PRIVILEGES;"
    
    # Izinkan Koneksi Remote
    sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
    service mariadb restart
    echo "PALANTIR (Database) SIAP."

# --- BAGIAN WORKER LARAVEL (ELENDIL, ISILDUR, ANARION) ---
elif [[ "$HOST" == "Elendil" || "$HOST" == "Isildur" || "$HOST" == "Anarion" ]]; then
    echo "--- Menyiapkan WORKER $HOST ---"
    
    PORT=""
    if [ "$HOST" == "Elendil" ]; then PORT="8001"; fi
    if [ "$HOST" == "Isildur" ]; then PORT="8002"; fi
    if [ "$HOST" == "Anarion" ]; then PORT="8003"; fi

    cd $PROJECT_DIR
    
    # 1. Konfigurasi .env (Menimpa file lama dengan DB_HOST yang benar)
    cat > .env << EOF
APP_NAME=Laravel
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost

DB_CONNECTION=mysql
DB_HOST=$DB_IP
DB_PORT=3306
DB_DATABASE=$DB_NAME
DB_USERNAME=$DB_USER
DB_PASSWORD=$DB_PASS
EOF
    
    # Generate APP_KEY (Wajib)
    php artisan key:generate
    
    # 2. Migrasi Database (Hanya Elendil)
    if [ "$HOST" == "Elendil" ]; then
        echo "Menjalankan migrasi database dari Elendil..."
        php artisan migrate:fresh --seed
    fi
    
    # 3. Konfigurasi Nginx
    NGINX_CONF="/etc/nginx/sites-available/$HOST"
    cat > $NGINX_CONF << EOF
server {
    listen $PORT;
    server_name ${HOST,,}.$DOMAIN;

    root $PROJECT_DIR/public;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

    # 4. Fix Permissions (chown & chmod)
    echo "Memperbaiki izin folder untuk www-data..."
    chown -R www-data:www-data $PROJECT_DIR
    chmod -R 775 $PROJECT_DIR/storage

    # 5. Aktifkan Config & Restart Service
    ln -s -f $NGINX_CONF /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    
    echo "Mengecek sintaks Nginx..."
    nginx -t
    
    echo "Merestart Nginx dan PHP-FPM..."
    service nginx restart
    service php8.4-fpm restart

    echo "$HOST Worker SIAP di port $PORT."

else
    echo "Script ini hanya untuk Palantir, Elendil, Isildur, atau Anarion."
fi