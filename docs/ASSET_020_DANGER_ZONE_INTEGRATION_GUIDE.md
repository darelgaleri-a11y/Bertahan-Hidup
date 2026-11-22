# Asset 020 — Danger Zone Integration

## Isi paket
- `scenes/main.tscn` — diperbarui untuk memuat `DangerZoneEnvironment`.
- `scenes/regions/danger_zone_map.tscn` — lingkungan Zona Bahaya, dekorasi, dan penghalang statis.
- `scripts/regions/danger_zone_environment.gd` — mengaktifkan lingkungan ketika wilayah `danger_zone` dipilih.
- `assets/tiles/region/danger_zone_map_layout.png` — lantai Zona Bahaya 960×544.
- `assets/sprites/danger_zone/danger_zone_props_atlas_32px.png` dan manifest — 12 dekorasi pixel art.
- `docs/PROJECT_CONTINUATION_CONTEXT.md` — ringkasan proyek untuk percakapan baru.
- `docs/CONTINUATION_PROMPT_NEW_CHAT.md` — prompt siap salin untuk melanjutkan proyek.

## Prasyarat
Paket ini adalah patch untuk repositori yang sudah memiliki Asset 011–019, khususnya `scenes/regions/forest_map.tscn`, `scenes/regions/cave_map.tscn`, serta aset monster yang ada. Jangan hapus file lama.

## Cara memasang
1. Buat salinan/backup folder proyek Godot.
2. Ekstrak ZIP ke folder root proyek, sejajar dengan `project.godot`.
3. Izinkan `scenes/main.tscn` ditimpa.
4. Buka proyek di Godot 4.x dan tunggu impor aset selesai.

## Cara menjalankan
1. Tekan F5.
2. Tekan M untuk membuka Peta Wilayah.
3. Pilih Zona Bahaya (Job Level minimal 5 sesuai `data/region_catalog.json`).
4. Jelajahi area dan hadapi Monster Buas Elite serta Penjaga Hutan yang sudah ada di scene utama.
5. Tekan M untuk kembali ke Desa atau berpindah ke wilayah lain.

## Hasil yang diharapkan
- Lantai dan dekorasi bertema tanah hangus, batu, bara, kristal bahaya, pohon mati, dan reruntuhan terlihat hanya di Zona Bahaya.
- Pohon mati, batu besar, pilar basalt, dan altar menjadi penghalang fisik.
- Monster Elite dan Boss yang telah ada tetap menggunakan sistem monster dan loot yang sudah tersedia.
- Desa, Hutan, dan Gua tetap dapat dipilih dari menu wilayah.

## Batasan tahap ini
- Spike trap dan ember vent masih dekorasi visual, belum memberikan damage atau interaksi.
- Tidak mengubah katalog wilayah, monster, sistem combat, loot, atau Job Level.
- Tidak memperbaiki bug yang ditemukan.
- Paket diperiksa secara statis dan integritas ZIP; belum dijalankan di Godot pada mesin ini.
