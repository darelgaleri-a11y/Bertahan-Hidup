# Asset 015 — Integrasi Peta Desa ke Scene Utama

## Isi paket
- `scenes/main.tscn` — scene utama diperbarui agar memakai latar desa baru.
- `assets/tiles/village/village_main_ground_16px.png` — latar peta desa 960×544 px, disusun dengan dasar visual 16×16 px.

## Yang berubah
Scene utama tetap menggunakan `scripts/ui/main.gd`, player, kolam, Slime, semua NPC, monster, HUD, dan posisi awal yang ada pada repositori.
Perubahan scene yang disengaja hanya mengganti tekstur `GroundVisual` dan memperbarui judul HUD menjadi `BERTAHAN HIDUP — DESA AWAL`.
Peta memuat jalur utama, tiga bangunan layanan, papan misi, sumur, petak kebun, pagar, pepohonan, dan dekorasi lingkungan.

## Cara memasang
1. Ekstrak isi ZIP ke folder utama proyek Godot, yaitu folder yang berisi `project.godot`.
2. Izinkan file `scenes/main.tscn` yang baru menggantikan file lama.
3. Pastikan folder `assets/tiles/village/` ikut tersalin.
4. Buka proyek `project.godot` menggunakan Godot 4.x.
5. Tekan F5 untuk menjalankan game dari scene utama.

## Hasil yang diharapkan
Latar prototipe akan tergantikan oleh area desa yang memiliki jalur, bangunan, kebun, pohon, dan area fasilitas. Player, kolam, NPC, HUD, monster, serta sistem gameplay tetap berasal dari scene dan script yang sudah ada. Interaksi dengan NPC tetap menggunakan tombol E sesuai jarak interaksi yang telah ditentukan di script.

## Batasan tahap ini
Peta ini adalah latar visual terintegrasi, bukan TileMap yang bisa diedit per tile di dalam editor. Bangunan dan dekorasi pada tekstur latar belum mempunyai collision atau interaksi tersendiri. Sistem gameplay tidak diubah. Pengujian runtime Godot belum dilakukan dalam paket ini.
