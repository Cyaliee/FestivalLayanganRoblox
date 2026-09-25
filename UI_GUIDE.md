# Panduan UI — Festival Layangan

Semua UI layar dibuat oleh kode (**Fusion 0.3**) dengan tone **gelap metalik**, mengikuti script
DonationMenu/Hotbar dan referensi Inventory: panel gelap (25,25,25), bar (20,18,26) transparan tipis,
tombol abu-abu dengan gradient metalik, stroke putih tipis, font Gotham, slot 44px.
Skala otomatis mengikuti tinggi layar (`/1080`, dibatasi 0.6–1.2) x pilihan **Ukuran UI** di Setting.

**Tidak ada emoji.** Semua ikon memakai gambar dari `Config/UIAssets.luau`; selama gambar kosong
tampil teks placeholder kecil (mis. "Bambu") supaya layout tetap bisa dites.

## Tata letak
| Elemen | Posisi | Keterangan |
|---|---|---|
| Kartu profil | kiri bawah | avatar bulat, `Lv. N`, kotak nama + uang (`Rp. ...`), bar EXP |
| Sidebar | kiri tengah | Shop, Inventory, Setting, Information + tombol `<` / `>` sembunyi/tampil |
| Hotbar | bawah tengah | slot 1-9 (slot 1 = kapak), tombol paling ujung = sembunyi/tampil |
| Notifikasi | atas tengah | meluncur dari atas |
| Pengumuman global | atas tengah (di bawah notifikasi) | stroke berwarna |

## Jendela
| Jendela | Dibuka dari |
|---|---|
| Shop (gamepass) | Sidebar |
| Inventory (klik item = pasang/lepas di hotbar) | Sidebar |
| Tas (upgrade) | tombol di header Inventory |
| Setting | Sidebar |
| Information | Sidebar |
| Pasar (Pengepul/Toko/Tengkulak) | prompt NPC |
| Rakit Layangan | prompt MejaRakit |
| Meja Rakit (upgrade) | Papan Nama kavling |

## Yang kamu isi
| File | Isi |
|---|---|
| `Config/UIAssets.luau` | `Icons` (sidebar, panah, uang, tas, dll.), `Items` (ikon per item), `Gamepasses` (gambar kartu Shop) |
| `Config/UITheme.luau` | warna, gradient metalik, font, ukuran slot/bar, animasi, skala |
| `Config/UIText.luau` | semua tulisan |
| `Config/Info.luau` | isi jendela Information |
| `Config/Settings.luau` | daftar pengaturan (Toggle / Choice) |
| `Config/Gamepasses.luau` | Id gamepass, nama, deskripsi |

Musik latar (opsional): taruh `Sound` bernama **Music** di `SoundService`; saklar Musik di Setting mengaturnya.

## Preview di UI Labs
Storybook **Festival Layangan**: `Button`, `ItemSlot`, `Toast`, `ProfileCard`, `Sidebar`, `Hotbar`,
`Inventory`, `ShopUI`, `MarketUI`, `CraftUI`, `SettingsUI`, `InfoUI`, `UpgradeUI`.

## Struktur kode UI
```
src/client/
  State/PlayerView.luau     data mentah -> teks/progress/isi hotbar
  State/PlayerState.luau    data pemain dari server (Fusion Value)
  State/UIState.luau        jendela terbuka, sidebar/hotbar buka-tutup, notifikasi, skala
  UI/Style.luau             sudut, stroke, gradient metalik, padding, list
  UI/Components/            Text, Icon, Button, Panel, Window, ProgressBar, ItemSlot,
                            Toast, Toggle, ScrollList, ProfileCard
  UI/Screens/               HUD, Sidebar, Hotbar, Inventory, BagUI, ShopUI, MarketUI,
                            CraftUI, UpgradeUI, SettingsUI, InfoUI, Announcement
  Controllers/UIController  memasang semua ScreenGui + bridge
  Controllers/SettingsController  musik
  Systems/craftTimers, treeHealth, nametags   billboard di dunia 3D
```

## World UI (dibuat di Studio)
| Path | Tipe | Dipakai untuk |
|---|---|---|
| `Workspace/Plots/<Plot>/PapanNama/**/OwnerText` | TextLabel di SurfaceGui (opsional) | "Kavling Kosong" / "Kavling <Nama>" |
