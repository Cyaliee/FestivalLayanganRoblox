# Panduan UI — Festival Layangan

Mulai Fase 2, **semua UI layar dibuat oleh kode (Fusion 0.3)** dengan gaya **Studded**
(meniru kit StuddedUI): warna solid + tekstur stud transparan, outline & bayangan bawah
berwarna gelap dari warna yang sama, teks FredokaOne putih ber-outline hitam, dan animasi spring.
Kamu tidak perlu menyusun UI di StarterGui lagi. Yang kamu isi hanyalah **gambar** dan (opsional) **tema**.

> Hapus ScreenGui lama buatan Studio (`HUD`, `Hotbar`, `UpgradeUI`, `ShopUI`, `SellUI`, `CraftUI`,
> `EventBanner`) dan folder `ReplicatedStorage/UITemplates`, supaya tidak dobel dengan UI dari kode.

## 1. Gambar — `src/shared/Config/UIAssets.luau`

| Bagian | Isi | Kalau kosong |
|---|---|---|
| `Icons.Coin`, `Bamboo`, `Kite`, `Bag`, `Close`, `Upgrade` | ikon di HUD & tombol | tampil emoji `Fallback` |
| `Items.<ItemId>` | ikon item di hotbar/toko (Id dari `Config/Items.luau`; semua rarity pakai ikon yang sama, warna slot beda) | tampil emoji `Fallback` |
| `Buttons.<Palette>` | skin **ImageButton** per warna tombol (`Green`, `Blue`, `Close`, `Orange`, ...) — opsional | tombol digambar kode (gaya Studded) |

Format asset: `"rbxassetid://1234567890"` (upload gambar lewat Asset Manager / Creator Dashboard,
lalu copy ID-nya).

Skin tombol boleh pakai 9-slice supaya tidak gepeng saat ukurannya berubah:
```lua
Primary = { Image = "rbxassetid://123", SliceCenter = Rect.new(24, 24, 104, 104) },
```

## 2. Tema — `src/shared/Config/UITheme.luau`

| Bagian | Isi |
|---|---|
| `Font`, `TitleFont` | font teks & judul |
| `Colors` | teks, outline teks, backdrop |
| `Palettes` | `{ Surface, Dark }` — warna dari kit (Red, Green, Blue, Cyan, Teal, Orange, Gold, Purple, Pink, ...) |
| `Roles` | warna per fungsi: tombol utama, koin, bambu, tas, tas penuh, slot, jendela upgrade, ... |
| `Profile` | kartu profil kiri bawah: palette panel, lencana level, kapsul uang, ukuran |
| `Studs` | tekstur stud (asset dari kit), ukuran tile, transparansi di tombol & jendela |
| `Sizes` | tebal outline, radius sudut, tinggi bayangan, ukuran pill/slot/toast |
| `Animation` | skala hover/tekan, kecepatan & damping spring, posisi toast |
| `ReferenceResolution`, `MinScale`, `MaxScale` | UI diskalakan otomatis sesuai layar |

## 3. Teks — `src/shared/Config/UIText.luau`
Semua tulisan di UI (format level, EXP, tas, judul jendela, pemisah ribuan).

## 4. Preview di UI Labs
1. Install plugin **UI Labs** dari Creator Store.
2. Jalankan `rojo serve` dan Connect (tidak perlu Play).
3. Buka UI Labs → storybook **Festival Layangan**. Story yang tersedia:
   `StudButton`, `ProgressBar`, `StatPill`, `HotbarSlot`, `Toast`, `Window`, `HUD`, `Hotbar`,
   `UpgradeUI`, `BagUI`, `ShopUI`, `CraftUI`, `ProfileCard`.
   Ubah nilai di panel Controls untuk mencoba data mock.

## 5. Yang masih dibuat di Studio (world UI)

| Path | Tipe | Dipakai untuk |
|---|---|---|
| `Workspace/Plots/<Plot>/PapanNama/**/OwnerText` | TextLabel di SurfaceGui (opsional) | "Kavling Kosong" / "Kavling <Nama>" |

## Struktur kode UI
```
src/client/
  State/PlayerView.luau    data mentah -> teks/progress (dipakai game & story)
  State/PlayerState.luau   data pemain dari server (Fusion Value)
  State/UIState.luau       screen terbuka, slot terpilih, notifikasi, skala layar
  UI/Style.luau            palette, outline, sudut, stud, padding
  UI/Components/           Block (dasar Studded), Label, Icon, Panel, StudButton, ProgressBar,
                           StatPill, HotbarSlot, Toast, Window, ListRow, ScrollList, ProfileCard
  Systems/nametags         nametag "DisplayName | Lv.xxx" di atas kepala (Fusion, client)
  Systems/craftTimers      billboard countdown di atas MejaRakit (Fusion, client)
  Systems/treeHealth       bar HP pohon bambu (Fusion, client)
  UI/Screens/              HUD, Hotbar, UpgradeUI, BagUI, ShopUI (per NPC), CraftUI, Announcement
  UI/Stories/              story UI Labs
  Controllers/UIController memasang ScreenGui + bridge OpenUI/Notify
```

## Memakai gambar dari kit StuddedUI
Gambar ikon di kit bisa dipakai ulang: di Studio pilih ImageLabel `Artwork`/`Icon` di kit,
copy properti `Image` (mis. `rbxassetid://129096757816558`), lalu tempel ke `UIAssets.luau`.
Kit-nya sendiri tidak perlu dimasukkan ke game.
