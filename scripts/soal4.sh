# Erendis

apt -y install bind9

cat >> /etc/bind/named.conf.local << EOF
zone "K34.com" {
  type master;
  file "/etc/bind/zones/db.K34.com";
  allow-transfer { 192.228.3.3; };   # Amdir
};

zone "3.228.192.in-addr.arpa" {
  type master;
  file "/etc/bind/zones/db.192.228.3";
  allow-transfer { 192.228.3.3; };
};
EOF

mkdir -p /etc/bind/zones

cat >> /etc/bind/zones/db.K34.com << EOF
$TTL 86400
@   IN SOA ns1.K34.com. admin.K34.com. (20251102 7200 3600 1209600 86400)
    IN NS  ns1.K34.com.
    IN NS  ns2.K34.com.
ns1 IN A   192.228.3.2      ; Erendis
ns2 IN A   192.228.3.3      ; Amdir

; A records penting
palantir   IN A 192.228.4.3
narvi      IN A 192.228.4.4
elros      IN A 192.228.1.6
pharazon   IN A 192.228.2.7
elendil    IN A 192.228.1.2
isildur    IN A 192.228.1.3
anarion    IN A 192.228.1.4
galadriel  IN A 192.228.2.2
celeborn   IN A 192.228.2.3
oropher    IN A 192.228.2.4
miriel     IN A 192.228.1.5
celebrimbor IN A 192.228.2.5

; alias
www  IN CNAME K34.com.

; TXT rahasia
"CinRing" IN TXT "Cincin Sauron -> elros.K34.com"
"Alliance" IN TXT "Aliansi Terakhir -> pharazon.K34.com"
EOF

cat >> /etc/bind/zones/db.192.228.3 << EOF
$TTL 86400
@ IN SOA ns1.K34.com. admin.K34.com. (1 7200 3600 1209600 86400)
  IN NS  ns1.K34.com.
  IN NS  ns2.K34.com.

2 IN PTR ns1.K34.com.
3 IN PTR ns2.K34.com.
EOF

mkdir -p /var/cache/bind
touch /var/log/named.log
chown -R bind:bind /var/cache/bind /var/log/named.log

cat >> /etc/bind/named.conf << EOF
include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
include "/etc/bind/named.conf.root-hints";

logging {
  channel default_file {
    file "/var/log/named.log" versions 3 size 5m;
    severity info;
    print-time yes;
  };
  category default { default_file; };
};
EOF

/usr/sbin/named -4 -u bind -c /etc/bind/named.conf -g

# Amdir

apt update
apt -y install bind9 bind9-utils bind9-dnsutils || true

# (image minimal tanpa service) siapkan dirs:
mkdir -p /var/cache/bind /var/log
touch /var/log/named.log
chown -R bind:bind /var/cache/bind /var/log/named.log

cat >> /etc/bind/named.conf.local << EOF
zone "K34.com" {
    type slave;
    masters { 192.228.3.2; };          // Erendis
    file "/var/cache/bind/db.K34.com";
};

zone "3.228.192.in-addr.arpa" {
    type slave;
    masters { 192.228.3.2; };
    file "/var/cache/bind/db.192.228.3";
};
EOF


cat >> /etc/bind/named.conf.options << EOF
options {
    directory "/var/cache/bind";

    listen-on { any; };
    // listen-on-v6 { any; };

    allow-query { any; };

    // Amdir sebagai SLAVE authoritative saja:
    recursion no;

    // (opsional) kalau mau bisa resolve internet juga:
    // recursion yes;
    // forwarders { 192.228.5.2; };  // Minastir
};
EOF

mkdir -p /var/cache/bind /var/log
touch /var/log/named.log
chown -R bind:bind /var/cache/bind /var/log/named.log

/usr/sbin/named -4 -u bind -c /etc/bind/named.conf -g

# semua node non-Durin
echo -e "nameserver 192.228.5.2 \nnameserver 192.228.3.2" > /etc/resolv.conf
