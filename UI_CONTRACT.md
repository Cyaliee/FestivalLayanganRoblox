# UI Contract — Festival Layangan

Kode **tidak pernah membuat** elemen UI. Semua elemen di bawah dibuat sendiri di Studio;
kode hanya mencarinya berdasarkan **nama** (`UIRef.find`) lalu `scope:Hydrate(...)`.
Kalau elemen tidak ketemu, muncul `warn` di Output dengan format:

```
[UIRef] Elemen tidak ketemu: Players.X.PlayerGui.HUD/StatusPanel/LevelText (berhenti di "StatusPanel"). Cek UI_CONTRACT.md
```

Game tetap jalan; binding elemen itu saja yang dilewati.

## Aturan umum

- Semua `ScreenGui` di `StarterGui`: set **`ResetOnSpawn = false`** (kalau `true`, GUI dibuat ulang
  saat respawn dan binding hilang).
- Screen yang dibuka/tutup oleh kode (`UpgradeUI`, `ShopUI`, `SellUI`, `CraftUI`): set
  **`Enabled = false`** di Studio; kode yang mengatur `Enabled`.
- Kolom **Tipe** = class minimum (`IsA`). `GuiButton` = `TextButton` atau `ImageButton`.
- Kolom **Fase** = kapan kode mulai memakai elemen itu. Elemen fase berikutnya boleh sudah dibuat.

## StarterGui

### HUD (ScreenGui)
| Path | Tipe | Dipakai untuk | Fase |
|---|---|---|---|
| `Notification` | TextLabel | Teks notifikasi ("Tas Penuh!", "Kavling berhasil diklaim!"). `Text` & `Visible` diatur kode | 1 |
| `StatusPanel/LevelText` | TextLabel | Level pemain | 2 |
| `StatusPanel/ExpBar/Fill` | GuiObject | `Size` X-scale = progress EXP | 2 |
| `StatusPanel/CoinText` | TextLabel | Koin | 2 |
| `StatusPanel/BambooText` | TextLabel | Jumlah bambu | 2 |
| `StatusPanel/KiteText` | TextLabel | Jumlah layangan | 2 |
| `StatusPanel/BagText` | TextLabel | Kapasitas tas, format `12/20` | 2–3 |

### Hotbar (ScreenGui)
| Path | Tipe | Dipakai untuk | Fase |
|---|---|---|---|
| `Slots` | GuiObject (container, boleh berisi UIListLayout) | Tempat clone `UITemplates/HotbarSlot` | 2 |

### UpgradeUI (ScreenGui, `Enabled = false`)
| Path | Tipe | Dipakai untuk | Fase |
|---|---|---|---|
| `Frame/CloseButton` | GuiButton | Tutup UI | 1 |
| `Frame/CurrentLevel` | TextLabel | Level meja sekarang | 4 |
| `Frame/NextLevel` | TextLabel | Level berikutnya | 4 |
| `Frame/CostText` | TextLabel | Biaya upgrade | 4 |
| `Frame/UpgradeButton` | GuiButton | Kirim intent upgrade | 4 |

### ShopUI (ScreenGui, `Enabled = false`)
| Path | Tipe | Dipakai untuk | Fase |
|---|---|---|---|
| `Frame/CloseButton` | GuiButton | Tutup UI | 1 |
| `Frame/Title` | TextLabel | Nama toko/NPC | 4 |
| `Frame/ItemList` | GuiObject (container) | Tempat clone `UITemplates/ShopItem` | 4 |

### SellUI (ScreenGui, `Enabled = false`) — struktur sama dengan ShopUI
| Path | Tipe | Dipakai untuk | Fase |
|---|---|---|---|
| `Frame/CloseButton` | GuiButton | Tutup UI | 1 |
| `Frame/Title` | TextLabel | Nama NPC | 4 |
| `Frame/ItemList` | GuiObject (container) | Tempat clone `UITemplates/ShopItem` | 4 |

### CraftUI (ScreenGui, `Enabled = false`)
| Path | Tipe | Dipakai untuk | Fase |
|---|---|---|---|
| `Frame/CloseButton` | GuiButton | Tutup UI | 1 |
| `Frame/RecipeList` | GuiObject (container) | Tempat clone `UITemplates/RecipeItem` | 4 |

### EventBanner (ScreenGui)
| Path | Tipe | Dipakai untuk | Fase |
|---|---|---|---|
| `Title` | TextLabel | Judul live event | 5 |
| `Subtitle` | TextLabel | Nama donatur / detail | 5 |

## ReplicatedStorage/UITemplates (di-clone oleh kode)

| Template | Anak | Tipe | Fase |
|---|---|---|---|
| `HotbarSlot` (GuiObject) | `Icon` | ImageLabel | 2 |
| | `Count` | TextLabel | 2 |
| | `KeyLabel` | TextLabel | 2 |
| | `SelectedStroke` | UIStroke | 2 |
| `ShopItem` (GuiObject) | `Icon` | ImageLabel | 4 |
| | `NameText` | TextLabel | 4 |
| | `PriceText` | TextLabel | 4 |
| | `BuyButton` | GuiButton | 4 |
| `RecipeItem` (GuiObject) | `Icon` | ImageLabel | 4 |
| | `NameText` | TextLabel | 4 |
| | `Requirements` | TextLabel | 4 |
| | `CraftButton` | GuiButton | 4 |
| `CraftTimerBillboard` (BillboardGui) | `TimerText` | TextLabel | 4 |

## World UI (di Workspace, dibuat di Studio)

| Path | Tipe | Dipakai untuk | Fase |
|---|---|---|---|
| `Workspace/Plots/<Plot>/PapanNama/**/OwnerText` | TextLabel (di SurfaceGui, boleh di kedalaman mana pun) | "Kavling Kosong" / "Kavling <Nama>". Opsional | 1 |

## Mengganti nama

Nama elemen UI ada langsung di kode controller (string path di `UIRef.find`). Nama yang
bukan UI (folder plot, nama prompt, nama model meja) ada di `src/shared/Config/Plot.luau`.
Kalau mengganti nama di Studio, update tabel ini dan string yang sesuai.
