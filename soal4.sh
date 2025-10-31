#!/bin/bash
# FILE: soal4.sh (Dijalankan di Erendis, Amdir, dan Node Client)

DNS_MASTER="192.228.3.2"
DNS_SLAVE="192.228.3.3"
DNS_FORWARDER="192.228.5.2"
DOMAIN="k34.com"
SERIAL="2025103102"
ELROS_IP="192.228.1.6"
PHARAZON_IP="192.228.2.7"

# --- BAGIAN ERENDIS (MASTER) ---
if [[ $(hostname) == "Erendis" ]]; then
    echo "--- Menyiapkan ERENDIS (Master DNS) ---"
    
    # Konfigurasi named.conf.local (Tambahkan Master Zone & Controls)
    # (Asumsi rndc.key dan controls sudah ada dari install bind9)
    cat >> /etc/bind/named.conf.local << EOF
zone "$DOMAIN" {
    type master;
    file "/etc/bind/db.k34";
    allow-transfer { $DNS_SLAVE; };
};

# Reverse Zone untuk PTR
zone "3.228.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.3.228.192";
    allow-transfer { $DNS_SLAVE; };
};
EOF
    
    # Buat File Peta Utama (db.k34)
    cat > /etc/bind/db.k34 << EOF
; BIND data file for $DOMAIN
\$TTL    604800
@       IN      SOA     ns1.$DOMAIN. root.$DOMAIN. (
                      $SERIAL      ; Serial (WAJIB UNIK)
                      604800          ; Refresh
                      86400           ; Retry
                      2419200         ; Expire
                      604800 )        ; Negative Cache TTL
; NS Records
@       IN      NS      ns1.$DOMAIN.
@       IN      NS      ns2.$DOMAIN.
; A Records (Name Servers)
ns1     IN      A       $DNS_MASTER
ns2     IN      A       $DNS_SLAVE
; Lokasi Penting (A Records)
palantir  IN    A       192.228.4.3
elros     IN    A       $ELROS_IP
pharazon  IN    A       $PHARAZON_IP
elendil   IN    A       192.228.1.2
isildur   IN    A       192.228.1.3
anarion   IN    A       192.228.1.4
galadriel IN    A       192.228.2.2
celeborn  IN    A       192.228.2.3
oropher   IN    A       192.228.2.4
; CNAME, TXT (Soal 5)
www     IN      CNAME   $DOMAIN.
@       IN      TXT     "Cincin Sauron: elros.$DOMAIN"
@       IN      TXT     "Aliansi Terakhir: pharazon.$DOMAIN"
EOF
    
    # Buat File Reverse Peta (db.3.228.192)
    cat > /etc/bind/db.3.228.192 << EOF
; BIND reverse data file for 192.228.3.x
\$TTL    604800
@       IN      SOA     $DOMAIN. root.$DOMAIN. (
                      $SERIAL      ; Serial
                      604800          ; Refresh
                      86400           ; Retry
                      2419200         ; Expire
                      604800 )        ; Negative Cache TTL
; Name Servers
@       IN      NS      ns1.$DOMAIN.
@       IN      NS      ns2.$DOMAIN.
; PTR Records
2       IN      PTR     ns1.$DOMAIN.
3       IN      PTR     ns2.$DOMAIN.
EOF

    # Fix Permissions & Reload Service
    chgrp bind /etc/bind/db.k34 && chmod g+r /etc/bind/db.k34
    chgrp bind /etc/bind/db.3.228.192 && chmod g+r /etc/bind/db.3.228.192
    rndc reload
    echo "Erendis Master SIAP."

# --- BAGIAN AMDIR (SLAVE) ---
elif [[ $(hostname) == "Amdir" ]]; then
    echo "--- Menyiapkan AMDIR (Slave DNS) ---"
    
    # Konfigurasi named.conf.local (Tambahkan Slave Zone)
    cat >> /etc/bind/named.conf.local << EOF
zone "$DOMAIN" {
    type slave;
    file "/var/lib/bind/db.k34";
    masters { $DNS_MASTER; };
};

zone "3.228.192.in-addr.arpa" {
    type slave;
    file "/var/lib/bind/db.3.228.192";
    masters { $DNS_MASTER; };
};
EOF

    # Fix Permissions & Restart Service
    chown -R bind:bind /var/lib/bind/
    service bind9 restart # Asumsi service bisa direstart, jika tidak: kill & named -u bind
    echo "Amdir Slave SIAP. Menunggu transfer zona..."

# --- BAGIAN CLIENT & MIGRASI FINAL ---
elif [ "$(hostname)" != "Durin" ] && [ "$(hostname)" != "Minastir" ] && [ "$(hostname)" != "Erendis" ] && [ "$(hostname)" != "Amdir" ]; then
    echo "--- Migrasi Final DNS pada $(hostname) ---"
    
    # 1. Update Permanen di interfaces (untuk node statis)
    if [ -f "/etc/network/interfaces" ]; then
        sed -i 's/dns-nameservers 192.228.5.2/dns-nameservers '$DNS_MASTER' '$DNS_SLAVE' '$DNS_FORWARDER'/' /etc/network/interfaces
    fi

    # 2. Update Langsung di resolv.conf (tanpa reboot)
    echo "nameserver $DNS_MASTER" > /etc/resolv.conf
    echo "nameserver $DNS_SLAVE" >> /etc/resolv.conf
    echo "nameserver $DNS_FORWARDER" >> /etc/resolv.conf

    # 3. Minta Lease Baru (untuk node dinamis)
    if command -v dhclient &> /dev/null; then
        dhclient -r && dhclient eth0
    fi
fi