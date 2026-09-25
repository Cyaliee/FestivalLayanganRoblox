--!strict
--[[
	Visual Layangan Naga yang dipasang di kavling.
	Model: ServerStorage/Assets/Kites/Naga_<Rarity> atau Naga (buatanmu, boleh berisi ParticleEmitter).
	Kalau tidak ada dipakai placeholder merah raksasa. Model dibuat Persistent supaya
	tetap terlihat dari seluruh map walau StreamingEnabled aktif.
	Tali (Beam) diikat ke Part "TiangNaga" di kavling, atau ke meja kalau tidak ada.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local World = require(ReplicatedStorage.Shared.Config.World)
local Dragon = require(ReplicatedStorage.Shared.Config.Dragon)
local ItemKey = require(ReplicatedStorage.Shared.Rules.ItemKey)
local KiteService = require(script.Parent.KiteService)

local DragonService = {}

export type Visual = { model: Model, main: BasePart, anchor: Attachment? }

local function flyingFolder(): Instance
	local folder = workspace:FindFirstChild(World.FlyingKitesFolder)
	if folder == nil then
		folder = Instance.new("Folder")
		folder.Name = World.FlyingKitesFolder
		folder.Parent = workspace
	end
	return folder :: Instance
end

local function prepare(part: BasePart)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
end

local function makePlaceholder(key: string): Model
	local tier = ItemKey.rarity(key)
	local color = if tier then tier.Color else Color3.fromRGB(255, 53, 67)
	local model = Instance.new("Model")

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Dragon.PlaceholderSize
	body.Color = color
	body.Material = Enum.Material.Neon
	body.Parent = model
	model.PrimaryPart = body

	-- Ekor panjang
	local a0 = Instance.new("Attachment")
	a0.Position = Vector3.new(0, -body.Size.Y / 2, 0)
	a0.Parent = body
	local a1 = Instance.new("Attachment")
	a1.Position = Vector3.new(0, -body.Size.Y / 2 - 3, 0)
	a1.Parent = body
	local trail = Instance.new("Trail")
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Lifetime = 4
	trail.Color = ColorSequence.new(color, Color3.fromRGB(255, 200, 60))
	trail.Transparency = NumberSequence.new(0, 1)
	trail.Parent = body

	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = 60
	light.Brightness = 3
	light.Parent = body

	local fire = Instance.new("ParticleEmitter")
	fire.Color = ColorSequence.new(color)
	fire.LightEmission = 1
	fire.Rate = 40
	fire.Lifetime = NumberRange.new(1.5, 2.5)
	fire.Speed = NumberRange.new(4, 8)
	fire.Size = NumberSequence.new(3, 0)
	fire.Parent = body
	return model
end

-- Titik ikat tali: Part "TiangNaga" di kavling, atau meja
local function tetherPart(plotModel: Model, tableModel: Model): BasePart?
	local pole = plotModel:FindFirstChild(Dragon.PoleName, true)
	if pole and pole:IsA("BasePart") then
		return pole
	end
	return tableModel.PrimaryPart or tableModel:FindFirstChildWhichIsA("BasePart", true)
end

function DragonService.create(key: string, ownerName: string, plotModel: Model, tableModel: Model): Visual
	local template = KiteService.findTemplate(key)
	local model: Model
	if template and template:IsA("Model") then
		model = template:Clone()
	elseif template and template:IsA("BasePart") then
		model = Instance.new("Model")
		local part = template:Clone()
		part.Parent = model
		model.PrimaryPart = part
	else
		model = makePlaceholder(key)
	end
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			prepare(descendant)
		end
	end
	local main = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true) :: BasePart
	model.Name = `Naga_{ownerName}`
	model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent

	local anchor: Attachment? = nil
	local tether = tetherPart(plotModel, tableModel)
	if tether then
		anchor = Instance.new("Attachment")
		anchor.Name = "DragonTether"
		anchor.Position = Vector3.new(0, tether.Size.Y / 2, 0)
		anchor.Parent = tether

		local dragonEnd = Instance.new("Attachment")
		dragonEnd.Parent = main

		local rope = Instance.new("Beam")
		rope.Attachment0 = anchor
		rope.Attachment1 = dragonEnd
		rope.Width0 = 0.3
		rope.Width1 = 0.3
		rope.FaceCamera = true
		rope.Segments = 20
		rope.CurveSize0 = -20
		rope.Color = ColorSequence.new(Color3.fromRGB(245, 240, 225))
		rope.Parent = main
	end

	model.Parent = flyingFolder()
	return { model = model, main = main, anchor = anchor }
end

-- Naga melayang tinggi di atas kavling dan meliuk pelan
function DragonService.update(visual: Visual, center: Vector3, time: number)
	local t = time * Dragon.SwaySpeed
	local offset = Vector3.new(math.cos(t) * Dragon.SwayAmount, Dragon.Height + math.sin(t * 2) * 6, math.sin(t) * Dragon.SwayAmount)
	local position = center + offset
	local ahead = center
		+ Vector3.new(math.cos(t + 0.1) * Dragon.SwayAmount, Dragon.Height, math.sin(t + 0.1) * Dragon.SwayAmount)
	visual.model:PivotTo(CFrame.lookAt(position, ahead))
end

function DragonService.destroy(visual: Visual?)
	if visual == nil then
		return
	end
	visual.model:Destroy()
	if visual.anchor then
		visual.anchor:Destroy()
	end
end

return DragonService
