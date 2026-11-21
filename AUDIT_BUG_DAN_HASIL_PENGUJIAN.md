# Laporan Audit Bug & Pengujian — Bertahan Hidup

## Repository yang diperiksa
- https://github.com/darelgaleri-a11y/Bertahan-Hidup.git
- Branch: `main`
- Pemeriksaan dilakukan terhadap struktur repository dan file implementasi yang tersedia.
- ZIP ini merupakan paket kerja lokal yang diselaraskan dengan repository dan memuat pembaruan terbaru; tidak ada commit yang dikirim ke GitHub.

## Temuan bug yang diperbaiki
1. **Quest Panen Pertama tidak bertambah** — event panen sukses belum memanggil QuestManager. Hook ditambahkan setelah panen berhasil.
2. **Quest Pengumpul Gel tidak bertambah** — InventoryManager belum meneruskan penambahan item ke QuestManager. Event `collect_item` ditambahkan.
3. **Quest Pemburu Slime tidak bertambah** — kematian Slime belum mencatat event monster. Event `monster_kill` ditambahkan saat Slime benar-benar mati.
4. **Progres quest tidak tersimpan** — SaveManager sebelumnya tidak memasukkan data quest ke save/load. Penyimpanan progres, status selesai, dan klaim hadiah ditambahkan.
5. **Respawn setelah relokasi** — pemain sekarang kembali ke spawn lahan aktif.
6. **Inventory dan Peti Loot saat memuat save** — data non-numerik/ID item tidak dikenal disaring dan kapasitas inventory dibatasi 30 slot.
7. **Data lahan rusak** — status lahan disanitasi saat load.
8. **Sistem equipment baru** — menambahkan transaksi equip/unequip yang mengembalikan item lama ke inventory, validasi slot, dan penyimpanan equipment.

## Equipment yang tersedia
- Pedang Kayu: +10 ATK
- Baju Kain: +2 DEF, +10 HP maksimum
- Sepatu Kulit: +12 kecepatan gerak
- Cincin Tembaga: +2 ATK, +1 DEF, +5 HP maksimum

Slot: Weapon, Armor, Boots, Accessory. Bonus diterapkan pada damage serangan pemain, pengurangan damage yang diterima, HP maksimum, dan kecepatan gerak.

## Hasil pemeriksaan statis
- Semua 4 katalog JSON berhasil dibaca.
- Tidak ditemukan referensi `res://` yang menunjuk file hilang.
- Semua nilai `load_steps` scene sesuai jumlah resource.
- Tidak ditemukan nama fungsi duplikat dalam file GDScript.
- Integrasi save/load quest dan equipment terdeteksi pada source.
- Hook panen, penambahan Slime Gel, dan kematian Slime terdeteksi.
- Simulasi transaksi ganti/lepas equipment dan progres quest lulus.
- ZIP diuji integritasnya.

## Batas pengujian
Godot tidak tersedia pada lingkungan pembuatan ZIP ini. Karena itu parser GDScript, runtime scene, gameplay sesungguhnya, dan perangkat Android belum dapat dinyatakan lulus. Pemeriksaan statis bukan pengganti pengujian langsung di Godot.
