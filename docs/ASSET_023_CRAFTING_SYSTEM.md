# Asset 023 — Crafting System

## Fitur
- Meja crafting dapat dibuka dengan tombol C.
- Lima resep awal: Papan Kayu, Batu Bata, Batangan Besi, Inti Kristal, dan Ramuan Pemulih.
- Daftar bahan menunjukkan jumlah dimiliki dibanding kebutuhan.
- Tombol BUAT nonaktif jika bahan kurang atau inventory tidak dapat menampung hasil.
- Bahan dikurangi dan hasil ditambahkan ke InventoryManager.
- Hasil crafting disimpan melalui mekanisme SaveManager yang sudah ada.

## Resep
| Hasil | Bahan |
|---|---|
| Papan Kayu x2 | Kayu x3 |
| Batu Bata x2 | Batu x3 |
| Batangan Besi x1 | Bijih Besi x2 + Batu x1 |
| Inti Kristal x1 | Kristal Biru x2 + Kristal Ungu x1 |
| Ramuan Pemulih x1 | Jamur Hutan x2 + Jamur Gua x1 |

## Instalasi
1. Cadangkan folder proyek.
2. Ekstrak ZIP ke folder yang berisi project.godot.
3. Izinkan file yang sama ditimpa.
4. Buka proyek di Godot 4.3+ dan jalankan dengan F5.

## Pengujian
1. Jalankan game, tekan C. Panel MEJA CRAFTING muncul.
2. Kumpulkan material di Hutan/Gua/Danger Zone menggunakan Asset 021.
3. Buka panel C lagi. Jumlah material harus berubah.
4. Penuhi resep Papan Kayu (3 Kayu), tekan BUAT.
5. Harus ada Papan Kayu x2, Kayu berkurang 3, dan notifikasi berhasil.
6. Uji resep lain dan uji ketika inventory penuh.

## Batasan
Ini adalah crafting dasar berbasis inventaris. Belum ada animasi meja kerja, bangunan workstation, kategori resep, crafting queue, level profesi, resep yang harus dibuka, atau penggunaan Ramuan Pemulih pada karakter. Perbaikan bug menyeluruh tetap ditunda sesuai rencana.
