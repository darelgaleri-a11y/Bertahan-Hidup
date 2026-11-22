# Asset 026 — Tool Durability & Upgrade System

## Isi perubahan
- `scripts/autoload/tool_manager.gd`: daya tahan alat, alat rusak, perbaikan, UI kondisi alat (tombol T), dan pemilihan alat terbaik yang masih layak.
- `scripts/resources/resource_gather_node.gd`: setiap gathering memakai 1 daya tahan; alat dengan daya tahan 0 tidak dapat dipakai.
- `scripts/autoload/save_manager.gd`: simpan/muat kondisi alat sebagai bagian dari save versi 7. Save versi 1–6 tetap diterima.
- `scripts/autoload/crafting_manager.gd`: upgrade Kapak Kayu menjadi Kapak Besi dan Beliung Kayu menjadi Beliung Besi; memerlukan Meja Kerja Dasar.
- `data/item_catalog.json`: metadata daya tahan alat kayu (100) dan besi (180).

## Kontrol
- `C`: buka/tutup menu crafting.
- `T`: buka/tutup kondisi dan perbaikan alat.
- `E`: gunakan resource node terdekat (sesuai kontrol proyek).

## Biaya perbaikan
- Kapak Kayu: 2 Kayu.
- Beliung Kayu: 2 Batu.
- Kapak Besi: 2 Batangan Besi + 1 Kayu.
- Beliung Besi: 2 Batangan Besi + 2 Batu.

## Upgrade
Upgrade alat kayu ke alat besi mengonsumsi alat kayu tersebut beserta bahan resep dan Meja Kerja Dasar. Alat besi memiliki daya tahan 180 dan tool power 2; alat kayu memiliki daya tahan 100 dan tool power 1.

## Cara memasang
1. Buat salinan cadangan seluruh folder proyek, terutama `data/item_catalog.json` dan `scripts/autoload`.
2. Pastikan Asset 021–025 sudah dipasang berurutan. Asset 025 harus sudah mendaftarkan `ToolManager` di `project.godot`.
3. Ekstrak ZIP ini ke folder root proyek Godot dan izinkan file di dalamnya menimpa file lama.
4. Buka proyek dengan Godot 4.3 atau versi 4.x yang kompatibel.
5. Jalankan proyek.

## Catatan kompatibilitas dan pengujian
- Patch dibuat berdasarkan isi file yang berhasil diperiksa dari branch default repository pada 22 November 2026.
- `project.godot` sengaja tidak disertakan karena Asset 025 sudah mendaftarkan Autoload `ToolManager`; jangan menghapus pendaftaran tersebut.
- Item catalog di dalam patch mengikuti katalog yang dibaca dari repository dan menambahkan metadata durability. Simpan backup sebelum menimpa katalog lokal.
- Arsip dan JSON diperiksa. Godot tidak tersedia di lingkungan pemeriksaan ini, sehingga parser GDScript, runtime, dan Android build belum diuji. Tahap QA dan perbaikan bug tetap ditunda sesuai arahan.
