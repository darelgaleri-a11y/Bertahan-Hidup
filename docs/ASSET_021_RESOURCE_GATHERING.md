# Asset 021 — Resource Gathering & Interactable Environment

## Isi
- `scripts/resources/resource_gather_node.gd`: mekanik pengumpulan, jarak interaksi, pemilihan node terdekat, depletion dan respawn.
- `scripts/regions/forest_environment.gd`: titik kayu, batu, jamur, kristal biru.
- `scripts/regions/cave_environment.gd`: bijih besi, kristal biru/ungu, jamur gua.
- `scripts/regions/danger_zone_environment.gd`: kayu hangus, batu hitam, kristal bara, pecahan kuno.
- `data/item_catalog.json`: item baru berikut nama dan harga jual.
- `assets/sprites/resources/resource_nodes_atlas_32px.png`: atlas pixel art baru 192×64 px, sel 32×32.
- `assets/sprites/resources/resource_nodes_manifest.json`: koordinat atlas.

## Cara bermain
1. Buka panel Wilayah dengan `M` atau tombol WILAYAH di layar sentuh.
2. Masuk Hutan, Gua, atau Danger Zone.
3. Dekati titik resource sampai jarak sekitar 58 px.
4. Tekan `E` atau tombol INTERAKSI.
5. Hasil masuk Inventory. Jika inventory penuh atau stack tidak dapat ditambah, item disimpan di Peti Loot.
6. Titik resource habis setelah beberapa kali interaksi dan muncul kembali setelah jeda.

## Catatan desain
- Pengumpulan saat ini tidak membutuhkan alat khusus. Sistem kapak/pickaxe dan durability belum menjadi bagian Asset 021.
- Hasil drop dan waktu respawn adalah nilai prototipe untuk playtest.
- Resource nodes dibuat saat scene wilayah aktif diinisialisasi dan mengikuti visibilitas wilayah induknya.
- Bug dan risiko lama tidak diperbaiki dalam tahap ini.
