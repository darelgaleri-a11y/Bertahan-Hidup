# BERTAHAN HIDUP — PROJECT CONTINUATION CONTEXT
Tanggal checkpoint: 22 November 2026
Repositori: https://github.com/darelgaleri-a11y/Bertahan-Hidup.git
Branch yang diperiksa: `main`
Commit/tree basis yang diperiksa: tree SHA `91038f23f5833d93069a7a59677ae9d6880c00e1`
Engine: Godot 4.x (project feature 4.3, GL Compatibility)
Target: Android dan desktop untuk pengembangan/pengujian
Gaya visual tetap: Detailed Pixel Art, tile dasar 16×16 px, objek lingkungan 32×32 px.

## Aturan kerja yang harus dipertahankan
1. Lanjutkan produksi game bertahap; jangan mengubah arah desain yang sudah ditetapkan.
2. Untuk tiap tahap, periksa isi repositori GitHub terbaru terlebih dahulu.
3. Jangan commit/push atau mengubah GitHub secara langsung. Berikan ZIP patch yang hanya memuat file baru/berubah.
4. Pengguna meminta bug diperbaiki nanti, bukan sekarang. Catat temuan bug/risiko untuk tahap QA terpisah; jangan melakukan refactor/perbaikan diam-diam.
5. Sertakan selalu: isi ZIP, lokasi ekstraksi, cara menjalankan, hasil yang diharapkan, checklist progres, dan langkah berikutnya.
6. Bedakan pemeriksaan statis dengan pengujian runtime. Jangan mengklaim sudah diuji di Godot jika belum benar-benar dijalankan.
7. Saat membuat patch `main.tscn`, pertahankan semua node, resource, dan sistem yang sudah ada. Jangan mengganti file besar secara ceroboh.

## Ketetapan desain dan proyek
- Game survival/peternakan dengan eksplorasi wilayah, monster, loot, ekonomi, breeding, quest, equipment, stats, skill, kepemilikan lahan, save/load.
- Visual Detailed Pixel Art; tile dasar 16×16.
- Android menjadi target penting; UI touch controls sudah ada dalam `scripts/ui/main.gd`.
- Navigasi wilayah saat ini melalui tombol `M` / tombol WILAYAH di UI mobile. Belum menggunakan pintu fisik antar-map.
- Sistem wilayah memakai `RegionManager` dan `data/region_catalog.json`.

## Tahapan visual yang telah dibuat
- Asset 008: Environment & World Details (tahap perencanaan/produksi aset lingkungan).
- Asset 009: UI & HUD.
- Asset 010: Audio & Sound Effects.
- Asset 011: region ground sheets dan object atlas dasar.
- Asset 012: TileSet resources.
- Asset 013–015: peta Desa dan integrasi ke `scenes/main.tscn`.
- Asset 016–018: peta, props, dan integrasi Hutan.
- Asset 019: peta, props, dan integrasi Gua.
- Asset 020: integrasi lingkungan Zona Bahaya (patch ini).

## Sistem gameplay yang terlihat dalam repositori
Fondasi/implementasi kode tersedia untuk:
- Player movement, health, combat, touch controls.
- Monster base, AI chase/attack, defeat, loot, respawn.
- Inventory dan katalog item.
- Farm/kolam ikan.
- NPC, shop, breeding.
- Quest, equipment, stats, skills.
- Property/land dan relocation.
- Save/load.
- Region manager dan katalog Desa, Hutan, Gua, Zona Bahaya.

Penting: keberadaan kode bukan bukti seluruh sistem telah diuji atau berfungsi sempurna. Status runtime/QA belum dikonfirmasi.

## Status wilayah pada basis repositori
- Desa: scene utama/ground terpasang.
- Hutan: `forest_map.tscn` dan `forest_environment.gd` terpasang.
- Gua: `cave_map.tscn` dan `cave_environment.gd` terpasang.
- Zona Bahaya: katalog wilayah dan monster sudah ada; Asset 020 menambahkan scene lingkungan dan integrasi visual.

## Temuan yang ditunda untuk audit bug
- `data/monster_catalog.json` menyebut Monster Buas Elite membutuhkan Job Level 4, sedangkan `scenes/monsters/elite_beast.tscn` menetapkan `required_job_level = 5`; katalog wilayah Zona Bahaya meminta Job Level 5. Jangan ubah tanpa instruksi/tahap QA.
- Scene lingkungan Hutan/Gua/Zona Bahaya masing-masing mengubah visibilitas ground/pond/NPC desa. Perlu diuji perpindahan wilayah bolak-balik di Godot untuk memastikan tidak ada kondisi tampilan yang tertinggal.
- Belum ada bukti pengujian runtime Godot pada patch Asset 020.
- Trap/vent di Zona Bahaya masih visual, belum mekanik damage.

## Checklist status checkpoint
- [x] Gaya visual Detailed Pixel Art dan ukuran tile 16×16 ditetapkan.
- [x] Struktur dasar proyek Godot dan sistem wilayah tersedia.
- [x] Asset 011–012: ground/tileset dasar.
- [x] Asset 013–015: Desa.
- [x] Asset 016–018: Hutan.
- [x] Asset 019: Gua.
- [x] Asset 020: integrasi visual Zona Bahaya disiapkan dalam patch.
- [ ] Jalankan Asset 020 di Godot dan verifikasi tampilan semua wilayah.
- [ ] Audit dan perbaiki bug (ditunda sesuai permintaan).
- [ ] Implementasi interaksi resource gathering (bijih/kristal/batu/kayu).
- [ ] Implementasi hazard/trap yang memberi efek gameplay.
- [ ] Poles transisi wilayah dan batas peta.
- [ ] QA menyeluruh sistem gameplay.
- [ ] Optimasi Android, kontrol, UI, dan performa.
- [ ] Build Android final dan pengujian perangkat.

## Langkah berikutnya yang disarankan
Asset 021: Resource Gathering & Interactable Environment — menambahkan titik pengumpulan resource di Hutan/Gua/Zona Bahaya dengan drop item yang memakai InventoryManager/LootManager yang sudah ada. Sebelum mengubah kode, periksa lagi implementasi inventory, loot, dan scene region terbaru. Jangan memperbaiki bug lama kecuali pengguna sudah meminta masuk tahap QA.

## Cara memulai percakapan baru
Unggah ZIP patch/checkpoint ini atau salin isi `CONTINUATION_PROMPT_NEW_CHAT.md`, lalu minta asisten membaca konteks dan melanjutkan Asset 021.
