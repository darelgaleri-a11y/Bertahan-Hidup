# Bertahan Hidup — Quest & Bugfix Update

Proyek game Godot 4.x, 2D top-down, gaya Detailed Pixel Art dengan tile dasar 16×16.

## Fitur dalam paket
- Player movement, kontrol keyboard dan tombol sentuh dasar.
- HUD HP, Money, Job Level, Farm Value, dan status kolam.
- Sistem kolam: bibit, pakan, pertumbuhan, panen, dan perhitungan offline.
- Save/load JSON dengan backup.
- Slime AI, combat, material loot, dan peluang drop bibit.
- Inventory: 30 slot, stack 99, daftar item, dan penjualan satuan.
- Shop: pembelian Bibit Basic dan Pakan Basic.
- Proteksi transaksi: uang hanya dipotong setelah validasi kapasitas dan item.
- Proteksi panen: hasil ikan masuk inventory terlebih dahulu; kolam tidak dikosongkan jika inventory tidak mampu menampung.

## Menjalankan
1. Ekstrak ZIP.
2. Buka Godot 4.3 atau Godot 4.x yang kompatibel.
3. Project Manager → Import.
4. Pilih `project.godot` di folder `Bertahan_Hidup_Godot`.
5. Tunggu import, lalu tekan F5.

## Kontrol
- WASD / panah: bergerak.
- E: interaksi kolam (dekat kolam).
- J / Space: serang Slime.
- I: buka/tutup inventory.
- B: buka/tutup toko.
- Escape: tutup panel yang sedang terbuka.
- Android: tombol TAS dan TOKO serta kontrol sentuh gerakan/interaksi/serang.

## Hasil yang diharapkan
- Tekan B, toko tampil dengan Bibit Basic (75 Money) dan Pakan Basic (10 Money).
- Membeli item mengurangi Money dan menambah jumlah item.
- Pembelian gagal tanpa mengurangi Money jika uang kurang atau inventory penuh.
- Tekan I untuk melihat item; tombol Jual menjual satu item dan menambah Money.
- Panen menambahkan Ikan Basic ke inventory; jika gagal ditampung, ikan tetap di kolam.
- Save otomatis tetap menyimpan uang, inventory, dan kondisi kolam.

## Checklist perkembangan
- [x] Struktur proyek dan asset dasar pixel art.
- [x] Gerakan pemain dan kontrol sentuh dasar.
- [x] HUD dan status HP.
- [x] Kolam, pakan, pertumbuhan, panen, Farm Value.
- [x] Save/load dan backup.
- [x] Slime AI, combat, loot material dan peluang bibit.
- [x] Inventory UI, kapasitas slot, stack, jumlah item.
- [x] Penjualan item dari inventory.
- [x] Shop pembelian Bibit Basic dan Pakan Basic.
- [ ] Pengujian runtime Godot dan Android.
- [ ] NPC toko fisik, breeding, quest, equipment, skills.
- [ ] Dunia desa/hutan/gua lengkap, audio, tutorial, UI final.
- [ ] Build APK dan uji performa perangkat.

## Batas verifikasi
Paket diperiksa secara statis (JSON, referensi scene, integritas ZIP). Godot tidak tersedia di lingkungan pembuatan paket ini, sehingga belum ada klaim bahwa parser/runtime Godot atau perangkat Android sudah lulus pengujian. Nilai harga toko merupakan nilai uji awal.


## Pembaruan NPC System
- Penduduk Pedagang dan Ahli Breeding sekarang muncul di area desa.
- Dekati NPC lalu tekan **E** untuk membaca dialog.
- Tekan **E** sekali lagi saat masih dekat Pedagang untuk membuka toko.
- Ahli Breeding memberikan informasi bahwa sistem breeding belum aktif.
- Interaksi NPC diprioritaskan daripada kolam agar tombol E tidak salah menjalankan aksi.
- Sprite NPC pixel-art 32×32 disimpan di `assets/sprites/npcs/`.

Catatan: fitur breeding sebenarnya, transaksi melalui dialog pilihan, dan sistem jadwal/pergerakan NPC belum dibuat pada tahap ini.


## Breeding System Update
- Ahli Breeding kini membuka panel breeding saat tombol E ditekan dua kali ketika pemain berada di dekatnya.
- Resep: 2 Basic → Advanced (100 Money, 90%); 2 Advanced → Rare (250 Money, 75%); 2 Rare → Epic (500 Money, 60%); 2 Epic → Legendary (1.000 Money, 40%).
- Jika gagal: satu bibit dikembalikan, satu bibit hilang, dan 50% biaya dikembalikan.
- Pemeriksaan inventory dan saldo dilakukan sebelum transaksi.
- Katalog sudah memuat bibit Advanced, Rare, Epic, dan Legendary.
- Proses breeding dipisahkan ke `BreedingManager` agar mudah diuji dan dikembangkan.


## Checklist perkembangan terbaru
- [x] Struktur proyek Godot 4.x dan aset dasar Detailed Pixel Art.
- [x] Player movement, input keyboard, dan kontrol sentuh dasar.
- [x] HUD, HP, respawn, dan combat dasar.
- [x] Kolam ikan, bibit, pakan, pertumbuhan offline, dan panen.
- [x] Farm Value dan Job Level dasar.
- [x] Save/load JSON, backup, dan validasi inventory.
- [x] Slime AI, serangan, loot material, dan peluang drop bibit.
- [x] Inventory 30 slot, stack, penjualan item, dan toko.
- [x] NPC Pedagang dan Ahli Breeding, dialog, serta interaksi jarak dekat.
- [x] Breeding Basic→Advanced→Rare→Epic→Legendary dengan biaya dan peluang.
- [ ] Pengujian runtime menyeluruh di Godot 4.x.
- [ ] Pengujian perangkat Android dan kontrol layar sentuh.
- [ ] NPC desa tambahan, jadwal/pergerakan NPC, dan sistem relokasi barang NPC.
- [ ] Sewa/pembelian lahan dan sistem perpindahan tempat tinggal.
- [ ] Quest, equipment, statistik karakter, dan skill.
- [ ] Monster tambahan, hutan, gua, dan Danger Zone.
- [ ] Audio final, tutorial, polish UI, optimasi, dan build APK.

## Catatan pengujian
File JSON, referensi resource `res://`, dan integritas ZIP diperiksa secara otomatis. Godot executable tidak tersedia di lingkungan pembuatan paket ini, sehingga parsing scene/script dan pengujian runtime belum dapat dikonfirmasi. Peluang breeding memakai RNG saat permainan berjalan; hasil tiap percobaan dapat berbeda.


## Perbaikan audit kode — Peti Loot
- Loot monster yang tidak muat di inventory otomatis masuk Peti Loot.
- Peti Loot tersimpan di save game dan dapat diambil melalui tombol **AMBIL LOOT** pada panel Inventory.
- Pengambilan loot bersifat parsial; sisa item tetap tersimpan jika inventory masih penuh.
- Pakan tidak dapat digunakan pada kolam kosong atau kolam yang sudah siap panen.


## Sistem Lahan & Properti (prototipe)
- NPC Pengelola Lahan mengelola sewa, pembelian, dan perpindahan lahan.
- Lahan Desa tersedia sejak awal sebagai sewa pengenalan selama 7 hari.
- Lahan Hutan memerlukan Job Level 1; Lahan Tepi Danau memerlukan Job Level 3.
- Menyewa lahan memberi akses 7 hari; membeli lahan memberi kepemilikan permanen.
- Saat pindah, NPC berjalan membawa gerobak barang menuju lokasi baru. Data kolam tetap dipertahankan.
- Status lahan, kepemilikan, masa sewa, dan lokasi aktif disimpan dalam save game.
- Harga prototipe masih sementara: Desa 150/5.000, Hutan 250/12.000, Tepi Danau 600/25.000 (sewa/beli).


## Quest & Mission System Update
- Menambahkan Papan Misi di area desa. Dekati lalu tekan **E** dua kali untuk membuka misi.
- Tombol **Q** juga membuka/menutup daftar misi di PC; tombol **MISI** tersedia pada layar sentuh.
- Misi awal: Panen Pertama (1 kali panen), Pemburu Slime (3 Slime), dan Pengumpul Gel (5 Slime Gel). Slime muncul kembali 5 detik setelah dikalahkan agar misi berburu bisa diselesaikan.
- Hadiah: 100, 150, dan 125 Money. Hadiah hanya bisa diklaim satu kali.
- Progres misi dan status hadiah disimpan dalam save game.
- Misi diperbarui otomatis ketika panen, Slime dikalahkan, atau Slime Gel masuk ke inventory.

## Audit bug dan perbaikan tambahan
- Memperbaiki titik respawn: setelah pemain pindah lahan, kekalahan/respawn kini mengembalikan pemain ke titik spawn lahan aktif, bukan koordinat awal desa.
- Memperkuat pemuatan data properti agar record lahan yang rusak/tidak sesuai format tidak langsung dipakai sebagai data status.
- Mempertahankan perbaikan sebelumnya untuk Peti Loot, transaksi breeding, inventory, dan validasi pakan.

## Cara menguji fitur terbaru
1. Jalankan game, dekati Papan Misi di area desa, lalu tekan **E** dua kali (atau tekan **Q**).
2. Selesaikan misi panen dengan memasukkan bibit, memberi pakan, menunggu pertumbuhan, lalu panen.
3. Kalahkan Slime sebanyak 3 kali untuk misi Pemburu Slime.
4. Kumpulkan Slime Gel hingga 5 unit untuk misi Pengumpul Gel. Jika inventory penuh, ambil dulu item dari Peti Loot.
5. Buka Papan Misi dan tekan **AMBIL HADIAH** pada misi yang selesai.
6. Tutup dan jalankan ulang game untuk memastikan progres dan status hadiah tetap tersimpan.

## Checklist perkembangan saat ini
- [x] Struktur proyek Godot 4.x dan aset dasar Detailed Pixel Art 16×16.
- [x] Gerakan pemain, input keyboard, kontrol sentuh dasar, HUD, HP, dan respawn.
- [x] Kolam ikan, bibit, pakan, pertumbuhan offline, panen, Farm Value, dan Job Level.
- [x] Save/load JSON dan backup.
- [x] Slime AI, combat, loot material, peluang drop bibit, dan Peti Loot overflow.
- [x] Inventory 30 slot, stack, penjualan item, dan toko.
- [x] NPC Pedagang, Ahli Breeding, Pengelola Lahan, dan Papan Misi.
- [x] Breeding Basic→Advanced→Rare→Epic→Legendary.
- [x] Sewa/beli lahan, syarat Job Level, relokasi NPC/gerobak, dan penyimpanan properti.
- [x] Quest awal, progres otomatis, klaim hadiah satu kali, dan penyimpanan progres.
- [ ] Pengujian parser/runtime Godot 4.x menyeluruh.
- [ ] Pengujian perangkat Android, layout layar, dan kontrol sentuh.
- [ ] Sistem equipment, statistik karakter, dan skill.
- [ ] Penyimpanan kolam terpisah untuk setiap lahan serta penempatan bangunan.
- [ ] Monster tambahan, hutan/gua/Danger Zone, dan quest lanjutan.
- [ ] Audio final, tutorial, polish UI, optimasi, dan build APK.

## Batas verifikasi
Pemeriksaan statis dilakukan pada JSON, referensi resource, jumlah resource scene, skenario aturan quest/properti, dan integritas ZIP. Godot executable tidak tersedia pada lingkungan pembuatan paket ini; karena itu parser GDScript, runtime game, dan perangkat Android belum dapat dinyatakan lulus. Harga lahan, toko, dan hadiah misi masih nilai prototipe untuk pengujian keseimbangan.
