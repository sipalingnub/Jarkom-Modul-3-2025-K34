# Dijalankan di Elendil, Isildur, dan Anarion sementara karena Palantir belum di setup, jadi lokal dulu

service mariadb start

mysql -u root <<'SQL'
CREATE DATABASE IF NOT EXISTS laravel CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'laravel'@'127.0.0.1' IDENTIFIED BY 'laravelpass';
GRANT ALL PRIVILEGES ON laravel.* TO 'laravel'@'127.0.0.1';
FLUSH PRIVILEGES;
SQL

# jangan lupa ubah .env nya jadi

# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=laravel
# DB_USERNAME=laravel
# DB_PASSWORD=laravelpass

php artisan migrate --seed
