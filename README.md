# Bertahan Hidup — Paket Pengembangan Godot 4.x

Game 2D top-down Detailed Pixel Art, basis tile 16×16, orientasi landscape.

## Isi paket
- Proyek Godot lengkap beserta aset pixel art yang sudah ada.
- Gerakan karakter dengan WASD/tombol panah.
- Interaksi kolam dengan tombol E.
- Pertumbuhan ikan, penggunaan pakan, panen, Farm Value, Job Level, dan penyimpanan lokal.
- Pertarungan uji melawan Slime.
- Loot Slime: 1–2 Slime Gel dijamin; peluang 10% mendapatkan 1 Bibit Basic.
- Sistem save dengan file sementara dan backup.

## Cara menjalankan
1. Ekstrak ZIP ke folder biasa.
2. Pasang/buka Godot 4.3 atau Godot 4.x yang kompatibel.
3. Di Project Manager pilih **Import**.
4. Pilih file `project.godot` di folder `Bertahan_Hidup_Godot`.
5. Buka proyek, tunggu import aset selesai, lalu tekan **F6** atau **F5**.

## Kontrol
- WASD / tombol panah: bergerak.
- E: interaksi kolam (dekat kolam).
- J atau Space: serang Slime jika berada dalam jarak 48 pixel.

## Hasil yang diharapkan
- Layar menampilkan area rumput, karakter, kolam, HUD, dan satu Slime.
- Karakter dapat bergerak.
- Dekati kolam lalu tekan E untuk memasukkan bibit, memberi pakan, atau memanen sesuai kondisi kolam.
- Dekati Slime lalu tekan J/Space dua kali (25 damage per serangan; HP Slime 50).
- Setelah Slime kalah, inventory bertambah 1–2 Slime Gel.
- Ada peluang 10% memperoleh Bibit Basic tambahan.
- Slime tidak memberi EXP; progres Job Level tetap berasal dari Farm Value sesuai ketetapan desain.
- Save otomatis tiap 30 detik dan ketika jendela ditutup.

## Checklist status paket ini
- [x] Struktur proyek Godot dan aset dasar.
- [x] Gerakan karakter keyboard.
- [x] Interaksi kolam dasar.
- [x] Pertumbuhan/pakan/panen prototipe.
- [x] Save/load JSON dan backup.
- [x] Slime uji: AI mendekati pemain, menyerang, menerima damage, dan mati.
- [x] Loot material dan peluang bibit Basic.
- [ ] Pengujian runtime di Godot oleh pengguna.
- [ ] Kontrol sentuh Android.
- [ ] Animasi dan efek serangan/loot.
- [ ] Banyak jenis monster, AI dan balancing lengkap.
- [ ] Toko, penjualan item, crafting, breeding, quest.
- [ ] Peta desa, hutan, gua, dan Danger Zone.
- [ ] Sistem equipment, skill, audio, tutorial, dan UI final.
- [ ] Build APK Android dan pengujian perangkat.

## Catatan verifikasi
Source code repository diperiksa dan paket ini diperbarui berdasarkan source tersebut. Lingkungan pembuatan paket tidak menyediakan Godot Engine, sehingga saya tidak mengklaim proyek sudah lolos uji runtime. Checklist pengujian runtime tetap menunggu hasil saat proyek dijalankan di Godot.
