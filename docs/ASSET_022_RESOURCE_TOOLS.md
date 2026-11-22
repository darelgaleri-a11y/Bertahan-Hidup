# Asset 022 — Resource Tools & Gathering Animations

## Isi pembaruan
- Atlas pixel-art kapak dan beliung, masing-masing sel 32×32 px.
- Animasi ayunan alat singkat saat karakter mengumpulkan resource.
- Kayu/kayu hangus memakai visual kapak.
- Batu, bijih dan kristal memakai visual beliung.
- Jamur tetap dikumpulkan dengan tangan.
- Kontrol tetap menggunakan E atau tombol INTERAKSI di layar sentuh.

## Cara memasang
1. Cadangkan folder proyek Godot.
2. Ekstrak ZIP ke folder utama proyek (folder yang berisi `project.godot`).
3. Izinkan file dengan nama sama ditimpa.
4. Buka proyek di Godot 4.3 atau lebih baru.

## Cara menguji
1. Jalankan proyek dengan F6/F5 sesuai scene yang sedang dibuka (utama: F5).
2. Tekan M, pilih Hutan.
3. Dekati pohon dan tekan E / INTERAKSI. Harus terlihat kapak mengayun dan jumlah Kayu bertambah.
4. Dekati batu atau kristal. Harus terlihat beliung mengayun dan item bertambah.
5. Coba jamur. Item bertambah tanpa animasi alat.
6. Ulangi di Gua dan Danger Zone.

## Batasan tahap ini
Ini adalah tahap visual/animasi alat. Kapak dan beliung belum menjadi item inventaris yang harus dimiliki, belum memiliki durability, upgrade, crafting, atau pembatasan akses. Belum ada animasi tubuh karakter penuh; yang tampil adalah sprite alat yang mengayun di dekat karakter. Nilai drop dan respawn tetap dari Asset 021.

## Status verifikasi
- Struktur ZIP dan PNG diperiksa.
- JSON manifest diperiksa.
- Godot headless/parser dan uji runtime belum tersedia pada lingkungan pemeriksaan ini; lakukan uji langkah di atas di Godot sebelum menyatakan tahap lolos QA.
