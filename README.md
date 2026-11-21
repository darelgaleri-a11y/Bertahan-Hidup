# Bertahan Hidup — Equipment System & Bugfix Update

Proyek game 2D top-down untuk Godot 4.x, target Android landscape, dengan gaya Detailed Pixel Art dan ukuran dasar tile 16×16 pixel.

## Fitur yang tersedia dalam paket

### Pemain dan dunia
- Gerakan pemain dengan keyboard dan kontrol sentuh.
- HP pemain, serangan, respawn, dan HUD.
- Slime mengejar dan menyerang pemain; Slime muncul kembali 5 detik setelah dikalahkan.
- NPC Pedagang, Ahli Breeding, Pengelola Lahan, dan Papan Misi.

### Farming dan ekonomi
- Kolam ikan: masukkan bibit, beri pakan, pertumbuhan offline, dan panen.
- Farm Value dan Job Level berdasarkan hasil panen.
- Inventory 30 slot, stack, penjualan item, dan Peti Loot untuk loot yang tidak tertampung.
- Toko menjual bibit, pakan, serta empat perlengkapan awal.
- Sistem breeding Basic → Advanced → Rare → Epic → Legendary.
- Sewa/beli lahan, persyaratan Job Level, relokasi NPC/gerobak.
- Save/load JSON dengan backup.

### Equipment System
Empat slot perlengkapan:
- Weapon — Pedang Kayu: +10 ATK.
- Armor — Baju Kain: +2 DEF, +10 HP maksimum.
- Boots — Sepatu Kulit: +12 kecepatan gerak.
- Accessory — Cincin Tembaga: +2 ATK, +1 DEF, +5 HP maksimum.

Cara memakai perlengkapan:
1. Dekati Pedagang dan tekan E dua kali untuk membuka toko.
2. Beli perlengkapan yang diinginkan.
3. Tekan I atau tombol TAS untuk membuka inventory.
4. Tekan **Pakai** di samping item perlengkapan.
5. Ringkasan slot dan bonus statistik terlihat pada panel inventory.
6. Tekan **Lepas** untuk mengembalikan item ke inventory.
7. Jika inventory penuh, pelepasan atau pergantian perlengkapan ditolak agar item tidak hilang.

Bonus equipment memengaruhi damage serangan, pengurangan damage masuk, HP maksimum, dan kecepatan gerak. Perlengkapan tersimpan di save game.

### Quest & Mission
- Panen Pertama: panen 1 kali, hadiah 100 Money.
- Pemburu Slime: kalahkan 3 Slime, hadiah 150 Money.
- Pengumpul Gel: kumpulkan 5 Slime Gel ke inventory, hadiah 125 Money.
- Progres misi otomatis tercatat dari event gameplay.
- Hadiah hanya bisa diklaim satu kali dan statusnya tersimpan.

## Kontrol

| Tombol | Fungsi |
|---|---|
| WASD / Panah | Bergerak |
| E | Interaksi dengan NPC/kolam |
| J / Space | Menyerang |
| I | Inventory dan perlengkapan |
| B | Toko |
| Q | Papan Misi |
| P | Status karakter |
| Escape | Menutup panel |

Di layar sentuh tersedia tombol gerak, INTERAKSI, SERANG, TAS, TOKO, MISI, dan STATUS.

## Cara menjalankan

1. Ekstrak ZIP.
2. Buka Godot 4.3 atau Godot 4.x yang kompatibel.
3. Pada Project Manager, pilih **Import**.
4. Pilih file `project.godot` di dalam folder `Bertahan_Hidup_Godot`.
5. Tunggu proses import selesai.
6. Tekan **F5** untuk menjalankan.

## Hasil yang diharapkan saat diuji

- Pemain muncul di desa dengan 250 Money dan inventory awal.
- NPC dapat membuka toko, breeding, properti, dan papan misi.
- Membeli perlengkapan mengurangi Money dan menambahkan item ke inventory.
- Memakai Pedang Kayu meningkatkan damage serangan dari 25 menjadi 35.
- Memakai Baju Kain menambahkan +2 Defense dan +10 HP maksimum di atas status dasar karakter. Dengan Defense dasar 5, serangan Slime 5 damage akan berkurang hingga minimum 1.
- Memakai Sepatu Kulit meningkatkan kecepatan gerak dari 110 menjadi 122.
- Memakai Cincin Tembaga menambah ATK 2, DEF 1, dan HP maksimum 5.
- Pergantian perlengkapan mengembalikan item lama ke inventory.
- Progres quest bertambah ketika panen, mengalahkan Slime, dan memasukkan Slime Gel ke inventory.
- Equipment dan progres quest tetap tersimpan setelah game dibuka ulang.
- Panel STATUS menampilkan enam atribut. Pada Job Level 1 nilai awalnya STR 10, VIT 10, DEF 5, AGI 5, ABILITY 5, dan STA 10.
- Setiap Job Level berikutnya menambah STR +2, VIT +2, DEF +1, AGI +1, ABILITY +1, dan STA +2.
- Status aktif: Strength menambah damage, Vitality menambah HP maksimum, Defense mengurangi damage masuk, dan Agility menambah kecepatan gerak.

## Checklist perkembangan game

- [x] Struktur proyek Godot 4.x dan asset dasar Detailed Pixel Art 16×16.
- [x] Gerakan pemain, kontrol sentuh dasar, HUD, HP, dan respawn.
- [x] Kolam ikan, bibit, pakan, pertumbuhan offline, panen, Farm Value, dan Job Level.
- [x] Save/load JSON dan backup.
- [x] Slime AI, combat, loot material, peluang drop bibit, dan respawn Slime.
- [x] Inventory 30 slot, stack, penjualan item, dan Peti Loot overflow.
- [x] Toko dan pembelian item.
- [x] NPC Pedagang, Ahli Breeding, Pengelola Lahan, dan Papan Misi.
- [x] Breeding lima tier.
- [x] Sewa/beli lahan, syarat Job Level, dan relokasi NPC/gerobak.
- [x] Quest awal, progres otomatis, klaim hadiah satu kali, dan penyimpanan progres.
- [x] Equipment empat slot, equip/unequip, bonus statistik, dan penyimpanan equipment.
- [x] Character Stats dasar (Strength, Vitality, Defense, Agility, Ability, Stamina), panel status, dan peningkatan otomatis dari Job Level.
- [ ] Implementasi efek Ability melalui Skill System dan konsumsi Stamina untuk aktivitas.
- [ ] Sistem skill dan peningkatan skill.
- [ ] Penyimpanan kolam terpisah untuk setiap lahan dan penempatan bangunan.
- [ ] Monster tambahan, hutan, gua, Danger Zone, dan quest lanjutan.
- [ ] Audio final, tutorial, polish UI, dan optimasi.
- [ ] Pengujian parser/runtime Godot secara menyeluruh.
- [ ] Pengujian perangkat Android dan build APK.

## Audit dan batas verifikasi

Pada paket ini diperbaiki event quest panen, event pengumpulan Slime Gel, event pembunuhan Slime, dan penyimpanan progres quest yang sebelumnya belum terhubung dengan benar. Pemeriksaan statis juga dilakukan pada katalog JSON, referensi `res://`, resource scene, fungsi duplikat, serta simulasi transaksi equipment, progres quest, dan rumus status Job Level 1–2.

Godot executable tidak tersedia pada lingkungan pembuatan paket ini. Karena itu parser GDScript, runtime gameplay, dan perangkat Android belum dapat dinyatakan lulus. Harga item dan keseimbangan bonus equipment masih nilai prototipe yang dapat disesuaikan setelah playtest.

## Status Karakter (Character Stats)
- Tekan **P** atau tombol **STATUS** pada layar sentuh untuk membuka panel status.
- Enam atribut ditampilkan: Strength, Vitality, Defense, Agility, Ability, dan Stamina.
- Atribut meningkat otomatis ketika Job Level naik. Tidak ada poin yang perlu dialokasikan.
- Strength menambah damage dasar, Vitality menambah HP maksimum, Defense mengurangi damage masuk, dan Agility menambah kecepatan gerak.
- Ability dan Stamina saat ini merupakan atribut dasar yang disiapkan untuk Skill System dan Stamina System pada tahap berikutnya.
- Bonus equipment ditambahkan pada efek atribut yang sudah aktif.
