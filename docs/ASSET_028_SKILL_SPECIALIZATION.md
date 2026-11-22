# Asset 028 — Skill Specialization

## Fitur yang ditambahkan
- Memperluas `SkillManager` yang sudah ada; tidak mengganti arsitektur skill.
- Power Strike Level 2: pilih salah satu spesialisasi:
  - **Berserker**: damage Power Strike +25%.
  - **Focused**: biaya stamina Power Strike -25%.
- Recovery Level 2: pilih salah satu:
  - **Renewal**: pemulihan HP Recovery +30%.
  - **Efficient**: cooldown Recovery -25%.
- Pilihan spesialisasi permanen dan tersimpan pada data save di bagian `skills.specializations`.
- Save lama yang belum memiliki data spesialisasi tetap dimuat dengan pilihan kosong.
- Menu spesialisasi melalui tombol **N** di keyboard atau tombol **TALENTA** pada layar sentuh.

## Cara memasang
1. Tutup game dan buat backup folder proyek.
2. Ekstrak ZIP ke root proyek Godot, pertahankan struktur folder.
3. Izinkan `scripts/autoload/skill_manager.gd` ditimpa.
4. Jangan ubah `project.godot`; Autoload `SkillManager` sudah terdaftar.
5. Buka proyek dengan Godot 4.3 atau Godot 4.x yang kompatibel, lalu jalankan `scenes/main.tscn`.

## Cara mencoba
1. Naikkan skill sampai Level 2 dengan menggunakan skill berhasil sebanyak 5 kali.
2. Tekan **N** (desktop) atau **TALENTA** (layar sentuh).
3. Pilih satu spesialisasi untuk skill yang sudah Level 2.
4. Gunakan skill dan amati efek spesialisasi.
5. Simpan/keluar lalu masuk kembali untuk memastikan pilihan tetap tersimpan.

## Hasil yang diharapkan
- Opsi spesialisasi terkunci sebelum skill Level 2.
- Setelah Level 2, pemain dapat memilih tepat satu opsi untuk tiap skill.
- Pilihan tidak dapat diganti melalui menu.
- Efek pilihan diterapkan saat skill digunakan.
- Data spesialisasi ikut tersimpan melalui `SaveManager` yang sudah menyimpan `SkillManager.get_save_data()`.

## Batasan dan status pengujian
- Patch ini hanya mengubah `scripts/autoload/skill_manager.gd`; tidak mengubah `main.gd`, `project.godot`, aset visual, atau data item.
- Arsip dan struktur patch diperiksa setelah dibuat.
- Godot tidak tersedia pada lingkungan pembuatan ZIP ini; parser GDScript, runtime, serta build Android belum dijalankan. Pengujian tersebut masuk checklist QA berikutnya.
- Bug/temuan lama tidak diperbaiki dalam tahap ini.
