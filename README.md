# Jarkom Modul 3 2025 K34

| Nama                         | NRP        |
| ---------------------------- | ---------- |
| Paundra Pujo Darmawan        | 5027241008 |
| Muhammad Khairul Yahya       | 5027241092 |

**Prefix IP:** `192.228`

# Daftar Isi

1. [Topologi Jaringan](#1-topologi-jaringan)
2. [Konfigurasi Jaringan](#2-konfigurasi-jaringan)
3. [Walkthrough Pengerjaan Soal](#3-walkthrough-pengerjaan-soal)

- [Soal 1](#soal-1-jaringan-dasar-router--nat)
- [Soal 2 & 6](#soal-2--6-dhcp-server-relay--lease-time)
- [Soal 4 & 5](#soal-4--5-dns-master-slave-cname-txt-ptr)
- [Soal 7](#soal-7-instalasi-worker-laravel)
- [Soal 8, 9 & 10](#soal-8-9-10-database-nginx--load-balancer)
- [Soal 11](#Soal-11:-Benchmark-&-Strategi-Bertahan)
- [soal 12](#Soal-12:-Instalasi-Worker-PHP)
- [soal 13](#Soal-13:-Konfigurasi-Nginx-Worker-PHP)

4. [Troubleshooting & Kendala Utama](#4.-troubleshooting-&-Kendala-Utama)


# 1. Topologi Jaringan

Praktikum ini disimulasikan menggunakan GNS3 dengan topologi sebagai berikut. Jaringan ini terdiri dari 20 node (termasuk 1 router, 8 switch, dan 1 NAT) yang dibagi menjadi 5 Jaringan (Subnet) berbeda. Router utama (Durin) menghubungkan semua 5 subnet dan menyediakan akses ke internet (NAT).

[!image alt](https://github.com/sipalingnub/Jarkom-Modul-3-2025-K34/blob/1ee85db7c3f8d51d2b2e835f3dde45be10819e85/assets/Screenshot%202025-10-29%20020713.png)

# 2. Konfigurasi Jaringan

Berikut adalah skema alokasi IP Address statis dan dinamis (DHCP) yang digunakan untuk setiap node di 5 jaringan.

## Jaringan 1 (Gateway: `192.228.1.1`)

- **Elendil (Static):** `address 192.228.1.2`
- **Isildur (Static):** `address 192.228.1.3`
- **Anarion (Static):** `address 192.228.1.4`
- **Miriel (Static):** `address 192.228.1.5`
- **Elros (Static):** `address 192.228.1.6`
- **Amandil (Dynamic):** `iface eth0 inet dhcp`

## Jaringan 2 (Gateway: `192.228.2.1`)

- **Galadriel (Static):** `address 192.228.2.2`
- **Celeborn (Static):** `address 192.228.2.3`
- **Oropher (Static):** `address 192.228.2.4`
- **Celebrimbor (Static):** `address 192.228.2.5`
- **Pharazon (Static):** `address 192.228.2.7`
- **Gilgalad (Dynamic):** `iface eth0 inet dhcp`

## Jaringan 3 (Gateway: `192.228.3.1`)

- **Erendis (Static / DNS Master):** `address 192.228.3.2`
- **Amdir (Static / DNS Slave):** `address 192.228.3.3`
- **Khamul (Dynamic):** `iface eth0 inet dhcp`

## Jaringan 4 (Gateway: `192.228.4.1`)

- **Aldarion (Static / DHCP Server):** `address 192.228.4.2`
- **Palantir (Static / DB Master):** `address 192.228.4.3`
- **Narvi (Static / DB Slave):** `address 192.228.4.4`

## Jaringan 5 (Gateway: `192.228.5.1`)

- **Minastir (Static/ DNS Forwarder):** `address 192.228.5.2`

# 3. Walkthrough Pengerjaan Soal

Berikut adalah langkah-langkah pengerjaan untuk setiap soal, dari Soal 1 hingga 8, yang diselesaikan berdasarkan log dan script di repositori ini.

### Soal 1: Jaringan Dasar (Router & NAT)
* **Script:** [`soal1.sh`](./soal1.sh)
* Tugas ini adalah mengkonfigurasi `Durin` agar berfungsi sebagai router yang menyediakan koneksi internet (NAT) untuk semua node dan mengizinkan *forwarding* antar jaringan internal.

1. **Akses Internet Awal:** Memberi `Durin` IP statis sementara (`192.168.122.100`) dan default route (`192.168.122.1`) agar bisa menjalankan `apt update`.

2. **Instalasi Tools:** Menginstal tools penting seperti `isc-dhcp-relay`, `bind9-utils`, dan `net-tools`.

3. **IP Forwarding:** Mengaktifkan routing di kernel dengan mengedit `/etc/sysctl.conf` dan menambahkan `net.ipv4.ip_forward=1`, lalu menerapkannya dengan `sysctl -p`.

4. **Konfigurasi NAT:** Mengatur `iptables` agar semua jaringan internal (`192.228.0.0/16`) dapat "menumpang" (Masquerade) IP `eth0` `Durin` untuk mengakses internet.

5. **Forwarding Internal:** Menambahkan aturan `iptables -A FORWARD` untuk mengizinkan komunikasi antar semua interface internal (misal `eth1` ke `eth2`, `eth2` ke `eth4`, dst.) agar client bisa saling berkomunikasi.

6. **Simpan Aturan:** Membuat directory `/etc/iptables` dan menyimpan semua aturan firewall dengan `iptables-save > /etc/iptables/rules.v4`

### Soal 2 & 6: DHCP Server, Relay, & Lease Time
* **Script:** [`soal2.sh`](./soal2.sh) dan [`soal6.sh`](./soal6.sh)
* Tugas ini mengatur `Aldarion` sebagai DHCP Server dan `Durin` sebagai DHCP Relay. Soal 6 (Lease Time) sudah termasuk di dalam konfigurasi `dhcpd.conf` di `soal2.sh`.

#### 1. **Konfigurasi `Aldarion` (Server):**
- Menginstal `isc-dhcp-server`.
- Mengatur `INTERFACESv4="eth0"` di `/etc/default/isc-dhcp-server`.
- Mengkonfigurasi `/etc/dhcp/dhcpd.conf` dengan subnet untuk 5 jaringan.
- Menambahkan range dinamis untuk Jaringan 1 (Manusia) dan Jaringan 2 (Peri).
- Menambahkan `default-lease-time` (1800s untuk Jaringan 1, 600s untuk Jaringan 2) dan `max-lease-time` (3600s) sesuai Soal 6.
- Menambahkan host block untuk `Khamul` dengan fixed-address `192.228.3.95` berdasarkan MAC Address (`02:42:b8:2d:50:00`).
- Menjalankan service isc-dhcp-server restart

#### 2. **Konfigurasi `Durin` (Relay):**

- Menginstal `isc-dhcp-relay`.
- Mengatur `/etc/default/isc-dhcp-relay` dengan `SERVERS="192.228.4.2"` (IP Aldarion) dan `INTERFACES="eth1 eth2 eth3 eth4"` (Fix krusial: menyertakan interface ke server).
- Menjalankan `service isc-dhcp-relay restart`.

#### 3. **Verifikasi Client (`Amandil`, `Gilgalad`, `Khamul`):**

- Karena OS minimalis, `isc-dhcp-client` tidak terinstal. Dilakukan "Cara Curang": memberi IP manual sementara (misal: `ip addr add 192.228.1.50/24 dev eth0`), `apt install isc-dhcp-client`, lalu `ip addr flush dev eth0`, baru menjalankan `dhclient -v eth0`.
- Hasil verifikasi sukses: `Amandil` & `Gilgalad` mendapat IP range, dan `Khamul` mendapat IP fixed `192.228.3.95`.

### Soal 3: DNS Forwarder (Versi Revisi)
* **Script:** [`soal3.sh`](./soal3.sh)
* Tugas ini mengubah `Minastir` menjadi DNS Forwarder murni (menggunakan BIND9) dan memigrasikan seluruh jaringan untuk menggunakan `Minastir` sebagai DNS utama.

#### 1. **Konfigurasi `Minastir` (Forwarder):**

- Memastikan semua service (NAT & DHCP) dari Soal 1 & 2 running setelah restart massal.
- Menginstal `bind9` di `Minastir` (`192.228.5.2`).
- Mengkonfigurasi `named.conf.options` sebagai forwarder murni (`forwarders { 192.168.122.1; };)` dan `allow-query { any; };`.
- Mengaktifkan `rndc` di `named.conf.local` dan memperbaiki izin `rndc.key` (`chown bind:bind...`).
- Menjalankan service BIND9 (`named -u bind`) dan memverifikasi forwarding dengan `dig google.com @127.0.0.1`.

#### 2. **Migrasi DNS Jaringan:**

- Mengubah `dns-nameservers` di `/etc/network/interfaces` 16 node statis menjadi `192.228.5.2`.
- Mengubah `option domain-name-servers` di `dhcpd.conf` `Aldarion` menjadi `192.228.5.2` dan me-restart service. 
- Menjalankan `dhclient -r && dhclient -v eth0` di 3 node dinamis untuk mengambil DNS baru.

### Soal 4 & 5: DNS Master-Slave, CNAME, TXT, PTR
* **Script:** [`soal4.sh`](./soal4.sh) dan [`soal5.sh`](./soal5.sh)
* Tugas ini adalah membangun server DNS otoritatif `k34.com` (`Erendis` sebagai Master, `Amdir` sebagai Slave) dan menambahkan *records* lanjutan (CNAME, TXT, PTR).

#### 1. **Konfigurasi `Erendis` (Master `192.228.3.2`):**

- Menginstal `bind9`.
- Mengatur `named.conf.options` untuk forward ke `Minastir` (`192.228.5.2`). 
- Mengatur `named.conf.local` sebagai Master untuk zone `k34.com` dan reverse zone `3.228.192.in-addr.arpa` (Soal 5).
- Membuat file "peta" (`db.k34`), mengisi records `SOA`, `NS`, `A` (Soal 4) , serta `CNAME` (`www`) dan `TXT` (Pesan Rahasia) (Soal 5).
- Membuat file "peta terbalik" (`db.3.228.192`) dan mengisi records `PTR` untuk `Erendis` dan `Amdir` (Soal 5).
- Memperbaiki semua izin file (`chgrp bind...`, `chmod g+r...`) dan me-reload BIND9 (`rndc reload` / `kill` & `named -u bind`).

#### 2. **Konfigurasi `Amdir` (Slave `192.228.3.3`):**

- Menginstal `bind9`.
- Mengatur `named.conf.options` (forward ke `Minastir`). 
- Mengatur `named.conf.local` sebagai Slave untuk kedua zone (`k34.com` dan `3.228.192.in-addr.arpa`), menunjuk ke Master `192.228.3.2`.
- Memperbaiki izin folder slave (`chown -R bind:bind /var/lib/bind/`) dan me-restart BIND9.

#### 3. **Migrasi DNS FINAL:**

- Mengubah `dns-nameservers` di 16 node statis menjadi 3 server: `192.228.3.2`, `192.228.3.3`, `192.228.5.2`.
- Mengubah `option domain-name-servers` di `dhcpd.conf` `Aldarion` menjadi 3 server dan me-restart service.
- Menjalankan `dhclient -r && dhclient eth0` di 3 node dinamis.

### Soal 7: Instalasi Worker Laravel
* **Script:** [`soal7.sh`](./soal7.sh)
* Tugas ini adalah menyiapkan *stack* LEMP (Nginx, PHP 8.4, Composer) di 3 worker (`Elendil`, `Isildur`, `Anarion`) dan meng-kloning *repository* Laravel.

1. **Atur Proxy:** Karena internet diblokir (Soal 3 Proxy), `apt` dan `curl` diatur untuk menggunakan proxy `Minastir` (`192.228.5.2:3128`).

- **Catatan:** Langkah ini ada di log tetapi kontradiktif dengan Soal 3 Revisi. Langkah yang benar (menggunakan Soal 3 Revisi) adalah `apt` akan bekerja tanpa proxy.

2. **Instalasi PHP:** Menambahkan PPA `sury.org` dan menginstal `php8.4-fpm` (dan modulnya), `nginx`, dan `git`.

3. **Instalasi Composer:** Mengunduh `composer` menggunakan `curl | php ...`.

4. **Setup Proyek:** Menjalankan `git clone`, lalu `cd laravel-simple-rest-api`.

5. **Fix PHP 8.4:** Menjalankan `composer update` (bukan `install`) untuk mengatasi `composer.lock` yang tidak kompatibel.

6. **Selesai:** Menjalankan `cp .env.example .env` dan `php artisan key:generate`.

### Soal 8, 9, 10: Database, Nginx, & Load Balancer
* **Script:** [`soal8.sh`](./soal8.sh), [`soal9.sh`](./soal9.sh), [`soal10.sh`](./soal10.sh)
* Tugas ini menghubungkan 3 *worker* ke `Palantir` (MariaDB), mengkonfigurasi Nginx di *port* unik (`8001-8003`), dan membuat *Load Balancer* (Reverse Proxy) di `Elros`.

1. **`Palantir` (DB Server):** Menginstal `mariadb-server`, membuat `laravel_db` dan `laravel_user` (`password123`), dan mengubah `bind-address` menjadi `0.0.0.0` untuk koneksi remote.

2. **3 Worker (`.env`):** Menimpa file `.env` untuk terhubung ke `DB_HOST=192.228.4.3` (Palantir) dan menjalankan `php artisan key:generate` ulang.

3. **`Elendil` (Migrasi):** Menjalankan `php artisan migrate:fresh --seed` untuk membuat tabel di `Palantir`.

4. **3 Worker (Nginx):** Mengkonfigurasi Nginx (`sites-available`) untuk listen di port unik (`8001`, `8002`, `8003`) dan domain unik (`elendil.k34.com`, dll.).

5. **`Elros` (Reverse Proxy):** Menginstal Nginx dan mengkonfigurasi `upstream kesatria_numenor` (berisi 3 IP Worker) dan `proxy_pass` ke upstream tersebut (Round Robin) untuk domain `elros.k34.com`.

6. **Verifikasi (`Miriel`):** Menginstal `lynx` dan `curl`, lalu mengakses `http://elros.k34.com/api/animes` (Tes Soal 10) dan `http://elendil.k34.com:8001/api/animes` (Tes Soal 9).

### Soal 11: Benchmark & Strategi Bertahan
* **Script:** [`soal11.sh`](./soal11.sh)

**Tujuan:** Menguji Load Balancer `Elros` dengan `ab` (ApacheBenchmark) dan menerapkan strategi bertahan (`weight`).

**1. Di Node Client (misal: `Miriel`) - Serangan Awal**

Kita butuh tool `ab` (ApacheBenchmark), yang ada di paket `apache2-utils`.

1. Pindah ke konsol `Miriel`.
2. Jalankan script `soal11.sh` .Script ini "pintar" dan akan mendeteksi dia bukan Elros, jadi dia akan masuk ke mode "Penyerang".
3. **Output Harapan:**
- `apt-get install apache2-utils` akan berjalan.
- Kamu akan melihat hasil benchmark pertama (`-n 100`).
- Kamu akan melihat hasil benchmark kedua (`-n 2000`).
- Perhatikan: Angka `Failed requests` (harus 0) dan `Requests per second`.

**2. Di Node `Elros` - Strategi Bertahan**

Sekarang, kita terapkan fix di Load Balancer.

1. Pindah ke konsol `Elros`.
2. Jalankan script `soal11.sh`. Script ini akan mendeteksi dia adalah `Elros`, jadi dia akan masuk ke mode "Bertahan".
3. **Output Harapan:**
- Script akan menimpa file `/etc/nginx/sites-available/elros-lb` dengan konfigurasi baru (menambahkan `weight=3` ke `Elendil`).
- `nginx -t` akan sukses.
- `service nginx restart` akan berjalan.

**3. Di Node Client (`Miriel`) - Serangan Kedua**

1. Kembali ke konsol `Miriel`.
2. Jalankan script `soal11.sh` LAGI.
3. **Verifikasi:** Bandingkan `Requests per second` (RPS) yang baru dengan yang lama. Karena `Elendil` (mungkin) lebih kuat atau kita sebar traffic-nya dengan lebih baik, angkanya bisa jadi lebih tinggi (lebih baik).

### Soal 12: Instalasi Worker PHP
* **Script:** [`soal12.sh`](./soal12.sh)

**Tujuan:** Menyiapkan file di 3 worker baru (`Galadriel`, `Celeborn`, `Oropher`).

1. Pindah ke konsol `Galadriel`.
2. Jalankan script `soal12.sh`:
3. Pindah ke konsol `Celeborn`.
4. Jalankan script `soal12.sh`.
5. Pindah ke konsol `Oropher`.
6. Jalankan script `soal12.sh`
7. Verifikasi (di `Galadriel`):

- `ls /var/www/html/index.php` (Pastikan file `index.php` ada).
- `cat /var/www/html/index.php` (Pastikan isinya `Hello from Galadriel`).
- `service php8.4-fpm status` (Pastikan running).

### Soal 13: Konfigurasi Nginx Worker PHP
* **Script:** [`soal13.sh`](./soal13.sh)

**Tujuan:** Menyalankan Nginx di 3 worker PHP di port unik (`8004`, `8005`, `8006`).

1. Pindah ke konsol `Galadriel`.
2. Jalankan script `soal13.sh`.
3. Pindah ke konsol `Celeborn`.
4. Jalankan script `soal13.sh`.
5. Pindah ke konsol `Oropher`.
6. Jalankan script `soal13.sh`.

### **Verifikasi Final (di Client `Miriel`)**

ini adalah tes terakhir untuk membuktikan Soal 12 & 13 Berhasil

1. Pindah ke konsol `Miriel`.

2. **Tes Akses via DOMAIN (Harus Berhasil):** 

```bash
lynx http://galadriel.k34.com:8004
lynx http://celeborn.k34.com:8005
lynx http://oropher.k34.com:8006
```
- **Output Harapan:** `lynx` akan menampilkan `Hello from Galadriel`, `Hello from Celeborn`, dst. (Tekan `q` untuk keluar).

3. **Tes Akses via IP (Harus Gagal):** Sesuai soal ("hanya bisa melalui domain nama"), Nginx server block kita di-setting untuk hanya merespons nama domain, bukan IP.

```bash
lynx http://192.228.2.2:8004
```

- **Output Harapan:** Gagal (misal: `404 Not Found` atau `Alert! Unable to connect`).


# 4. Troubleshooting & Kendala Utama

Selama pengerjaan, ditemukan berbagai kendala yang disebabkan oleh sifat OS Debian minimalis:

1. **OS "Telanjang":** Service kritis seperti `isc-dhcp-client` tidak terinstal secara default. Ini memaksa dilakukannya "Cara Curang" (memberi IP manual sementara) hanya untuk bisa menginstal `dhclient`.

2. **Service Tidak Autostart:** Kendala terbesar. Setiap kali node di-restart (baik sengaja atau tidak), semua service yang diinstal manual (`isc-dhcp-server`, `isc-dhcp-relay`, `named`, `squid`, `mariadb`) **MATI**. Ini mengharuskan service di-start ulang secara manual (`service ... start` atau `named -u bind`).

3. **BIND9 `SERVFAIL` / `NXDOMAIN`:** Ini adalah troubleshooting paling sulit (Soal 4). `SERVFAIL` (kegagalan server) dan `NXDOMAIN` (domain tidak ditemukan) terjadi berulang kali. Solusinya adalah chain perbaikan izin yang spesifik:

- Memastikan `named.conf.local` (file config) dapat dibaca oleh `bind`.
- Memastikan `db.k34` (file peta) bukanlah folder (yang terjadi karena typo `rmdir`).
- Memastikan `db.k34` (file peta) dapat dibaca oleh `bind` (`chgrp bind` dan `chmod g+r`).
- Memastikan `Amdir `(Slave) punya izin tulis ke `/var/lib/bind/` (`chown -R bind:bind`).

4. **Nginx/Laravel 404 `File not found:`** Setelah semua jaringan (DNS, Nginx, PHP-FPM) terbukti jalan, Laravel tetap mengembalikan 404. Ini dipecahkan dengan 3 langkah:

- Menjalankan `php artisan migrate:fresh --seed` (untuk membuat route `/api/animes`).
Menjalankan `chown -R www-data:www-data` (agar PHP punya izin baca file proyek).
- Memperbaiki path di `fastcgi_param SCRIPT_FILENAME` (dari `$realpath_root` ke `$document_root`).

