# Changelog — Perbaikan Bug & Stabilitas

## Farming
- Menghilangkan pakan gratis yang sebelumnya otomatis diberikan setiap kali bibit ditebar.
- Pertumbuhan hanya berjalan jika ikan dan waktu pakan tersedia.
- Sisa waktu pakan disimpan dalam detik dan kompatibel dengan save lama yang hanya memiliki `feed_count`.
- Data kolam divalidasi agar jumlah ikan, progres, dan status siap panen tetap konsisten.
- Pakan berlebih tidak lagi terbuang saat panen; waktu pertumbuhan yang dibutuhkan saja yang dikonsumsi.
- Interaksi tidak memaksa menambah pakan ketika sisa pakan masih mencukupi.

## Player & Combat
- Pemain berhenti bergerak saat HP mencapai nol.
- Pemain tidak dapat menerima damage berulang selama kondisi kalah.
- Respawn menggunakan fungsi khusus yang memulihkan HP, posisi, dan status pemain secara konsisten.
- Input interaksi/serangan diabaikan ketika pemain sedang kalah.

## Save & Progression
- Save versi 3 memvalidasi struktur JSON dan inventory sebelum dipakai.
- Jika save utama rusak, sistem mencoba membaca backup.
- Job Level dihitung ulang dari Farm Value saat memuat save.
- Save dipanggil saat aplikasi mobile dijeda, selain autosave dan penutupan jendela.

## Verifikasi
- Pemeriksaan statis dan pemeriksaan isi paket dilakukan.
- Pengujian runtime Godot belum dapat dilakukan pada lingkungan pembuatan paket.

## Inventory System Update
- InventoryManager memuat katalog item, memvalidasi item, menerapkan batas 30 slot dan batas stack.
- Inventory UI dapat dibuka dengan tombol I, ditutup dengan Escape/tombol TUTUP, serta memiliki tombol TAS untuk layar sentuh.
- Item dengan harga jual dapat dijual satu per satu dan menambah Money.
- Ikan hasil panen masuk inventory sebagai Ikan Basic.
- Panen sekarang memeriksa kapasitas inventory terlebih dahulu; bila penuh, hasil ikan tidak hilang dan proses panen ditolak.
- Katalog menambahkan Ikan Basic dengan harga jual uji 25 Money.

## Shop System Update
- Menambahkan panel toko yang dapat dibuka dengan B atau tombol TOKO di layar sentuh.
- Toko menjual Bibit Basic (75 Money) dan Pakan Basic (10 Money).
- Menambahkan validasi saldo, kapasitas slot, dan batas stack sebelum transaksi.
- Menambahkan penjualan item satuan dari panel inventory.
- Memperbaiki urutan panen: inventory harus menerima ikan sebelum data kolam dikosongkan.


## Pemeriksaan Bug Tambahan
- Memperbaiki pemuatan inventory dari save: ID item yang tidak ada di katalog dibuang, jumlah item dibatasi sesuai stack, dan jumlah slot tetap tervalidasi.
- Data save dengan nilai jumlah item non-numerik diabaikan agar tidak merusak proses load.
- Penyegaran daftar inventory kini menghapus node lama secara langsung sebelum membuat daftar baru, mencegah baris UI menumpuk pada beberapa refresh dalam satu frame.


## NPC System — perbaikan dan fondasi
- Memperbaiki baris resource NPC pada `scenes/main.tscn` yang sebelumnya tersimpan sebagai teks `\
` literal dan dapat merusak parsing scene.
- Menambahkan sprite Pedagang dan Ahli Breeding yang sebelumnya direferensikan scene tetapi belum tersedia.
- NPC masuk ke group `npcs` dan dapat dikenali melalui `npc_id`.
- Menambahkan interaksi jarak dekat: E pertama menampilkan dialog, E kedua pada Pedagang membuka toko.
- Interaksi NPC diprioritaskan dari interaksi kolam untuk menghindari salah aksi.
- Ahli Breeding saat ini hanya dialog/fondasi; proses breeding belum aktif.


## Breeding System Update
- Menambahkan `BreedingManager` sebagai autoload khusus transaksi breeding.
- Menambahkan empat tier bibit baru ke katalog item.
- Menambahkan panel breeding di UI; Ahli Breeding membuka panel setelah interaksi kedua.
- Menetapkan biaya dan peluang sesuai rancangan: Basic→Advanced 100/90%, Advanced→Rare 250/75%, Rare→Epic 500/60%, Epic→Legendary 1.000/40%.
- Saat gagal, satu bibit dikembalikan dan 50% biaya dikembalikan.
- Menambahkan pemeriksaan saldo, jumlah bibit, kapasitas slot, dan stack hasil sebelum transaksi.
- Menambahkan rollback jika penambahan hasil breeding gagal.


## Audit & Bugfix — Loot dan Pakan
- Menambahkan LootManager sebagai Peti Loot permanen.
- Memperbaiki loot Slime yang sebelumnya bisa hilang saat inventory penuh.
- Loot overflow disimpan ke save game dan dapat diklaim sebagian melalui Inventory.
- Pakan tidak bisa dihabiskan pada kolam kosong atau kolam yang sudah siap panen.
- Menormalkan batas minimum/maksimum jumlah material drop Slime.


## Sistem Lahan & Properti
- Menambahkan PropertyManager dan katalog lahan JSON.
- Menambahkan NPC Pengelola Lahan.
- Menambahkan fungsi sewa 7 hari, pembelian permanen, syarat Job Level, dan perpindahan lokasi.
- NPC bergerak membawa gerobak saat relokasi; status lahan dan lokasi aktif tersimpan.
- Mempertahankan Peti Loot dan seluruh fitur versi sebelumnya.
- Harga dan durasi adalah nilai prototipe sementara untuk pengujian keseimbangan.


## Audit Bug — Respawn dan Data Properti
- Respawn setelah pemain kalah kini memakai koordinat spawn dari lahan yang sedang aktif, termasuk setelah relokasi.
- Data record lahan saat load disanitasi: status hanya menerima `locked`, `rented`, atau `owned`; waktu sewa dibatasi agar tidak negatif; record yang rusak dikembalikan ke nilai aman.

## Quest & Mission System
- Menambahkan `QuestManager` sebagai autoload.
- Menambahkan tiga misi awal: Panen Pertama, Pemburu Slime, dan Pengumpul Gel.
- Progres misi terhubung ke event panen, kematian Slime, dan penambahan item ke inventory.
- Hadiah Money hanya bisa diklaim satu kali.
- Status progres, penyelesaian, dan klaim hadiah disimpan bersama save game.
- Menambahkan NPC Papan Misi dan panel daftar misi.
- Akses PC melalui tombol Q; layar sentuh melalui tombol MISI.

- Slime kini muncul kembali 5 detik setelah dikalahkan sehingga misi berburu tidak terhenti setelah monster pertama mati.
