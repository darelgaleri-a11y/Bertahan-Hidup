# Asset 018 — Integrasi Lingkungan Hutan

## File diperbarui
- `scenes/main.tscn` — menambahkan scene lingkungan hutan ke scene utama.
- `scenes/regions/forest_map.tscn` — latar hutan, 12 dekorasi, lima collider, dan dua serigala.
- `scripts/regions/forest_environment.gd` — pergantian tampilan desa/hutan mengikuti RegionManager.

## Cara memasang
1. Ekstrak ZIP ke folder utama proyek (sejajar dengan `project.godot`).
2. Izinkan penimpaan `scenes/main.tscn`.
3. Pastikan file dari Asset 016 dan 017 sudah tersedia: `assets/tiles/region/forest_map_layout.png` dan `assets/sprites/forest/forest_props_atlas_32px.png`.
4. Buka proyek Godot 4.x, tunggu impor, lalu tekan F5.
5. Tekan M, pilih Hutan (Job Level minimum 1). Gunakan WASD/panah untuk bergerak dan J/Space untuk menyerang.
6. Tekan M lalu pilih Desa untuk kembali.

## Hasil yang diharapkan
- Game dimulai di Desa seperti sebelumnya.
- Memilih Hutan mengganti latar desa dengan peta hutan; kolam dan NPC desa disembunyikan.
- Pepohonan, batang kayu, batu, dan semak berduri memiliki collider penghalang.
- Dua serigala tampil dan mengikuti sistem AI/loot/quest monster yang sudah ada.
- Kembali ke Desa mengembalikan latar, kolam, dan NPC desa.

## Checklist
- [x] Asset tanah hutan (016)
- [x] Atlas dekorasi hutan (017)
- [x] Lingkungan hutan dihubungkan ke scene utama (018)
- [x] Lima collider rintangan statis
- [x] Dua serigala ditempatkan di area hutan
- [x] Tampilan Desa/Hutan mengikuti pergantian wilayah
- [ ] Uji runtime Godot 4.x
- [ ] Penyesuaian posisi objek berdasarkan hasil uji
- [ ] Gathering jamur/kristal
- [ ] Damage/efek semak berduri

Catatan: bug lain tetap ditunda. Pemeriksaan tahap ini statis; Godot belum dijalankan di lingkungan ini. Asset 016 dan 017 harus sudah terpasang sebelum game dijalankan.
