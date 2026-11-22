# Asset 029 — Skill Passive Bonuses & Character Build

## Pemeriksaan dasar
Patch mengikuti `SkillManager` yang ada di repositori: level skill tersedia melalui `get_skill_level(skill_id)`. Data progres skill sudah disimpan oleh `SaveManager` melalui `SkillManager.get_save_data()`. Karena bonus dihitung dari level skill, tidak diperlukan perubahan format save.

## Bonus pasif
- **Power Strike:** setiap level di atas Level 1 memberi +3% damage serangan dasar. Contoh: Level 2 = +3%, Level 5 = +12%.
- **Recovery:** setiap level di atas Level 1 memberi +5 HP maksimum dan +0,5 regenerasi stamina per detik. Contoh: Level 5 = +20 HP maksimum dan +2,0 regenerasi stamina/detik.

Bonus bersifat otomatis, dapat ditumpuk dengan bonus Stats dan Equipment, dan mengikuti level skill yang tersimpan. Spesialisasi Asset 028 tetap terpisah dan tidak dihapus.

## File patch
- `scripts/autoload/skill_passive_manager.gd` — manager bonus pasif baru.
- `scripts/autoload/skill_manager.gd` — menghubungkan bonus regenerasi stamina Recovery.
- `scripts/player/player.gd` — mengintegrasikan bonus damage dan HP maksimum ke karakter.
- `project.godot` — mendaftarkan `SkillPassiveManager` sebagai Autoload.
- `PATCH_FILE_LIST.txt` — daftar file.

## Cara memasang
1. Tutup game dan buat backup folder proyek.
2. Ekstrak ZIP ke root proyek Godot.
3. Izinkan tiga file di atas ditimpa/dibuat sesuai struktur folder.
4. Buka `project.godot` dan pastikan Autoload `SkillPassiveManager` tercantum satu kali.
5. Jalankan proyek dengan Godot 4.3 atau Godot 4.x kompatibel.

## Cara mencoba
1. Gunakan Power Strike sampai skill naik level.
2. Periksa damage serangan dasar sebelum dan sesudah kenaikan level.
3. Naikkan Recovery dan periksa HP maksimum serta regenerasi stamina.
4. Simpan game, tutup, lalu buka kembali. Bonus harus mengikuti level skill yang dimuat.

## Hasil yang diharapkan
- Bonus Power Strike otomatis meningkatkan damage serangan normal.
- Bonus Recovery otomatis meningkatkan HP maksimum dan regenerasi stamina.
- Tidak ada pilihan build tambahan yang perlu disimpan; build karakter ditentukan oleh level kedua skill.
- Data save lama tetap dapat digunakan karena tidak ada field save baru.

## Status validasi
Arsip ZIP diperiksa integritasnya. Source yang disediakan ditulis mengikuti API SkillManager dan Player yang ditemukan di branch `main`. Godot tidak tersedia pada lingkungan pembuatan arsip, sehingga parser GDScript, runtime, dan Android belum diuji. Jangan menganggap patch telah lolos QA sebelum menjalankannya di Godot.
