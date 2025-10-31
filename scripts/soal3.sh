#!/bin/bash
# FILE: soal3.sh (Dijalankan di Minastir, Aldarion, dan 16 Node Statis)

# --- VARIABEL DNS BARU ---
DNS1="192.228.5.2" # Minastir

# --- BAGIAN MINASTIR (FORWARDER) ---
if [[ $(hostname) == "Minastir" ]]; then
    echo "--- Menyiapkan MINASTIR (DNS Forwarder) ---"
    apt-get update && apt-get install -y bind9 nano dnsutils
    
    # named.conf.options
    cat > /etc/bind/named.conf.options << EOF
options {
    directory "/var/cache/bind";
    forwarders { 192.168.122.1; };
    recursion yes;
    allow-query { any; };
};
EOF
    
    # named.conf.local (Controls)
    cat > /etc/bind/named.conf.local << EOF
include "/etc/bind/rndc.key";
controls {
    inet 127.0.0.1 port 953
    allow { 127.0.0.1; } keys { "rndc-key"; };
};
EOF
    
    # Fix Permissions & Start Service
    chown bind:bind /etc/bind/rndc.key && chmod 600 /etc/bind/rndc.key
    named -u bind
    echo "Minastir Forwarder AKTIF."

# --- BAGIAN ALDARION (MIGRASI DHCP) ---
elif [[ $(hostname) == "Aldarion" ]]; then
    echo "--- Migrasi DNS Aldarion (DHCP) ---"
    # Mengganti semua 192.168.122.1 dengan Minastir (192.228.5.2) di dhcpd.conf
    sed -i 's/192.168.122.1;/'$DNS1';/g' /etc/dhcp/dhcpd.conf
    service isc-dhcp-server restart
    echo "DHCP Server Diperbarui."

# --- BAGIAN NODE STATIS LAIN (MIGRASI INTERFACES) ---
elif [ "$(hostname)" != "Durin" ]; then
    echo "--- Migrasi DNS Statis: $(hostname) ---"
    
    # 1. Update Permanen di interfaces
    sed -i 's/dns-nameservers 192.168.122.1/dns-nameservers '$DNS1'/' /etc/network/interfaces

    # 2. Update Langsung di resolv.conf (tanpa reboot)
    echo "nameserver $DNS1" > /etc/resolv.conf
    echo "DNS statis berhasil diperbarui."
fi