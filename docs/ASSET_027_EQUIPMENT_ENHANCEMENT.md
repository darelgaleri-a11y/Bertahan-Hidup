# Asset 027 — Equipment Enhancement & Enchantment System

## File yang diperbarui
- `scripts/autoload/equipment_manager.gd`

Sistem menggunakan EquipmentManager yang sudah terdaftar sebagai Autoload di `project.godot`, sehingga tidak perlu menambahkan Autoload baru atau mengubah scene utama.

## Fitur
- Menu Enhancement & Enchantment dibuka dengan tombol `U`.
- Peningkatan hanya berlaku pada perlengkapan yang sedang dipakai.
- Level maksimum +5.
- Peningkatan tidak menggunakan peluang acak; jika bahan cukup, peningkatan berhasil.
- Level enhancement disimpan pada data save EquipmentManager dan dimuat kembali.
- Bonus atribut masuk ke `get_total_stat()` sehingga sistem yang membaca total stat perlengkapan menerima nilai yang sudah ditingkatkan.

## Bonus per level
- Weapon: +2 Attack.
- Armor: +1 Defense dan +5 Max Health.
- Boots: +2 Move Speed.
- Accessory: +1 Attack, +1 Defense, +2 Max Health.

## Biaya per level tujuan
Biaya dasar dikalikan dengan level tujuan. Contoh: peningkatan armor ke +3 memerlukan 3 Batangan Besi dan 6 Batu.
- Weapon: 1 Iron Ingot + 1 Blue Crystal.
- Armor: 1 Iron Ingot + 2 Stone.
- Boots: 2 Wood + 1 Blue Crystal.
- Accessory: 1 Purple Crystal + 1 Ancient Shard.

## Cara memasang
1. Backup folder proyek.
2. Pastikan versi proyek memiliki Asset 026 dan `EquipmentManager` terdaftar pada Autoload.
3. Ekstrak ZIP ini ke root folder proyek Godot, pertahankan struktur folder.
4. Timpa `scripts/autoload/equipment_manager.gd` versi sebelumnya.
5. Buka proyek di Godot 4.x dan jalankan dengan F5.

## Cara mencoba
1. Dapatkan perlengkapan dan pakai melalui sistem Equipment yang sudah ada.
2. Kumpulkan material sesuai slot.
3. Tekan `U`.
4. Periksa nama perlengkapan, level, bonus, dan biaya.
5. Klik tombol tingkatkan.
6. Periksa bonus atribut dan level bertambah.
7. Simpan, tutup, lalu buka kembali game untuk memastikan level enhancement tetap ada.

## Batasan tahap ini
- Ini peningkatan stat permanen, bukan efek visual partikel atau animasi enchant.
- Belum ada risiko gagal, batu pelindung, reroll, atau pemindahan enchant.
- Belum diuji melalui parser/runtime Godot atau Android pada tahap pembuatan paket ini.
- Perbaikan bug menyeluruh tetap ditunda sampai QA sesuai arahan proyek.
