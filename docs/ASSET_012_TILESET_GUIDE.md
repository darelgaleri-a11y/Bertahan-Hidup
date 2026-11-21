# Asset 012 — TileSet & Terrain Resources (Godot 4.x)

Paket ini melanjutkan Asset 011 dengan resource `.tres` yang dapat diimpor langsung sebagai TileSet.

## Isi tambahan
- `assets/tiles/region/village_ground_tileset.tres`
- `assets/tiles/region/forest_ground_tileset.tres`
- `assets/tiles/region/cave_ground_tileset.tres`
- `assets/tiles/region/danger_zone_ground_tileset.tres`
- `assets/sprites/environment/environment_objects_tileset.tres`

## Cara memasang
1. Ekstrak seluruh isi ZIP ke folder utama proyek Godot (sejajar dengan `project.godot`).
2. Pilih gabungkan/merge saat folder `assets` bertemu.
3. Buka Godot 4.x dan tunggu import.
4. Di FileSystem, pilih salah satu `.tres`, misalnya `village_ground_tileset.tres`.
5. Resource TileSet berisi atlas 4×4. Setiap cell ground menggunakan ukuran 16×16 pixel.
6. Resource dekorasi berisi atlas 4×2 cell berukuran 32×32 pixel.

## Integrasi ke TileMapLayer
- Buka atau buat scene map yang menggunakan `TileMapLayer`.
- Inspector > Tile Set: masukkan resource `.tres` sesuai wilayah.
- Pada TileMap, gunakan TileMap editor untuk melukis tile atlas.
- Untuk dekorasi, tambahkan `TileMapLayer` terpisah dan pilih `environment_objects_tileset.tres`.

## Batasan tahap
Resource TileSet telah disiapkan, tetapi scene map belum disambungkan ke menu perpindahan wilayah. Belum ada TileMap yang otomatis dilukis. Main scene, scripts gameplay, save format, dan data catalog tidak diubah. Dengan sengaja paket ini tidak menyentuh script gameplay.
