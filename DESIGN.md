# Desain Game — Festival Layangan

Ringkasan keputusan desain. Semua angka ada di `src/shared/Config/`.

## Loop inti
Tebang bambu → jual ke Pengepul / beli bahan di Toko → rakit layangan di Meja Rakit →
terbangkan di Area Festival (koin + EXP) atau jual ke Tengkulak → upgrade tas & meja.

## Rarity (`Config/Rarity.luau`)
Diacak di **server** saat crafting selesai (bukan saat tombol ditekan).

| Tier | Peluang | Booster Bambu Emas | Multiplier (terbang & jual) | Warna slot |
|---|---|---|---|---|
| Common | 70% | 30% | x1 | biru (default) |
| Uncommon | 20% | 25% | x1,5 | hijau |
| Rare | 8% | 20% | x2 | biru |
| Epic | 1,9% | 10% | x3 | ungu |
| Legendary | 0,1% | 15% | x5 | emas |
| Mythic | khusus Naga | — | x10 | merah |

- Layangan disimpan per rarity: key inventory `Kite@Epic` (`Rules/ItemKey.luau`).
- Terbang (Common): +5 koin & +2 EXP per 10 detik, dikali multiplier rarity. 1 layangan habis per terbang.
- Luck mengalikan bobot semua tier selain Common (Luck 2x: Legendary 0,1% → ±0,15%).
- Rakit Legendary diumumkan ke semua pemain.

## Bambu Emas
- 1% per pohon tumbang (x Luck), atau Pohon Bambu Emas acak tiap 30 menit (HP 12, +3 Bambu Emas, diumumkan).
- Tidak dijual di NPC mana pun. Dipakai untuk booster rarity dan resep Naga.

## Layangan Naga (endgame)
- Resep: 3 Bambu Emas + 10 Kain Parasut + 5 Lem Super, Meja Rakit **level maksimal**, 90 detik. Selalu **Mythic**.
- **Dipasang di kavling** (prompt F di meja), bukan dari hotbar. Tanpa durasi, maksimal 1 per kavling,
  bisa diturunkan kembali ke tas. Status tersimpan di data dan muncul lagi saat klaim kavling berikutnya.
- Model raksasa, Persistent (terlihat dari seluruh map), tali ke Tiang Naga / meja.
- Pengumuman global saat dipasang.
- Aura Buff:
  - Mesin AFK: pemilik (online di mana saja) +100 koin & +40 EXP per 10 detik
  - Crafting di meja pemilik 50% lebih cepat
  - Pemain lain dalam radius 45 stud: +25% EXP

## Gamepass (`Config/Gamepasses.luau`)
| Pass | Efek |
|---|---|
| VIP | 2x EXP, 2x Luck |
| X2 EXP | 2x EXP |
| Luck X2 | 2x Luck |

Efek menumpuk (dikali): VIP + X2 EXP = 4x EXP. Luck memengaruhi rarity & drop Bambu Emas, tidak memengaruhi Naga.

## UI
- Kartu profil kanan bawah: avatar, nama, `Rp. <koin>`, `Lvl N`, EXP bar.
- Nametag `DisplayName | Lv.xxx` menggantikan nama bawaan Roblox.
