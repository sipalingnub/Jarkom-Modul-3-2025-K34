#!/bin/bash
# FILE: soal9.sh
# Dijalankan di Elendil, Isildur, dan Anarion untuk tes mandiri

echo "--- Memulai Tes Mandiri Soal 9 di $(hostname) ---"

# --- VARIABEL ---
PROXY_IP="192.228.5.2:3128" # Proxy Minastir
DOMAIN="k34.com"
API_PATH="/api/airing" # Sesuai permintaan soal

HOST=$(hostname)
PORT=""

# --- Tentukan Port berdasarkan Hostname ---
if [ "$HOST" == "Elendil" ]; then
    PORT="8001"
elif [ "$HOST" == "Isildur" ]; then
    PORT="8002"
elif [ "$HOST" == "Anarion" ]; then
    PORT="8003"
else
    echo "ERROR: Script ini hanya untuk Elendil, Isildur, atau Anarion."
    exit 1
fi

URL_UTAMA="http://${HOST,,}.$DOMAIN:$PORT"
URL_API="http://${HOST,,}.$DOMAIN:$PORT$API_PATH"

# --- Langkah 1: Instalasi Tools (via Proxy) ---
echo "--- Langkah 1: Instalasi Lynx & Curl (via Proxy Soal 3) ---"

# Atur Proxy untuk apt
echo 'Acquire::http::Proxy "http://'$PROXY_IP'";' > /etc/apt/apt.conf.d/01proxy
echo 'Acquire::https::Proxy "http://'$PROXY_IP'";' >> /etc/apt/apt.conf.d/01proxy

apt-get update
apt-get install -y lynx curl

# --- Langkah 2: Tes Halaman Utama (lynx) ---
echo "--- Langkah 2: Tes Halaman Utama (lynx) ---"
echo "Menjalankan: lynx -dump $URL_UTAMA"
# 'lynx -dump' akan mencetak hasil ke konsol dan langsung keluar (non-interaktif)
lynx -dump $URL_UTAMA
echo "-----------------------------------------"
echo "HARAPAN: Output harus '404 Not Found' (dari Laravel), BUKAN 'connection refused'."
echo "-----------------------------------------"

# --- Langkah 3: Tes API (curl) ---
echo "--- Langkah 3: Tes API (curl) ---"
echo "Menjalankan: curl $URL_API"
curl $URL_API
echo # Tambah baris baru
echo "-----------------------------------------"
echo "HARAPAN: Output harus berupa JSON (misal: []), BUKAN '404 Not Found' HTML."
echo "-----------------------------------------"

echo "SOAL 9 SELESAI di $(hostname)."