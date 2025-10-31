#!/bin/bash
# FILE: soal7.sh
# Dijalankan di Elendil, Isildur, dan Anarion

echo "--- Memulai Instalasi Worker Laravel di $(hostname) ---"

# --- VARIABEL ---
PROXY_IP="192.228.5.2:3128" # Proxy Minastir
PROJECT_DIR="/var/www/laravel-simple-rest-api"

echo "--- Langkah 0: Konfigurasi Proxy (Soal 3) ---"
# Atur Proxy untuk apt 
echo 'Acquire::http::Proxy "http://'$PROXY_IP'";' > /etc/apt/apt.conf.d/01proxy
echo 'Acquire::https::Proxy "http://'$PROXY_IP'";' >> /etc/apt/apt.conf.d/01proxy

# Atur Proxy untuk Terminal (curl, git, composer) [cite: 71]
export http_proxy="http://$PROXY_IP"
export https_proxy="http://$PROXY_IP"

echo "--- Langkah 1: Instalasi PPA & PHP ---"
# Install Prasyarat (Fix: Tanpa software-properties-common) [cite: 71]
apt-get update && apt-get install -y lsb-release ca-certificates apt-transport-https gnupg2

# Tambahkan PPA PHP Sury.org [cite: 71]
curl -sSL https://packages.sury.org/php/README.txt | bash -x

# Install PHP 8.4, Nginx, dan Git [cite: 72]
apt-get update
apt-get install -y php8.4 php8.4-fpm php8.4-mysql php8.4-mbstring php8.4-xml php8.4-curl php8.4-zip unzip nginx git

echo "--- Langkah 2: Instalasi Composer ---" [cite: 72]
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

echo "--- Langkah 3: Setup Proyek Laravel ---"
cd /var/www
git clone https://github.com/elshiraphine/laravel-simple-rest-api.git [cite: 72]
cd $PROJECT_DIR

# Fix: Update composer untuk PHP 8.4 (bukan install) [cite: 72]
composer update

cp .env.example .env [cite: 72]
php artisan key:generate [cite: 72]

echo "--- Langkah 4: Verifikasi Instalasi ---"
echo "Mengecek .env:"
cat $PROJECT_DIR/.env
echo "Mengecek folder vendor:"
ls $PROJECT_DIR/vendor/
echo "Mengecek versi artisan:"
php artisan --version

echo "SOAL 7 SELESAI di $(hostname)."