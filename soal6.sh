#!/bin/bash
# FILE: soal6.sh
# Dijalankan di Amandil dan Gilgalad untuk VERIFIKASI

echo "--- Menjalankan Verifikasi Soal 6 di $(hostname) ---"

# 1. Minta Ulang Lease
echo "Meminta DHCP lease baru..."
dhclient -r && dhclient -v eth0 [cite: 68, 69]

# 2. Cek File Lease
echo "Mengecek file lease-time:"
cat /var/lib/dhcp/dhclient.leases | grep "lease-time" [cite: 68, 69]

if [[ $(hostname) == "Amandil" ]]; then
    echo "HARAPAN: Harus ada 'option dhcp-lease-time 1800;'"
elif [[ $(hostname) == "Gilgalad" ]]; then
    echo "HARAPAN: Harus ada 'option dhcp-lease-time 600;'"
fi