# Setup Studio — Festival Layangan

Semua nama folder/instance bisa diubah di `src/shared/Config/World.luau`, `Plot.luau`, dan `Shops.luau`.

## Fase 1 — Kavling
```
Workspace/Plots (Folder)
  Plot1 (Model)
    PapanNama (Part/Model)            ← SurfaceGui/OwnerText (TextLabel) opsional
    TableSpawn (Part, Anchored, Transparency 1, CanCollide off)
ServerStorage/Assets/MejaRakit (Model, PrimaryPart di-set, semua Anchored)
```

## Fase 4 — Farming, Pasar, Festival
```
Workspace/HutanBambu (Folder)
  <bebas> (Model atau Part)           ← tiap child = 1 pohon bambu. Anchored.
Workspace/Pasar (Folder)
  Pengepul (Model)                    ← nama HARUS sama dengan NpcName di Config/Shops
  Toko (Model)
  Tengkulak (Model)                   ← boleh rig R15/R6; prompt dipasang di HumanoidRootPart/PrimaryPart
Workspace/AreaFestival (Part, atau Folder berisi Part)
                                      ← Anchored, Transparency 1, CanCollide off. Area X/Z-nya = area terbang
ServerStorage/Assets/Tools/Kapak (Tool, opsional)     ← kalau tidak ada dipakai kapak placeholder
ServerStorage/Assets/Kites/KiteBiasa (Model/Part, opsional) ← kalau tidak ada dipakai layangan placeholder
ServerStorage/Assets/Kites/KiteNaga  (Model/Part, opsional)
```

Prompt & tool dibuat otomatis oleh kode:
- ProximityPrompt di NPC ("Jual Bambu", "Beli Bahan", "Jual Layangan")
- ProximityPrompt "Rakit Layangan" di MejaRakit
- Kapak di Backpack setiap pemain

### Cara cepat (placeholder untuk testing)
Tempel ke **Command Bar** (mode Edit), lalu geser posisinya sesuai map:
```lua
local function part(name, size, pos, color, parent)
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.Position = pos; p.Color = color
	p.Anchored = true; p.Parent = parent
	return p
end
-- Hutan bambu (10 pohon)
local forest = workspace:FindFirstChild("HutanBambu") or Instance.new("Folder", workspace)
forest.Name = "HutanBambu"
for i = 1, 10 do
	local m = Instance.new("Model"); m.Name = "Bambu" .. i
	local trunk = part("Batang", Vector3.new(14, 1.2, 1.2), Vector3.new(-80 + (i % 5) * 8, 7, 40 + math.floor(i / 5) * 8), Color3.fromRGB(110, 170, 70), m)
	trunk.Shape = Enum.PartType.Cylinder; trunk.Orientation = Vector3.new(0, 0, 90)
	m.PrimaryPart = trunk; m.Parent = forest
end
-- Pasar (3 NPC)
local market = workspace:FindFirstChild("Pasar") or Instance.new("Folder", workspace)
market.Name = "Pasar"
for i, name in { "Pengepul", "Toko", "Tengkulak" } do
	local m = Instance.new("Model"); m.Name = name
	local body = part("HumanoidRootPart", Vector3.new(3, 6, 2), Vector3.new(60 + i * 12, 3, 40), Color3.fromRGB(230, 180, 120), m)
	m.PrimaryPart = body; m.Parent = market
end
-- Area Festival
local area = part("AreaFestival", Vector3.new(80, 1, 80), Vector3.new(0, 0.5, 120), Color3.fromRGB(255, 220, 120), workspace)
area.Transparency = 0.8; area.CanCollide = false
```
