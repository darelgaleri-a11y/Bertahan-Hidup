# Asset 024 — Advanced Crafting & Workbench System

## File yang diperbarui
- `scripts/autoload/crafting_manager.gd`
- `data/item_catalog.json`

## Fitur
- Filter resep berdasarkan kategori.
- Resep Meja Kerja Dasar dibuat dari 6 Papan Kayu + 4 Batu Bata.
- Resep lanjutan terkunci sampai item `workbench_basic` ada di inventory.
- Resep lanjutan: Pedang Besi, Zirah Perkuatan, Kapak Besi, Beliung Besi, dan Ramuan Pemulih Besar.
- Hasil crafting masuk inventory dan disimpan melalui SaveManager.

## Cara memasang
1. Buat salinan cadangan proyek.
2. Ekstrak ZIP ke folder proyek Godot, izinkan file dengan nama sama ditimpa.
3. Pastikan Asset 023 sudah dipasang, karena CraftingManager merupakan pengembangan dari sistem tersebut.
4. Buka proyek melalui Godot 4.x.

## Cara menguji
1. Jalankan game, kumpulkan material dan buka crafting dengan tombol `C`.
2. Buat Papan Kayu dan Batu Bata pada kategori Bahan Dasar.
3. Buka kategori Stasiun Kerja, buat Meja Kerja Dasar.
4. Pastikan resep Perlengkapan Lanjutan dan Peralatan dapat dibuat setelah meja kerja ada di inventory.
5. Pastikan resep lanjutan terkunci sebelum meja kerja dimiliki.
6. Tutup game, jalankan lagi, lalu periksa inventory untuk memastikan hasil crafting tersimpan.

## Batas tahap ini
- Meja kerja masih berupa item kepemilikan di inventory, belum ditempatkan sebagai objek fisik di dunia.
- Kapak dan beliung sudah dapat dibuat sebagai item, tetapi belum terhubung dengan kecepatan/animasi gathering.
- Ramuan tercatat sebagai item; efek pemulihan belum ditambahkan pada tahap ini.
- GDScript belum diuji parser/runtime Godot pada tahap pembuatan ZIP. Jangan anggap fitur lulus QA sebelum diuji di editor dan saat game berjalan.
