#!/bin/bash
# FILE: soal1.sh (Dijalankan di Durin)

# 1. Konfigurasi Jaringan Permanen (WAJIB DIBUAT DULU DI GNS3 EDIT CONFIG)
# Pastikan /etc/network/interfaces sudah benar di semua 20 node (PREFIX 192.228)

# 2. Instalasi Tools & Fix Startup
apt update
apt install nano isc-dhcp-client isc-dhcp-relay net-tools bind9-utils

# 3. Aktifkan Routing (IP Forwarding)
echo 'net.ipv4.ip_forward=1' > /etc/sysctl.conf
sysctl -p

# 4. Konfigurasi NAT (Masquerade)
# Ini adalah NAT global yang mengizinkan semua jaringan internal ke internet
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 192.228.0.0/16

# 5. Konfigurasi Forwarding Internal (Antar Jaringan)
# Ini penting agar Minastir bisa bicara dengan Aldarion, dll.
iptables -A FORWARD -i eth1 -o eth2 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth1 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth3 -j ACCEPT
iptables -A FORWARD -i eth3 -o eth1 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth3 -j ACCEPT
iptables -A FORWARD -i eth3 -o eth2 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth4 -j ACCEPT
iptables -A FORWARD -i eth4 -o eth1 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth5 -j ACCEPT
iptables -A FORWARD -i eth5 -o eth1 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth4 -j ACCEPT
iptables -A FORWARD -i eth4 -o eth2 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth5 -j ACCEPT
iptables -A FORWARD -i eth5 -o eth2 -j ACCEPT
iptables -A FORWARD -i eth3 -o eth4 -j ACCEPT
iptables -A FORWARD -i eth4 -o eth3 -j ACCEPT
iptables -A FORWARD -i eth3 -o eth5 -j ACCEPT
iptables -A FORWARD -i eth5 -o eth3 -j ACCEPT
iptables -A FORWARD -i eth4 -o eth5 -j ACCEPT
iptables -A FORWARD -i eth5 -o eth4 -j ACCEPT

# 6. Simpan Aturan Firewall & Buat Folder
mkdir -p /etc/iptables
iptables-save > /etc/iptables/rules.v4
