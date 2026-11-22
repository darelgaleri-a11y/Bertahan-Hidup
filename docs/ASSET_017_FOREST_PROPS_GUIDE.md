# Asset 017 — Dekorasi, Objek, dan Rintangan Hutan

## Isi paket
- `assets/sprites/forest/forest_props_atlas_32px.png`: atlas 12 objek, cell 32×32 px.
- `assets/sprites/forest/forest_props_manifest.json`: nama objek, koordinat atlas, dan saran collision.
- `scenes/regions/forest_props_preview.tscn`: scene preview untuk melihat seluruh objek.

## Objek yang tersedia
Pohon rindang, pohon pinus, batang kayu tumbang, batu besar, tunggul pohon, pakis, jamur, kristal biru, semak berduri, tunggul berlubang, papan penunjuk jalan, dan api unggun.

## Cara memasang
1. Ekstrak ZIP ke folder utama proyek Godot, sejajar dengan `project.godot`.
2. Buka proyek Godot 4.x dan tunggu import.
3. Buka `scenes/regions/forest_props_preview.tscn`.
4. Tekan F6 untuk melihat semua objek.
5. Untuk menempatkan pada peta Hutan, gunakan atlas sebagai Sprite2D/AtlasTexture atau pecah cell menggunakan region 32×32.
6. Tambahkan StaticBody2D + CollisionShape2D secara manual untuk objek yang harus menghalangi pemain. Saran ukuran collider terdapat di manifest.

## Hasil
Preview memperlihatkan 12 objek Hutan dengan grid 32×32, serasi dengan dasar tile 16×16 (skala objek 2×2 tile).

## Batasan
Objek belum ditempatkan otomatis pada `forest_map.tscn`, belum memiliki collision atau perilaku gatherable/hazard. Scene utama dan script gameplay tidak diubah. Perbaikan bug tetap ditunda. Pengujian runtime Godot belum dilakukan.
