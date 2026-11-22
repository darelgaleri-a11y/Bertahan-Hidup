# Asset 014 — Village Map Layout

## Isi
- `scenes/regions/village_map.tscn`: scene peta desa mandiri yang memakai player, NPC, Slime, dan pond dari project.
- `assets/tiles/village/village_map_ground.png`: terrain peta 960×544.
- `assets/sprites/environment/village_layout_props_32px.png`: atlas dekorasi 8×4, cell 32×32.

## Cara memasang
1. Ekstrak ZIP ke folder utama project Godot (sejajar dengan `project.godot`).
2. Gabungkan folder `assets`, `scenes`, dan `docs`; jangan hapus berkas lama.
3. Buka Godot dan tunggu import.
4. Buka `scenes/regions/village_map.tscn`.
5. Tekan F6 untuk menjalankan scene peta Desa mandiri.
6. Tekan F5 untuk menjalankan game utama seperti biasa.

## Hasil
Scene peta Desa menampilkan terrain, jalan utama, area kebun, kolam, rumah, toko, sumur, Player, NPC desa, papan misi dan Slime.

## Batasan integrasi
Scene peta ini merupakan preview/layout mandiri, belum menggantikan `scenes/main.tscn` atau tersambung otomatis ke RegionManager. Sistem interaksi dan tampilan HUD game utama tetap berada di main scene. Lakukan pengujian dan penyesuaian posisi collision secara manual di editor sebelum mengintegrasikan sebagai map final.
