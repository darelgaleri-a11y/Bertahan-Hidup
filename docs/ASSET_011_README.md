# Asset 011 — Region Environment (Bertahan Hidup)

Paket ini menambahkan fondasi visual empat wilayah dengan gaya Detailed Pixel Art dan grid dasar 16×16.

## Isi
- `assets/tiles/region/village_ground_16px.png`
- `assets/tiles/region/forest_ground_16px.png`
- `assets/tiles/region/cave_ground_16px.png`
- `assets/tiles/region/danger_zone_ground_16px.png`
- `assets/sprites/environment/environment_objects_32px.png`
- `assets/tiles/region/region_asset_manifest.json`

## Penggunaan di Godot 4.x
1. Ekstrak folder `assets` ke folder utama proyek (sejajar dengan `project.godot`).
2. Buka proyek Godot dan tunggu proses import.
3. Buka `Project > Tools` atau panel FileSystem untuk memastikan PNG terdeteksi.
4. Untuk membuat TileSet: buat resource TileSet, atur Tile Size ke `16 × 16`, lalu tambahkan masing-masing ground sheet sebagai Atlas Source dengan region 64×64 dan separation 0.
5. Untuk objek dekorasi: gunakan texture `environment_objects_32px.png` sebagai atlas; setiap objek berada di sel 32×32.
6. Gunakan Texture Filter `Nearest` agar pixel art tetap tajam.

## Catatan integrasi
Ini adalah paket aset visual mandiri. Tidak mengubah `scenes/main.tscn`, `scripts/ui/main.gd`, `data/region_catalog.json`, atau sistem perpindahan wilayah. Aset belum ditempatkan otomatis ke peta permainan karena integrasi peta per wilayah memerlukan penyesuaian scene yang ada. Setelah paket disalin, aset tersedia di FileSystem Godot tetapi belum tampil dalam game sampai dipasang ke TileMapLayer/TileMap scene.
