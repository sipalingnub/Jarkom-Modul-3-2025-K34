#!/bin/bash
# FILE: soal10.sh
# Dijalankan di Elros (Load Balancer)

# --- Validasi Host ---
if [[ $(hostname) != "Elros" ]]; then
    echo "ERROR: Script ini hanya boleh dijalankan di node Elros."
    exit 1
fi

echo "--- Memulai Konfigurasi Soal 10 di Elros ---"

# --- VARIABEL ---
PROXY_IP="192.228.5.2:3128" # Proxy Minastir
DOMAIN="k34.com"
UPSTREAM_NAME="kesatria_numenor"

# IP Worker (Sesuai Soal 1 & 8)
WORKER1_IP="192.228.1.2:8001" # Elendil
WORKER2_IP="192.228.1.3:8002" # Isildur
WORKER3_IP="192.228.1.4:8003" # Anarion

# --- Langkah 1: Instalasi Nginx (via Proxy) ---
echo "--- Langkah 1: Instalasi Nginx (via Proxy Soal 3) ---"
# Atur Proxy untuk apt
echo 'Acquire::http::Proxy "http://'$PROXY_IP'";' > /etc/apt/apt.conf.d/01proxy
echo 'Acquire::https::Proxy "http://'$PROXY_IP'";' >> /etc/apt/apt.conf.d/01proxy

apt-get update
apt-get install -y nginx

# --- Langkah 2: Konfigurasi Nginx (Reverse Proxy) ---
echo "--- Langkah 2: Konfigurasi Nginx (Reverse Proxy) ---"
CONF_FILE="/etc/nginx/sites-available/elros-lb"

cat > $CONF_FILE << EOF
# 1. Definisikan Upstream (Para Kesatria)
# (Algoritma Round Robin adalah default, tidak perlu ditulis)
upstream $UPSTREAM_NAME {
    server $WORKER1_IP; # Elendil
    server $WORKER2_IP; # Isildur
    server $WORKER3_IP; # Anarion
}

# 2. Definisikan Server (Elros)
server {
    listen 80;
    server_name elros.$DOMAIN;

    location / {
        # Teruskan semua permintaan ke upstream
        proxy_pass http://$UPSTREAM_NAME;
        
        # Header tambahan (Best Practice agar worker tahu siapa client aslinya)
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# --- Langkah 3: Aktifkan Situs & Restart Nginx ---
echo "--- Langkah 3: Aktifkan Situs & Restart Nginx ---"

# Buat symlink (tambahkan -f untuk "force" menimpa jika sudah ada)
ln -s -f $CONF_FILE /etc/nginx/sites-enabled/

# Hapus config default jika masih ada
rm -f /etc/nginx/sites-enabled/default

echo "Mengecek sintaks Nginx..."
nginx -t
# Jika 'nginx -t' gagal, script akan berhenti di sini

echo "Merestart Nginx..."
service nginx restart

echo "--- SOAL 10 SELESAI di Elros ---"
echo "Verifikasi (dari node client, misal Miriel):"
echo "1. Pastikan DNS Soal 4/5 sudah di-update (Elros 192.228.1.6 harus ada di db.k34 Erendis)"
echo "2. Jalankan: lynx http://elros.k34.com/api/animes"
echo "3. Jalankan berkali-kali untuk melihat Round Robin (traffic akan tersebar)."