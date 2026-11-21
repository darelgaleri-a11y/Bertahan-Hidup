# Audit Bug & Hasil Pemeriksaan — Patch v11

## Basis pemeriksaan
Repository: `https://github.com/darelgaleri-a11y/Bertahan-Hidup`
Branch: `main`
Commit dasar yang diperiksa: `72ccfbebc38854182eaf4850f038af2a4a9af843`
Tanggal: 22 November 2026.

## Perbaikan pada patch ini
1. **Respawn monster tertunda:** antrean lama dibersihkan ketika monster dari scene yang sama sudah aktif kembali. Entri yang tidak valid dibuang, dan pemrosesan antrean tidak membuat duplikat jika monster hidup ditemukan.
2. **Pencatatan sinyal monster respawn:** monster baru sekarang ditambahkan ke SceneTree terlebih dahulu, baru sinyal `defeated` didaftarkan. Ini menghindari registrasi callback terlalu dini sebelum node memasuki pohon scene.
3. **Validasi save:** file save dengan versi non-numerik, kurang dari 1, atau lebih baru dari `SAVE_VERSION` ditolak agar tidak dibaca oleh format yang tidak kompatibel. Nilai Money dan Farm Value juga harus numerik sebelum diterapkan.
4. **Validasi pemakaian skill:** `_cast_skill()` di UI utama sekarang menghentikan penggunaan skill saat pemain kalah, termasuk pemanggilan keyboard atau UI.

## File yang berubah
- `scripts/ui/main.gd`
- `scripts/autoload/save_manager.gd`

Tidak ada file aset visual yang diubah karena audit kali ini berfokus pada bug logika dan data. ZIP berisi file sumber lengkap dengan path folder agar bisa langsung ditimpa di proyek.

## Kompatibilitas
`SAVE_VERSION` dipertahankan pada 6. Save lama versi 1–6 masih dapat dibaca selama data wajib valid. Save yang lebih baru dari versi aplikasi tidak akan ditimpa melalui proses load; backup yang valid akan dicoba.

## Pemeriksaan statis
- Pemeriksaan perubahan teks dan struktur fungsi dilakukan.
- ZIP dibuat dengan struktur path proyek.
- Integritas arsip diperiksa dengan `ZipFile.testzip()`.
- Godot Engine tidak tersedia untuk pemeriksaan parser GDScript, runtime, gameplay, maupun build Android. Status runtime belum dinyatakan lulus.

## Skenario uji manual
1. Kalahkan Serigala di Hutan, kembali ke Desa sebelum waktu respawn, lalu masuk Hutan kembali. Pastikan tidak ada Serigala ganda.
2. Kalahkan monster Gua/Zona Bahaya dan ulangi perpindahan wilayah.
3. Saat pemain kalah, coba tombol K/L dan tombol skill di UI. Tidak boleh ada skill yang terpakai.
4. Jalankan save versi 6 yang sudah ada dan periksa Money, Farm Value, inventory, kolam, properti, quest, equipment, skill dan wilayah.
5. Buat backup save terlebih dahulu sebelum menguji skenario file save rusak atau versi tidak dikenal.
