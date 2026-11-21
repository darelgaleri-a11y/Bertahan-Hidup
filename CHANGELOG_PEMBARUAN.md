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

\n## Pemeriksaan Bug Tambahan\n- Memperbaiki pemuatan inventory dari save: ID item yang tidak ada di katalog dibuang, jumlah item dibatasi sesuai stack, dan jumlah slot tetap tervalidasi.\n- Data save dengan nilai jumlah item non-numerik diabaikan agar tidak merusak proses load.\n- Penyegaran daftar inventory kini menghapus node lama secara langsung sebelum membuat daftar baru, mencegah baris UI menumpuk pada beberapa refresh dalam satu frame.\n

## NPC System — perbaikan dan fondasi
- Memperbaiki baris resource NPC pada `scenes/main.tscn` yang sebelumnya tersimpan sebagai teks `\\n` literal dan dapat merusak parsing scene.
- Menambahkan sprite Pedagang dan Ahli Breeding yang sebelumnya direferensikan scene tetapi belum tersedia.
- NPC masuk ke group `npcs` dan dapat dikenali melalui `npc_id`.
- Menambahkan interaksi jarak dekat: E pertama menampilkan dialog, E kedua pada Pedagang membuka toko.
- Interaksi NPC diprioritaskan dari interaksi kolam untuk menghindari salah aksi.
- Ahli Breeding saat ini hanya dialog/fondasi; proses breeding belum aktif.
