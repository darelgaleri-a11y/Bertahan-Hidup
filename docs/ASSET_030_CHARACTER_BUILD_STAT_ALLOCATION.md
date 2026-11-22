# Asset 030 — Character Build & Stat Allocation

## Tujuan
Menambahkan sistem pembentukan karakter yang dapat dipilih pemain. Pertumbuhan atribut otomatis dari Job Level tetap berjalan; poin alokasi merupakan lapisan tambahan dan tidak menggantikan sistem lama.

## Perubahan
- `StatsManager` kini menyimpan alokasi enam atribut: Strength, Vitality, Defense, Agility, Ability, dan Stamina.
- Pemain memperoleh **2 poin atribut setiap kenaikan Job Level** setelah Job Level 1.
- Batas alokasi tambahan: **20 poin per atribut**.
- Panel Character Build dibuka dengan tombol **V** pada keyboard atau tombol **BUILD** pada layar sentuh.
- Data alokasi disimpan pada properti `character_build` di save JSON.
- Save lama tetap dapat dibaca. Jika save belum memiliki `character_build`, alokasi dimulai dari nol; poin yang belum dipakai dihitung berdasarkan Job Level saat ini.

## Dampak setiap poin alokasi
| Atribut | Efek tambahan |
|---|---|
| Strength | +1 damage serangan dasar |
| Vitality | +5 HP maksimum |
| Defense | Mengurangi 1 damage masuk, minimum damage tetap 1 |
| Agility | +2 kecepatan gerak |
| Ability | Meningkatkan bonus Ability pada Power Strike dan Recovery |
| Stamina | +10 stamina maksimum dan +0,1 regenerasi stamina/detik |

Pertumbuhan otomatis Job Level yang sudah ada tetap berlaku di luar bonus alokasi tersebut.

## Cara menjalankan
1. Tutup game dan buat salinan cadangan folder proyek.
2. Ekstrak ZIP ini.
3. Salin folder `scripts` dan file `project.godot` ke root proyek Godot, lalu izinkan penggabungan folder.
4. Jika diminta mengganti file, pastikan backup sudah dibuat. File yang diganti tercantum di `PATCH_FILE_LIST.txt`.
5. Buka proyek menggunakan Godot 4.3 atau versi 4.x yang kompatibel.
6. Tekan **F5**.
7. Tekan **V** untuk membuka Character Build, atau gunakan tombol **BUILD** pada layar sentuh.
8. Naikkan Job Level melalui progres Farm Value untuk memperoleh poin. Pilih atribut dengan tombol `+1`.

## Hasil yang diharapkan
- Job Level 1: 0 poin alokasi.
- Job Level 2: 2 poin alokasi tersedia.
- Job Level 3: 4 poin total tersedia sebelum alokasi.
- Setelah mengalokasikan 1 poin Strength, damage serangan dasar bertambah 1 di luar pertumbuhan otomatis Job Level.
- Setelah mengalokasikan 1 poin Vitality, HP maksimum bertambah 5.
- Setelah mengalokasikan 1 poin Defense, damage masuk berkurang 1 (tetap minimum 1).
- Alokasi tidak dapat dilakukan jika poin habis atau atribut mencapai batas +20.
- Setelah keluar dan membuka game kembali, alokasi atribut tetap tersimpan.

## Checklist proyek
- [x] Character Stats dasar dan pertumbuhan otomatis Job Level (sudah ada sebelumnya).
- [x] Skill System, level skill, spesialisasi, dan bonus pasif (Asset 028–029).
- [x] Poin alokasi atribut dan panel Character Build (Asset 030).
- [x] Penyimpanan dan pemuatan alokasi karakter.
- [ ] Uji parser GDScript di Godot 4.3.
- [ ] Uji runtime: alokasi semua atribut, batas +20, dan save/load.
- [ ] Uji regresi: HP, stamina, skill, equipment, dan progression setelah alokasi.
- [ ] Uji kontrol sentuh dan layout Android.
- [ ] Build APK dan uji perangkat Android.

## Catatan audit / risiko yang belum diperbaiki
- `README.md` di branch saat pemeriksaan masih memiliki uraian lama yang menyebut Skill System belum aktif, padahal kode SkillManager dan SkillPassiveManager sudah tersedia. README tidak diubah pada paket ini.
- Pemeriksaan ini bersifat statis. Parser Godot, runtime gameplay, dan perangkat Android belum dijalankan.
- UI Character Build dibuat sebagai panel Autoload terpisah agar tidak perlu mengganti `main.gd`. Posisi tombol sentuh perlu diperiksa pada resolusi perangkat sebenarnya.
- `SAVE_VERSION` tetap 7 karena properti `character_build` bersifat tambahan dan opsional untuk kompatibilitas save lama. Pengujian save/load tetap wajib dilakukan.
