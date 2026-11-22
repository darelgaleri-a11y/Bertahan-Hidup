# Asset 016 — Hutan: Layout Visual dan Scene Preview

## File dalam paket
- `scenes/regions/forest_map.tscn`: scene preview Hutan yang dapat dibuka dan dijalankan mandiri.
- `assets/tiles/region/forest_map_layout.png`: peta Hutan 960×544 px dengan dasar visual 16×16 px.
- `assets/tiles/region/forest_ground_16px.png`: atlas rumput hutan 4×4 tile.
- `assets/tiles/region/forest_ground_tileset.tres`: TileSet 16×16 untuk proses pengeditan lanjutan.

## Cara memasang
1. Ekstrak ZIP ke folder utama proyek, sejajar dengan `project.godot`.
2. Buka proyek di Godot 4.x dan tunggu impor selesai.
3. Di FileSystem, buka `scenes/regions/forest_map.tscn`.
4. Tekan F6 untuk menjalankan preview Hutan.
5. Tekan F5 untuk tetap menjalankan game utama.

## Hasil yang diharapkan
Preview memperlihatkan hutan rimbun, jalan setapak berkelok, aliran air di sisi kanan, beberapa area terbuka, pepohonan, pakis, jamur, dan penanda jalur.

## Batasan tahap
Ini adalah scene preview visual mandiri. Belum terhubung ke sistem perpindahan wilayah di game utama dan belum berisi node monster, collision pohon/batu, gathering, atau interaksi. Scene utama dan script gameplay tidak diubah. Pengujian runtime di Godot belum dilakukan.
