# Minastir
apt -y install unbound

cat >/etc/unbound/unbound.conf.d/forward.conf <<'EOF'
server:
  interface: 0.0.0.0
  access-control: 0.0.0.0/0 allow
forward-zone:
  name: "."
  forward-addr: 192.168.122.1    # meneruskan ke DNS ITS/Internet
EOF

service unbound restart

# Semua node kecuali Durin
echo "nameserver 192.228.5.2" > /etc/resolv.conf

# cek
ping -c3 192.228.5.2
