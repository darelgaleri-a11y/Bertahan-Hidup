# Asset 025 — Tool Gameplay Integration

## Perubahan file
- `project.godot` — mendaftarkan ToolManager setelah InventoryManager.
- `scripts/autoload/tool_manager.gd` — memilih alat terbaik dari inventory.
- `scripts/resources/resource_gather_node.gd` — menolak gathering tanpa alat yang cocok dan memberi bonus hasil untuk alat besi.
- `scripts/autoload/crafting_manager.gd` — resep kapak/beliung kayu serta resep alat besi.
- `data/item_catalog.json` — katalog dipertahankan dari struktur item repositori yang diperiksa dan ditambah item crafting/peralatan dari tahapan sebelumnya serta metadata alat.

## Perilaku yang diharapkan
- Pohon dengan tool_type `axe` hanya dapat dipanen jika pemain memiliki Kapak Kayu atau Kapak Besi.
- Node mineral dengan tool_type `pickaxe` hanya dapat ditambang jika pemain memiliki Beliung Kayu atau Beliung Besi.
- Jamur dengan tool_type `hand` tetap dapat dikumpulkan tanpa alat.
- Alat besi diprioritaskan otomatis jika pemain memiliki alat kayu dan besi sekaligus.
- Alat besi memberi tambahan 1 unit hasil per aksi dibanding alat kayu.
- Alat disimpan di inventory, sehingga tercakup oleh mekanisme save inventory yang sudah ada.
- Saat inventory penuh, hasil gathering tetap diarahkan ke LootManager seperti perilaku sebelumnya.

## Pemasangan
1. Buat backup proyek.
2. Pasang Asset 021, 022, 023, dan 024 terlebih dahulu secara berurutan bila belum dipasang.
3. Ekstrak ZIP ini ke folder utama proyek Godot, timpa hanya file dengan nama sama.
4. Buka `project.godot` di Godot 4.x dan jalankan F6/F5.

## Uji manual
1. Pergi ke hutan tanpa kapak, dekat pohon, tekan E: harus muncul pemberitahuan membutuhkan kapak dan tidak ada kayu yang ditambahkan.
2. Buat Kapak Kayu lewat menu crafting (C), kembali ke pohon, tekan E: kayu bertambah.
3. Dekati batu/kristal tanpa beliung: harus ditolak.
4. Buat Beliung Kayu: node mineral bisa ditambang.
5. Buat Meja Kerja Dasar, lalu Kapak/Beliung Besi; alat besi harus terpilih otomatis dan memberi +1 hasil.
6. Dekati jamur: tetap bisa dikumpulkan dengan tangan.
7. Simpan dan jalankan ulang: alat tetap berada di inventory.

## Batas dan status pengujian
- Tidak ada durability atau kerusakan alat pada tahap ini.
- Alat belum memiliki slot equip khusus; sistem otomatis memilih alat terbaik yang ada di inventory.
- Belum diuji parser/runtime Godot, animasi, atau Android dalam sesi pembuatan paket.
- Aset visual ayunan alat yang digunakan tetap berasal dari Asset 022.
