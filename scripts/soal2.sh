#!/bin/bash
# FILE: soal2.sh (Dijalankan di Aldarion & Durin)

# --- BAGIAN ALDARION (DHCP SERVER) ---
# Jalankan ini di Aldarion
if [[ $(hostname) == "Aldarion" ]]; then
    echo "--- Menyiapkan ALDARION (DHCP Server) ---"
    
    # Konfigurasi Interface Server
    echo 'INTERFACESv4="eth0"' > /etc/default/isc-dhcp-server
    echo 'INTERFACESv6=""' >> /etc/default/isc-dhcp-server
    
    # Konfigurasi dhcpd.conf (PREFIX 192.228)
    # MAC Khamul: 02:42:b8:2d:50:00
    cat > /etc/dhcp/dhcpd.conf << EOF
authoritative;
option domain-name-servers 192.168.122.1;

# Manusia (Jaringan 1)
subnet 192.228.1.0 netmask 255.255.255.0 {
    range 192.228.1.6 192.228.1.34;
    range 192.228.1.68 192.228.1.94;
    option routers 192.228.1.1;
    option broadcast-address 192.228.1.255;
    option domain-name-servers 192.168.122.1;
    default-lease-time 1800;
    max-lease-time 3600;
}

# Peri (Jaringan 2)
subnet 192.228.2.0 netmask 255.255.255.0 {
    range 192.228.2.35 192.228.2.67;
    range 192.228.2.96 192.228.2.121;
    option routers 192.228.2.1;
    option broadcast-address 192.228.2.255;
    option domain-name-servers 192.168.122.1;
    default-lease-time 600;
    max-lease-time 3600;
}

# Fixed Address (Jaringan 3 - Khamul)
subnet 192.228.3.0 netmask 255.255.255.0 {
    option routers 192.228.3.1;
    option broadcast-address 192.228.3.255;
    option domain-name-servers 192.168.122.1;
}

# Aldarion (Jaringan 4 - Server)
subnet 192.228.4.0 netmask 255.255.255.0 {
    option routers 192.228.4.1;
    option broadcast-address 192.228.4.255;
    option domain-name-servers 192.168.122.1;
}

# Minastir (Jaringan 5)
subnet 192.228.5.0 netmask 255.255.255.0 {
}

# Host Khamul
host Khamul {
    hardware ethernet 02:42:b8:2d:50:00;
    fixed-address 192.228.3.95;
}
EOF

    # Restart Service
    service isc-dhcp-server restart
    echo "DHCP Server di Aldarion AKTIF."

# --- BAGIAN DURIN (DHCP RELAY) ---
elif [[ $(hostname) == "Durin" ]]; then
    echo "--- Menyiapkan DURIN (DHCP Relay) ---"
    
    # Konfigurasi Relay
    echo 'SERVERS="192.228.4.2"' > /etc/default/isc-dhcp-relay
    echo 'INTERFACES="eth1 eth2 eth3 eth4"' >> /etc/default/isc-dhcp-relay
    echo 'OPTIONS=""' >> /etc/default/isc-dhcp-relay
    
    # Restart Service
    service isc-dhcp-relay restart
    echo "DHCP Relay di Durin AKTIF."

else
    echo "Script ini hanya untuk Aldarion dan Durin. Mengabaikan."
fi