# Asset 013 — Peta Desa (Fondasi Scene)

Isi paket:
- `scenes/regions/village_map.tscn`: scene mandiri dengan dua TileMapLayer.
- `assets/tiles_village_ground_16px.png`: atlas rumput 4×4, setiap tile 16×16.
- `assets/sprites/environment/village_props_32px.png`: atlas rumah, toko, sumur, pagar, bunga, papan misi, lampu, dan rumput.

## Cara memasang
1. Ekstrak ZIP ke folder utama proyek Godot, sejajar dengan `project.godot`.
2. Buka proyek Godot 4.x dan tunggu impor aset.
3. Buka `scenes/regions/village_map.tscn`.
4. Pilih `GroundLayer`, gunakan TileMap editor untuk melukis tile rumput.
5. Pilih `PropsLayer` untuk menaruh objek desa.
6. Untuk menjalankan scene ini tekan F6 setelah scene aktif.
7. Game utama tetap dapat dijalankan dengan F5.

## Catatan
Scene utama `scenes/main.tscn`, script gameplay, katalog, dan save format tidak diubah.
Peta ini adalah fondasi mandiri; layout Desa belum dilukis dan belum dihubungkan ke perpindahan wilayah.
