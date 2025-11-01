# Durin config

sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

apt -y install isc-dhcp-relayi


cat > /etc/default/isc-dhcp-relay << EOF
SERVERS="192.228.4.2"          # IP Aldarion
INTERFACES="eth2 eth3 eth1"  # antarmuka ke subnet 1,2,3 (sesuaikan)
OPTIONS=""
EOF

service isc-dhcp-relay restart

# Aldarion

apt -y install isc-dhcp-server

cat > /etc/default/isc-dhcp-server << EOF
INTERFACESv4="eth0"
EOF

cat > /etc/dhcp/dhcpd.conf << EOF
authoritative;
default-lease-time 1800;  # fallback 30m
max-lease-time 3600;      # 1h batas maksimal

# Subnet Manusia: 192.228.1.0/24
subnet 192.228.1.0 netmask 255.255.255.0 {
  option routers 192.228.1.1;
  option domain-name "K34.com";
  option domain-name-servers 192.228.5.2;
  range 192.228.1.6 192.228.1.34;
  range 192.228.1.68 192.228.1.94;
  default-lease-time 1800;   # 30 menit (Manusia)
}

# Subnet Peri: 192.228.2.0/24
subnet 192.228.2.0 netmask 255.255.255.0 {
  option routers 192.228.2.1;
  option domain-name "K34.com";
  option domain-name-servers 192.228.5.2;
  range 192.228.2.35 192.228.2.67;
  range 192.228.2.96 192.228.2.121;
  default-lease-time 600;    # 10 menit (Peri)
}

# Subnet Fixed/Server: 192.228.3.0/24
subnet 192.228.3.0 netmask 255.255.255.0 {
  option routers 192.228.3.1;
  option domain-name "K34.com";
  option domain-name-servers 192.228.5.2;
}

host khamul {
  hardware ethernet 02:42:b8:2d:50:00;   # MAC Khamul
  fixed-address 192.228.3.95;
}

subnet 192.228.4.0 netmask 255.255.255.0 {
  option routers 192.228.4.1;
  option domain-name "K34.com";
  # tidak ada 'range' karena klien tidak direct di sini (pakai relay)
}
EOF

service isc-dhcp-server restart
