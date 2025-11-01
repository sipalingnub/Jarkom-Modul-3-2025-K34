# di semua node, jalanin ini selain Durin
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt update && apt -y install curl wget nano htop lynx nginx php8.4 php8.4-fpm php8.4-cli composer git mariadb-server apache2-utils
# Minastir v, Aldarion v, Erendis, Amdir v, Palantir v, Narvi v, Elros v, Pharazon v, Elendil, Isildur v, Anarion v, Galadriel v, Celeborn v, Oropher v, Miriel , Amandil, Gilgalad, Celebrimbor, Khamul

# Durin config
# Aktifkan Routing (IP Forwarding)
echo 'net.ipv4.ip_forward=1' > /etc/sysctl.conf
sysctl -p

# Konfigurasi NAT (Masquerade)
# Ini adalah NAT global yang mengizinkan semua jaringan internal ke internet
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 192.228.0.0/16

# Konfigurasi Forwarding Internal (Antar Jaringan)
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
