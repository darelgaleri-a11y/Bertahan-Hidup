# Asset 019 — Cave Map Integration

## Isi paket
- `scenes/main.tscn` — menambahkan instance CaveEnvironment ke scene utama.
- `scenes/regions/cave_map.tscn` — area gua dengan lantai, dekorasi, dan penghalang.
- `scripts/regions/cave_environment.gd` — menampilkan gua hanya ketika region aktif adalah `cave`.
- `assets/tiles/region/cave_map_layout.png` — peta lantai gua 960x544.
- `assets/sprites/cave/cave_props_atlas_32px.png` dan manifest — 12 objek gua 32x32.

## Prasyarat
Paket ini ditujukan untuk kondisi repositori yang sudah memuat Asset 018, Asset 016, dan Asset 017. Pertahankan file-file tersebut. Ekstrak isi ZIP ke root proyek, sejajar dengan `project.godot`, dan izinkan `scenes/main.tscn` ditimpa.

## Menjalankan
1. Buka proyek `Bertahan Hidup` di Godot 4.x.
2. Tunggu impor aset selesai.
3. Jalankan proyek dengan F5.
4. Tekan M untuk membuka Peta Wilayah.
5. Pilih Gua (Job Level minimal 3).
6. Jelajahi gua dan lawan Tengkorak serta Goblin.
7. Tekan M dan pilih Desa/Hutan untuk berpindah kembali.

## Hasil yang diharapkan
- Gua hanya terlihat saat `RegionManager.current_region_id == "cave"`.
- Lantai gua, stalagmit, stalaktit, tumpukan batu, kristal, pilar, bijih, reruntuhan, obor, dan penanda pintu gua terlihat.
- Penghalang statis membatasi gerakan pemain.
- Monster Tengkorak dan Goblin yang sudah ada pada `scenes/main.tscn` menjadi aktif di Gua karena `region_id` masing-masing adalah `cave`.
- Desa dan Hutan tetap dapat dipilih melalui menu wilayah.

## Catatan
Paket dibuat berdasarkan pemeriksaan statis struktur repositori GitHub. Belum dilakukan pengujian runtime Godot pada paket ini. Bug tidak diperbaiki pada tahap ini sesuai arahan; jika ada masalah saat dijalankan, catat pesan error untuk tahap pengujian terpisah.
