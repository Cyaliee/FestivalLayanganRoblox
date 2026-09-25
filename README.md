# Festival Layangan (Roblox)

Simulator + Tycoon + RPG ringan bertema layangan Indonesia.

Stack: Rojo · Wally · Matter ECS · Fusion 0.3 · BridgeNet2 · ProfileStore · UI Labs

## Setup

```bash
rokit install           # rojo, wally, stylua, selene (lihat rokit.toml)
wally install           # -> Packages/, ServerPackages/, DevPackages/
rojo serve              # atau: rojo serve dev.project.json (ikut DevPackages untuk UI Labs)
```

Buka **place file kamu sendiri** (yang berisi UI, Plots, dan model buatan Studio), lalu
Connect lewat plugin Rojo. Rojo hanya mengelola:

| Studio | Sumber |
|---|---|
| `ReplicatedStorage/Shared` | `src/shared` |
| `ReplicatedStorage/Packages` | `Packages` (wally) |
| `ServerScriptService/Server` | `src/server` |
| `ServerScriptService/ServerPackages` | `ServerPackages` (wally) |
| `StarterPlayer/StarterPlayerScripts/Client` | `src/client` |

Instance lain (`Workspace/Plots`, `ServerStorage/Assets`) tidak disentuh Rojo —
simpan place file seperti biasa. UI layar dibuat oleh kode (Fusion), lihat UI_GUIDE.md.

## Struktur

```
src/
  shared/                 ReplicatedStorage/Shared
    Config/               SEMUA angka balancing, nama instance, tema & gambar UI
    Rules/                rumus bersama server/client (kapasitas tas, EXP)
    Util/Format.luau      format angka
    Components.luau       komponen Matter
    Net.luau              akses bridge BridgeNet2
  server/                 ServerScriptService/Server
    init.server.luau      bootstrap + Matter loop
    Services/DataService  ProfileStore
    Systems/              system Matter (server)
    Util/                 RateLimiter, Validation, Queries, WarnOnce
  client/                 StarterPlayerScripts/Client
    init.client.luau      bootstrap + Matter loop
    Controllers/          UI, state dari server, input hotbar
    State/                PlayerState, UIState, PlayerView (Fusion)
    UI/                   komponen, layar, story UI Labs (Fusion)
    Systems/              system Matter (client)
```

Lihat [SETUP_STUDIO.md](SETUP_STUDIO.md) untuk instance yang perlu disiapkan di Studio, dan [UI_GUIDE.md](UI_GUIDE.md) untuk mengisi gambar & mengubah tema UI.
