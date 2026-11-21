# Bertahan Hidup — Paket Update Kontrol Android & Save System

Proyek game 2D top-down Godot 4.x dengan gaya Detailed Pixel Art dan tile dasar 16×16.
Paket ZIP ini berisi **seluruh proyek beserta asset**, bukan hanya file pengganti.

## Cara menjalankan
1. Unduh dan ekstrak ZIP.
2. Buka Godot 4.3 atau Godot 4.x yang kompatibel.
3. Pada Project Manager pilih **Import**.
4. Pilih file `project.godot` dari folder hasil ekstrak.
5. Buka proyek, tunggu proses import asset selesai, lalu tekan **F6** untuk menjalankan scene utama atau **F5** untuk menjalankan proyek.

## Kontrol
### Keyboard
- WASD / tombol panah: bergerak.
- E: interaksi dengan kolam.
- J atau Space: menyerang Slime saat berada dalam jangkauan.

### Layar sentuh
Pada perangkat Android/layar sentuh akan muncul tombol arah, INTERAKSI, dan SERANG.

## Hasil yang diharapkan
- Game berjalan dalam orientasi landscape.
- Pemain dapat bergerak menggunakan keyboard atau tombol sentuh.
- Dekati kolam dan tekan E/INTERAKSI untuk memasukkan bibit, menambah pakan, atau memanen sesuai kondisi kolam.
- Pertumbuhan ikan berlangsung sampai 48 jam waktu yang didukung pakan. Sisa waktu pakan dihitung dalam detik, sehingga waktu parsial tidak hilang saat game ditutup.
- Dekati Slime dan tekan J/Space atau SERANG. Serangan pemain memberikan 25 damage; Slime memiliki 50 HP.
- Slime menyerang pemain, dan ketika dikalahkan menjatuhkan 1–2 Slime Gel serta peluang 10% bibit Basic. Monster tidak memberikan EXP.
- HUD menampilkan Money, Job Level, Farm Value, progres kolam, dan HP pemain.
- Save otomatis setiap 30 detik dan ketika aplikasi ditutup. Backup save dibuat sebelum file utama diganti.

## Checklist perkembangan dan pengujian
- [x] Struktur proyek Godot dan asset dasar tersedia.
- [x] Karakter pemain dan pergerakan keyboard.
- [x] Slime dengan AI mengejar dan menyerang.
- [x] Serangan pemain dan loot dasar Slime.
- [x] Kolam, bibit, pakan, pertumbuhan, dan panen dasar.
- [x] HUD dasar: uang, progres kolam, Job Level/Farm Value, dan HP.
- [x] Save/load JSON, autosave, dan backup dasar.
- [x] Perhitungan sisa pakan per detik dan kompatibilitas save lama.
- [x] Konfigurasi aksi serang dipindahkan ke Input Map yang benar.
- [x] Kontrol sentuh virtual untuk Android.
- [x] Orientasi landscape.
- [ ] Uji parser dan jalankan proyek di Godot 4.x pada perangkat/komputer.
- [ ] Uji seluruh alur farming, combat, save/load, dan kontrol sentuh secara langsung.
- [ ] Implementasi sistem inventory UI, toko, NPC, quest, skill, dan area dunia lanjutan.

## Catatan verifikasi
Checklist `[x]` berarti fitur sudah tersedia di source code paket. Checklist tersebut **bukan** klaim bahwa fitur telah lulus pengujian runtime. Lingkungan pembuatan paket ini tidak menyediakan Godot Engine, sehingga parser Godot dan gameplay belum dapat dijalankan di sini. Mohon nilai hasil aktual dari pengujian setelah proyek dibuka di Godot.
