#!/bin/bash
# FILE: soal5.sh
# Dijalankan di Erendis (Master) lalu di Amdir (Slave)

DOMAIN="k34.com"
SERIAL_LAMA="2025103101" # Serial dari Soal 4
SERIAL_BARU="2025103102" # Serial BARU
REVERSE_ZONE="3.228.192.in-addr.arpa"
SLAVE_IP="192.228.3.3"
MASTER_IP="192.228.3.2"

# --- BAGIAN ERENDIS (MASTER) ---
if [[ $(hostname) == "Erendis" ]]; then
    echo "--- Menyiapkan ERENDIS (Master) untuk Soal 5 ---" [cite: 48]

    # 1. Update file peta (db.k34) [cite: 48]
    echo "Updating /etc/bind/db.k34..."
    # Update Serial
    sed -i "s/$SERIAL_LAMA/$SERIAL_BARU/" /etc/bind/db.k34 [cite: 48]
    
    # Tambahkan CNAME dan TXT
    cat >> /etc/bind/db.k34 << EOF
; CNAME untuk www
www     IN      CNAME   $DOMAIN.

; Pesan Rahasia (TXT Record)
@       IN      TXT     "Cincin Sauron: elros.$DOMAIN"
@       IN      TXT     "Aliansi Terakhir: pharazon.$DOMAIN"
EOF
    
    # 2. Update named.conf.local (Tambah Reverse Zone) [cite: 50]
    echo "Updating /etc/bind/named.conf.local..."
    cat >> /etc/bind/named.conf.local << EOF
# Reverse zone untuk Jaringan 3 (192.228.3.0/24)
zone "$REVERSE_ZONE" {
    type master;
    file "/etc/bind/db.3.228.192";
    allow-transfer { $SLAVE_IP; }; // Izinkan IP Amdir
};
EOF

    # 3. Buat File Peta Terbalik (db.3.228.192) [cite: 51]
    echo "Membuat /etc/bind/db.3.228.192..."
    cat > /etc/bind/db.3.228.192 << EOF
; BIND reverse data file for 192.228.3.x
\$TTL    604800
@       IN      SOA     $DOMAIN. root.$DOMAIN. (
                      $SERIAL_LAMA      ; Serial (Bisa pakai yg lama/baru)
                      604800          ; Refresh
                      86400           ; Retry
                      2419200         ; Expire
                      604800 )        ; Negative Cache TTL
;
; Name Servers
@       IN      NS      ns1.$DOMAIN.
@       IN      NS      ns2.$DOMAIN.
; PTR Records (IP terakhir -> nama)
2       IN      PTR     ns1.$DOMAIN.    ; 192.228.3.2 -> Erendis
3       IN      PTR     ns2.$DOMAIN.    ; 192.228.3.3 -> Amdir
EOF

    # 4. Perbaiki Izin & Reload
    chgrp bind /etc/bind/db.3.228.192 && chmod g+r /etc/bind/db.3.228.192 [cite: 58]
    echo "Reloading Erendis..."
    rndc reload [cite: 58]
    echo "Erendis (Master) Selesai."

# --- BAGIAN AMDIR (SLAVE) ---
elif [[ $(hostname) == "Amdir" ]]; then
    echo "--- Menyiapkan AMDIR (Slave) untuk Soal 5 ---" [cite: 59]
    
    # 1. Update named.conf.local (Tambah Slave Reverse Zone) [cite: 59]
    echo "Updating /etc/bind/named.conf.local..."
    cat >> /etc/bind/named.conf.local << EOF
# Reverse zone untuk Jaringan 3
zone "$REVERSE_ZONE" {
    type slave;
    file "/var/lib/bind/db.3.228.192";
    masters { $MASTER_IP; }; // IP Erendis
};
EOF

    # 2. Restart Total Amdir (untuk ambil zone baru)
    echo "Restarting Amdir BIND9 Service..."
    ps aux | grep named
    PID_AMDIR=$(ps aux | grep 'named -u bind' | awk '{print $2}')
    if [ -n "$PID_AMDIR" ]; then
        kill $PID_AMDIR
        echo "Killed old process $PID_AMDIR"
    fi
    named -u bind [cite: 60]
    
    echo "Amdir (Slave) Selesai. TUNGGU 15 DETIK untuk transfer zona..."

else
    echo "Script ini hanya untuk Erendis atau Amdir."
fi