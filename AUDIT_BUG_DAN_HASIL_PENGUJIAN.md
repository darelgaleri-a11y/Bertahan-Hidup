# Laporan Audit — Bertahan Hidup

## Sumber yang diperiksa
- Repository: https://github.com/darelgaleri-a11y/Bertahan-Hidup
- Branch: main
- Folder kerja lokal: Bertahan_Hidup_Godot

## Temuan dan perbaikan pada paket ini
1. **Respawn setelah relokasi lahan** — sebelumnya respawn selalu memakai koordinat awal desa. Sekarang titik respawn diambil dari `spawn_position` lahan aktif.
2. **Validasi inventory saat load** — sanitasi inventory sekarang menolak item yang tidak dikenal/jumlah tidak valid dan membatasi inventory maksimal 30 slot.
3. **Validasi Peti Loot saat load** — jumlah loot non-numerik atau item yang tidak dikenal diabaikan.
4. **Validasi data lahan** — record properti yang rusak dinormalisasi ke status yang aman.
5. **Respawn Slime** — Slime muncul kembali 5 detik setelah dikalahkan agar area berburu dan misi Pemburu Slime tetap dapat dimainkan.\n6. **Quest/Misi** — menambahkan tiga misi awal, progres otomatis, hadiah sekali klaim, NPC Papan Misi, UI PC/touch, serta penyimpanan progres.

## Checklist pemeriksaan statis
- [x] Empat file katalog JSON dapat dibaca.
- [x] Tidak ditemukan referensi `res://` yang menunjuk file hilang.
- [x] Semua `load_steps` pada scene sesuai jumlah resource eksternal/internal.
- [x] Tidak ditemukan nama fungsi duplikat dalam satu file GDScript.
- [x] Simulasi progres quest menyelesaikan ketiga target sesuai jumlah.
- [x] Simulasi sanitasi inventory membatasi kapasitas ke 30 slot.
- [x] Arsip ZIP diuji integritasnya.

## Batas pengujian
Godot tidak tersedia di lingkungan pemeriksaan ini. Karena itu, pemeriksaan parser GDScript, menjalankan scene, gameplay sesungguhnya, dan pengujian perangkat Android belum dilakukan. Jangan anggap pemeriksaan statis sebagai pengganti playtest di Godot.
