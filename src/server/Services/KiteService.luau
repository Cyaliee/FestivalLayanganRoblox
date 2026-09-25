--!strict
--[[
	Visual layangan terbang. Model dicari di ServerStorage/Assets/Kites dengan urutan:
	  "<ItemId>_<Rarity>" (mis. Kite_Legendary)  ->  "<ItemId>"  ->  placeholder
	Placeholder memberi efek per rarity: Uncommon warna mencolok, Rare ekor (Trail),
	Epic cahaya (PointLight), Legendary partikel + lebih besar.
	Tali (Beam) dari HumanoidRootPart pemain ke layangan.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local World = require(ReplicatedStorage.Shared.Config.World)
local Kites = require(ReplicatedStorage.Shared.Config.Kites)
local Rarity = require(ReplicatedStorage.Shared.Rules.Rarity)
local ItemKey = require(ReplicatedStorage.Shared.Rules.ItemKey)

local KiteService = {}

local ANCHOR_NAME = "KiteStringAnchor"

local function flyingFolder(): Folder
	local folder = workspace:FindFirstChild(World.FlyingKitesFolder)
	if folder == nil then
		folder = Instance.new("Folder")
		folder.Name = World.FlyingKitesFolder
		folder.Parent = workspace
	end
	return folder :: Folder
end

local function prepare(part: BasePart)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
end

local function makePlaceholder(key: string): BasePart
	local kiteId, rarityId = ItemKey.parse(key)
	local stats = Kites.Stats[kiteId]
	local tier = ItemKey.rarity(key)
	local rarity = rarityId or "Common"

	local part = Instance.new("Part")
	part.Name = kiteId
	part.Size = stats.Size * (Kites.RaritySize[rarity] or 1)
	part.Color = if tier then tier.Color else Color3.new(1, 1, 1)
	part.Material = if Rarity.atLeast(rarity, "Epic") then Enum.Material.Neon else Enum.Material.SmoothPlastic

	if Rarity.atLeast(rarity, "Rare") then
		local a0 = Instance.new("Attachment")
		a0.Position = Vector3.new(0, -part.Size.Y / 2, 0)
		a0.Parent = part
		local a1 = Instance.new("Attachment")
		a1.Position = Vector3.new(0, -part.Size.Y / 2 - 0.5, 0)
		a1.Parent = part
		local trail = Instance.new("Trail")
		trail.Attachment0 = a0
		trail.Attachment1 = a1
		trail.Lifetime = 1.2
		trail.Color = ColorSequence.new(part.Color)
		trail.Transparency = NumberSequence.new(0.2, 1)
		trail.Parent = part
	end
	if Rarity.atLeast(rarity, "Epic") then
		local light = Instance.new("PointLight")
		light.Color = part.Color
		light.Range = 14
		light.Brightness = 2
		light.Parent = part
	end
	if Rarity.atLeast(rarity, "Legendary") then
		local particles = Instance.new("ParticleEmitter")
		particles.Color = ColorSequence.new(part.Color)
		particles.LightEmission = 1
		particles.Rate = 25
		particles.Lifetime = NumberRange.new(0.8, 1.4)
		particles.Speed = NumberRange.new(1, 3)
		particles.Size = NumberSequence.new(0.5, 0)
		particles.Parent = part
	end
	return part
end

-- Template model dari ServerStorage/Assets/Kites (per rarity dulu, lalu umum)
function KiteService.findTemplate(key: string): Instance?
	local itemId, rarity = ItemKey.parse(key)
	local assets = ServerStorage:FindFirstChild(World.AssetFolder)
	local kites = assets and assets:FindFirstChild(World.KitesFolder)
	if kites == nil then
		return nil
	end
	return (rarity and kites:FindFirstChild(`{itemId}_{rarity}`)) or kites:FindFirstChild(itemId)
end

-- Buat visual layangan untuk pemain. return (root visual, attachment di pemain)
function KiteService.createVisual(player: Player, key: string): (Instance, Attachment?)
	local kiteId = ItemKey.parse(key)
	local template = KiteService.findTemplate(key)

	local visual: Instance
	local mainPart: BasePart
	if template and template:IsA("Model") then
		local model = template:Clone()
		for _, descendant in model:GetDescendants() do
			if descendant:IsA("BasePart") then
				prepare(descendant)
			end
		end
		visual = model
		mainPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true) :: BasePart
	elseif template and template:IsA("BasePart") then
		local part = template:Clone()
		prepare(part)
		visual, mainPart = part, part
	else
		local part = makePlaceholder(key)
		prepare(part)
		visual, mainPart = part, part
	end
	visual.Name = `{player.Name}_{kiteId}`

	-- Tali
	local anchor: Attachment? = nil
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root and mainPart then
		anchor = Instance.new("Attachment")
		anchor.Name = ANCHOR_NAME
		anchor.Parent = root

		local kiteEnd = Instance.new("Attachment")
		kiteEnd.Parent = mainPart

		local beam = Instance.new("Beam")
		beam.Attachment0 = anchor
		beam.Attachment1 = kiteEnd
		beam.Width0 = 0.08
		beam.Width1 = 0.08
		beam.FaceCamera = true
		beam.Segments = 12
		beam.CurveSize0 = -4
		beam.Color = ColorSequence.new(Color3.fromRGB(245, 245, 235))
		beam.Parent = mainPart
	end

	visual.Parent = flyingFolder()
	return visual, anchor
end

-- Posisikan layangan di atas-belakang pemain dengan goyangan
function KiteService.updateVisual(visual: Instance, root: BasePart, time: number)
	local sway = math.sin(time * Kites.SwaySpeed) * Kites.SwayAmount
	local bob = math.sin(time * Kites.SwaySpeed * 1.7) * 1.2
	local target = root.Position
		+ Vector3.new(0, Kites.Height + bob, 0)
		- root.CFrame.LookVector * Kites.Distance
		+ root.CFrame.RightVector * sway
	local cf = CFrame.lookAt(target, root.Position) * CFrame.Angles(0, 0, math.rad(45 + sway * 3))
	if visual:IsA("Model") then
		visual:PivotTo(cf)
	elseif visual:IsA("BasePart") then
		visual.CFrame = cf
	end
end

function KiteService.destroyVisual(visual: Instance?, anchor: Attachment?)
	if visual then
		visual:Destroy()
	end
	if anchor then
		anchor:Destroy()
	end
end

return KiteService
