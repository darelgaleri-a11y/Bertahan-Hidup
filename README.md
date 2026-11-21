# Bertahan Hidup — Shop System Update

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
