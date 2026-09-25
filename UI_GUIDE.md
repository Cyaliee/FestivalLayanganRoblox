# Panduan UI — Festival Layangan

Mulai Fase 2, **semua UI layar dibuat oleh kode (Fusion 0.3)** dengan gaya cartoon simulator:
outline tebal, sudut bulat, gradient, tombol "timbul", dan animasi spring.
Kamu tidak perlu menyusun UI di StarterGui lagi. Yang kamu isi hanyalah **gambar** dan (opsional) **tema**.

> Hapus ScreenGui lama buatan Studio (`HUD`, `Hotbar`, `UpgradeUI`, `ShopUI`, `SellUI`, `CraftUI`,
> `EventBanner`) dan folder `ReplicatedStorage/UITemplates`, supaya tidak dobel dengan UI dari kode.

## 1. Gambar — `src/shared/Config/UIAssets.luau`

| Bagian | Isi | Kalau kosong |
|---|---|---|
| `Icons.Coin`, `Bamboo`, `Kite`, `Bag`, `Close`, `Upgrade` | ikon di HUD & tombol | tampil emoji `Fallback` |
| `Items.<ItemId>` | ikon item di hotbar (Id dari `Config/Items.luau`) | tampil emoji `Fallback` |
| `Buttons.<Variant>` | skin **ImageButton** per varian tombol (`Primary`, `Secondary`, `Danger`, `Gold`, `Slot`, `SlotEmpty`) | tombol digambar kode (gradient + outline + bayangan) |

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
| `Colors` | outline, teks, backdrop, track progress bar |
| `Palettes` | `{ Atas, Bawah, Bayangan }` untuk gradient panel/tombol |
| `Sizes` | tebal outline, radius sudut, tinggi "timbul", ukuran pill/slot/toast |
| `Animation` | skala hover/tekan, kecepatan & damping spring, posisi toast |
| `ReferenceResolution`, `MinScale`, `MaxScale` | UI diskalakan otomatis sesuai layar |

## 3. Teks — `src/shared/Config/UIText.luau`
Semua tulisan di UI (format level, EXP, tas, judul jendela, pemisah ribuan).

## 4. Preview di UI Labs
1. Install plugin **UI Labs** dari Creator Store.
2. Jalankan `rojo serve` dan Connect (tidak perlu Play).
3. Buka UI Labs → storybook **Festival Layangan**. Story yang tersedia:
   `StudButton`, `ProgressBar`, `StatPill`, `HotbarSlot`, `Toast`, `HUD`, `Hotbar`, `UpgradeUI`.
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
  UI/Style.luau            outline, sudut, gradient, padding
  UI/Components/           Label, Icon, Panel, StudButton, ProgressBar, StatPill, HotbarSlot, Toast, Window
  UI/Screens/              HUD, Hotbar, UpgradeUI
  UI/Stories/              story UI Labs
  Controllers/UIController memasang ScreenGui + bridge OpenUI/Notify
```
