# RECAP PROJECT — Festival Layangan (Roblox)

Repo: `cyaliee/festivallayanganroblox`, branch `claude/dazzling-curie-dx7dmb`.
Game Roblox bertema layangan Indonesia: **Simulator + Tycoon + RPG ringan**.

## Tech stack
- **Rojo 7.4** (sinkron kode) + **Wally** (package) + Rokit (tools)
- **Matter ECS 0.8.5** (`matter-ecs/matter`): semua game logic = components + systems, loop di server & client
- **Fusion 0.3**: SEMUA UI dibuat dari kode (tidak ada UI buatan Studio)
- **BridgeNet2 1.0**: networking server <-> client
- **ProfileStore**: DataStore (store `PlayerData_v1`)
- **UI Labs**: story `.story.luau` untuk preview UI

## Prinsip arsitektur
- **Server authoritative**: client hanya kirim "intent" (mis. `{ RecipeId }`, `{ ItemKey, Mode }`), tidak pernah kirim jumlah/harga/nilai. Semua dicek di server.
- Semua intent: **rate limit** (`Util/RateLimiter`) + **validasi jarak** (`Util/Validation`) + antrean (`Util/IntentQueue`) yang diproses system Matter.
- **Semua angka balancing di `src/shared/Config/*.luau`**, tidak ada magic number di system.
- Resep crafting **data-driven** (`Config/Recipes.luau`).
- Item disimpan dengan **item key**: `"Bamboo"` untuk item biasa, `"Kite@Epic"` untuk item ber-rarity (`Rules/ItemKey.luau`).

## Struktur folder
```
src/shared/  (ReplicatedStorage/Shared)
  Config/    Items, Rarity, Recipes, Shops, Kites, Dragon, Farming, Bags, CraftingTable,
             Progression, Gamepasses, Settings, Hotbar, Network, Messages, UIText, UITheme,
             UIAssets (gambar ikon), Info, Plot, World, PlayerData, UI
  Rules/     ItemKey, Rarity (acak), Bag (kapasitas), CraftingTable, Progression
  Components.luau (Matter), Net.luau (BridgeNet2), Util/Format.luau
src/server/  (ServerScriptService/Server)
  Services/  DataService (ProfileStore), InventoryService (satu-satunya jalan ubah item),
             WalletService, ProgressionService (EXP/level), GamepassService, AuraService,
             ToolService (kapak), KiteService, DragonService, GoldenTrees, DevCommands
  Systems/   players, registerPlots, plotPrompts, releasePlots, craftingTables, plotVisuals,
             registerTrees, chopping, treeRespawn, goldenTrees, tools, registerShops,
             shopPrompts, shopTrades, craftPrompts, crafting, craftJobs, tableUpgrades,
             equipment, kiteFlights, dragons, dragonPrompts, bagUpgrades, hotbarAssign,
             settings, overhead, replicatePlayerState
  Util/      RateLimiter, Validation, Queries, IntentQueue, Notify, Announce, FestivalArea, WarnOnce
src/client/  (StarterPlayerScripts/Client)
  State/     PlayerState (Fusion Value dari snapshot server), UIState, PlayerView (nilai turunan)
  Controllers/ UIController (pasang semua ScreenGui), StateController, HotbarController,
             ToolController (ayun kapak), SettingsController (musik)
  Systems/   clock, flightStatus, craftTimers (billboard), treeHealth (billboard), nametags,
             plotPromptVisibility
  UI/        Style, Components/ (Text, Icon, Button, Panel, Window, ProgressBar, ItemSlot,
             Toast, Toggle, ScrollList, ProfileCard), Screens/ (HUD, Sidebar, Hotbar,
             Inventory, BagUI, ShopUI, MarketUI, CraftUI, UpgradeUI, SettingsUI, InfoUI,
             Announcement), Stories/ (UI Labs)
```

## Fitur yang sudah jadi

### Fase 1 — Fondasi, data, kavling
- Klaim kavling via ProximityPrompt di `PapanNama` (1 pemain 1 kavling, dilepas saat keluar).
- Setelah klaim: spawn `MejaRakit` dari `ServerStorage/Assets`, jadi entity ECS (Plot, Owner, CraftingTable).
- Papan nama berubah jadi pembuka Upgrade Meja.

### Fase 2 — Replikasi state
- Server kirim snapshot data ke client saat berubah (BridgeNet2) -> Fusion Value -> UI update realtime.

### Fase 3 — Tas
- "Tas Level 1..20", kapasitas & harga dari rumus (`Config/Bags.luau`).
- Semua item fisik menghitung ke kapasitas; loot ditolak kalau penuh + notif "Tas Penuh!".
- Upgrade tas pakai uang (dari tombol di Inventory).

### Fase 4 — Farming, ekonomi, crafting, terbang
- **Hutan Bambu**: pohon = entity (HP, respawn 15 detik), tebang pakai kapak (slot 1 hotbar), +2 Bambu.
- **Pasar**: NPC Pengepul (jual bambu), Toko (beli Lem, Kertas, Lem Super, Kain Parasut), Tengkulak (jual layangan per rarity). Validasi jarak ke NPC.
- **Crafting** di MejaRakit sendiri, bahan dikurangi saat mulai, timer countdown di atas meja (billboard), hasil masuk tas. Status crafting tersimpan di data (lanjut walau keluar).
- **Terbangkan layangan** di Area Festival dari hotbar: 1 layangan habis, +5 uang & +2 EXP per 10 detik x multiplier rarity, durasi 60 detik.
- Level up otomatis, upgrade Meja Rakit (5 level, kecepatan rakit x1 -> x2).

### Fase 4.5 — Endgame
- **Rarity** (diacak server saat crafting selesai): Common 70%, Uncommon 20%, Rare 8%, Epic 1.9%, Legendary 0.1%, Mythic (khusus Naga). Multiplier terbang & harga jual x1 / x1.5 / x2 / x3 / x5 / x10. Legendary diumumkan global.
- **Bambu Emas**: drop 1% x Luck saat tebang + Pohon Bambu Emas acak tiap 30 menit (diumumkan). Tidak dijual NPC. Dipakai sebagai booster crafting (peluang Legendary jadi 15%) dan resep Naga.
- **Layangan Naga**: resep 3 Bambu Emas + 10 Kain Parasut + 5 Lem Super, butuh Meja level max, 90 detik, selalu Mythic. **Dipasang di kavling** (tombol F di meja), bukan dari hotbar; tanpa durasi, maks 1 per kavling, bisa diturunkan. Model raksasa Persistent + tali. Aura: pemilik online dapat +100 uang & +40 EXP per 10 detik, crafting 50% lebih cepat, pemain lain di sekitar +25% EXP.
- **Gamepass**: VIP (2x EXP + 2x Luck), X2 EXP, Luck X2 — Id masih 0 di `Config/Gamepasses.luau`. Efek menumpuk (dikali).
- **Nametag** `DisplayName | Lv.xxx` menggantikan nama bawaan Roblox.

### UI (dirombak terakhir) — tone gelap metalik
- Mengikuti script Fusion milik user (DonationMenu & Hotbar): panel (25,25,25), bar (20,18,26) transparan 0.1, tombol (63,63,63) + gradient metalik 153->77, stroke putih tipis, font Gotham, slot 44px, skala tinggi layar /1080 (clamp 0.6–1.2) x setting Ukuran UI, jendela meluncur dari bawah (Spring).
- **Tidak ada emoji**: semua ikon gambar dari `Config/UIAssets.luau` → `icon("Label", "rbxassetid://...")`; selama gambar kosong tampil teks placeholder.
- **Kiri bawah**: kartu profil (avatar bulat, Lv., kotak nama + uang "Rp. ...", bar EXP).
- **Kiri tengah**: sidebar tombol gambar Shop, Inventory, Setting, Information + tombol `<`/`>` sembunyi/tampil.
- **Bawah tengah**: hotbar 1-9 (slot 1 kapak), tombol di ujung untuk sembunyi/tampil (slot ditarik masuk dengan Spring).
- **Inventory**: grid tanpa search/sort; klik item = pasang/lepas di hotbar (disimpan di server).
- **Shop** (sidebar) = kartu gamepass. **Pasar** = jendela per NPC. **Crafting** = kartu resep + saklar booster.
- **Setting**: tampilkan nametag, musik (Sound "Music" di SoundService), ukuran UI. **Information**: panduan (`Config/Info.luau`).
- Notifikasi & banner pengumuman global di atas.

## Data yang disimpan (ProfileStore)
Coins, Level, Exp, BagLevel, TableLevel, Inventory (per item key), ActiveCraft, PlacedDragon, Hotbar, Settings.
Tidak disimpan (by design): kepemilikan kavling, layangan yang sedang terbang, gamepass (dicek live), kondisi pohon.

## Setup di Studio (manual)
- `Workspace/Plots/<Plot>` (Model) berisi `PapanNama` + `TableSpawn`; opsional `TiangNaga`.
- `Workspace/HutanBambu` (pohon), `Workspace/Pasar` (NPC `Pengepul`, `Toko`, `Tengkulak`), `Workspace/AreaFestival` (Part).
- `ServerStorage/Assets/MejaRakit`; opsional `Assets/Tools/Kapak`, `Assets/Kites/Kite`, `Kite_<Rarity>`, `Naga`.
- Enable Studio Access to API Services supaya data tersimpan saat test. Detail: `SETUP_STUDIO.md`.

## Command testing (chat, hanya di Studio)
`!give <ItemKey> <n>` (mis. `!give Kite@Legendary 1`), `!coins`, `!exp`, `!clearbag`, `!baglevel`, `!tablelevel`, `!finishcraft`, `!golden`, `!pass <VIP|X2Exp|Luck2>`, `!devhelp`.

## Status & yang dibatalkan
- Fase 5 (webhook SociaBuzz + VPS + Open Cloud) **DIBATALKAN** — tidak pakai VPS/SociaBuzz.
- Semua kode belum pernah dites langsung di Studio oleh AI (hanya `rojo build`, compile, analyzer, dan tes logika rarity). Perlu dites user.
- User sedang mengisi ID gambar ikon di `Config/UIAssets.luau`.

## Dokumen di repo
`README.md` (setup), `SETUP_STUDIO.md` (instance Studio), `UI_GUIDE.md` (UI & config), `DESIGN.md` (desain game & angka), `RECAP.md` (ini).
