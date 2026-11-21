# Changelog — Farming & Player HUD

- Mengganti hitungan konsumsi pakan per hari penuh menjadi hitungan detik aktif.
- Menyimpan sisa detik pakan agar progres parsial tidak hilang saat game ditutup.
- Mendukung data save lama yang hanya memiliki `feed_count`.
- Membatasi progres pertumbuhan pada 0–100% dan pakan tidak menjadi negatif.
- Menambahkan tampilan HP pemain pada HUD.
- Menambahkan pemulihan pemain di posisi awal setelah HP mencapai nol.
- Mempertahankan AI Slime, serangan, dan loot dari pembaruan sebelumnya.

## Update kontrol Android dan penyimpanan
- Memindahkan konfigurasi aksi `attack` ke bagian `[input]` agar tombol J/Space terdaftar sebagai input game, bukan salah dibaca sebagai autoload.
- Menambahkan tombol sentuh virtual untuk arah, interaksi, dan serangan pada perangkat layar sentuh.
- Mengatur orientasi perangkat ke landscape sesuai keputusan desain game.
- Penyimpanan kini memperbarui simulasi kolam tepat sebelum membuat save.
- Jika save utama rusak/tidak valid, game mencoba membaca backup; proses penggantian save juga memulihkan backup jika gagal.
- Memindahkan pesan status ke bagian bawah-tengah agar tidak menutupi kontrol sentuh.
