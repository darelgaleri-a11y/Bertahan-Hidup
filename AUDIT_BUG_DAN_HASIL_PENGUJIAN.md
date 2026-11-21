# Audit Bug & Hasil Pemeriksaan — Bertahan Hidup v9

## Basis pemeriksaan
Repository: https://github.com/darelgaleri-a11y/Bertahan-Hidup (branch main), diperiksa 22 November 2026.

## Bug yang diperbaiki pada patch ini
1. Fasilitas Desa (NPC toko, breeding, pengelola lahan, papan misi, serta kolam) masih dapat dicoba saat pemain berada di wilayah lain. Sekarang interaksi dunia/fasilitas dibatasi ke wilayah Desa; perintah untuk kembali ke Desa ditampilkan.
2. Monster yang mengejar pemain dapat menjauh jauh dari titik spawn dan kemudian respawn pada koordinat kematiannya. Sekarang posisi rumah monster direkam saat dibuat dan dipakai sebagai titik respawn.
3. Monster dapat meninggalkan area asalnya saat mengejar pemain. Sekarang pengejaran dibatasi terhadap radius dari titik rumah monster agar monster tidak berkeliaran tanpa batas.
4. Pemeriksaan respawn dirapikan agar hanya menganggap instance hidup sebagai alasan menolak pembuatan monster baru; pemeriksaan menggunakan path scene yang sama.

## Pemeriksaan sumber proyek
- RegionManager menyediakan Desa, Hutan, Gua, Zona Bahaya dengan syarat Job Level 1, 1, 3, dan 5.
- Monster dan NPC menggunakan `region_id` untuk membatasi kehadiran sesuai wilayah.
- Save/load menyimpan wilayah aktif dan fallback ke Desa jika data tidak valid atau wilayah belum terbuka.
- Loot, quest kill, serta koneksi sinyal monster tetap menggunakan sistem sebelumnya.

## Batas pengujian
ZIP diverifikasi integritasnya dan file patch diperiksa secara statis. Godot Engine tidak tersedia di lingkungan pembuatan paket; parser GDScript, runtime scene, gameplay sesungguhnya, dan build Android belum dapat dinyatakan lulus. Pengujian manual tetap diperlukan setelah paket dipasang.
