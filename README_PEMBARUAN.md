# Paket pembaruan — Bertahan Hidup

Paket ini berisi **file pengganti**, bukan seluruh proyek Godot. Salin folder `scripts/`
ke folder proyek yang sudah Anda clone. File aset, scene, katalog JSON, dan `project.godot`
tidak diubah.

## File yang diperbarui
- `scripts/autoload/farm_manager.gd`
  - Progres pertumbuhan tidak lagi hilang karena waktu dihitung per pecahan detik.
  - Konsumsi pakan dihitung berdasarkan detik aktif dan tersimpan saat game ditutup.
  - Save lama yang hanya memiliki `feed_count` tetap dapat dibaca.
  - Progres pertumbuhan dibatasi 0–100% dan pakan tidak menjadi negatif.
- `scripts/autoload/save_manager.gd`
  - Save versi 2 menyimpan data pakan presisi.
  - Membuat backup sebelum mengganti save sebelumnya.
  - Memeriksa kegagalan baca/tulis dan memulihkan sinyal UI setelah load.
- `scripts/ui/main.gd`
  - Pertumbuhan diperbarui selama game berjalan.
  - Autosave setiap 30 detik dan saat game ditutup.
  - Label uang/farm value diperbarui dari sinyal yang sesuai.

## Cara memasang
1. Buat salinan/backup folder proyek Anda terlebih dahulu.
2. Ekstrak ZIP ini.
3. Buka folder hasil ekstrak. Salin folder `scripts` ke folder utama proyek Godot Anda.
4. Jika Windows bertanya apakah file lama ingin diganti, pilih **Replace**.
5. Buka `project.godot` menggunakan Godot 4.3 atau versi 4.x yang kompatibel.
6. Tekan **F6** untuk menjalankan scene aktif atau **F5** untuk menjalankan proyek.

## Hasil yang diharapkan
- Karakter tetap dapat bergerak dengan WASD/tombol panah.
- Tekan E di dekat kolam untuk memasukkan bibit, memberi pakan, atau memanen.
- Setelah ikan dan pakan tersedia, progres bertambah selama waktu berjalan.
- Pakan berkurang seiring waktu pertumbuhan; jika pakan habis, pertumbuhan berhenti.
- Setelah 48 jam waktu pertumbuhan yang didukung pakan, kolam menjadi siap panen.
- Keluar dan buka kembali game: progres dan sisa pakan dilanjutkan dari save.
- File `user://savegame_backup.json` menjadi salinan save sebelumnya saat save baru dibuat.

## Checklist pengujian manual
- [ ] Proyek berhasil dibuka tanpa error parser Godot.
- [ ] Karakter bergerak dengan WASD dan tombol panah.
- [ ] Menekan E jauh dari kolam menampilkan pesan jarak.
- [ ] Menekan E dekat kolam memasukkan bibit jika stok tersedia.
- [ ] Pakan dapat ditambahkan dari inventory.
- [ ] Progres tumbuh saat game berjalan dan pakan tersedia.
- [ ] Progres berhenti saat pakan habis.
- [ ] Progres dan sisa pakan tetap benar setelah game ditutup dan dibuka lagi.
- [ ] Autosave berjalan setelah 30 detik.
- [ ] Panen berhasil ketika progres mencapai 100%.
- [ ] Tidak ada error di panel Debugger Godot.

## Batas verifikasi
Paket ini dibuat berdasarkan source code repository GitHub yang diperiksa. Godot Engine tidak tersedia
di lingkungan pembuatan paket ini, sehingga proyek belum dijalankan di engine dan checklist di atas
belum boleh dianggap lulus. Jalankan pengujian di komputer Anda.
