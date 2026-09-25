--!strict
-- Visual layangan terbang: model dari ServerStorage/Assets/Kites/<ItemId>, atau placeholder.
-- Tali (Beam) dari HumanoidRootPart pemain ke layangan.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local World = require(ReplicatedStorage.Shared.Config.World)
local Kites = require(ReplicatedStorage.Shared.Config.Kites)

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

local function makePlaceholder(kiteId: string): BasePart
	local stats = Kites.Stats[kiteId]
	local part = Instance.new("Part")
	part.Name = kiteId
	part.Size = stats.Size
	part.Color = stats.Color
	part.Material = Enum.Material.SmoothPlastic
	return part
end

-- Buat visual layangan untuk pemain. return (root visual, attachment di pemain)
function KiteService.createVisual(player: Player, kiteId: string): (Instance, Attachment?)
	local assets = ServerStorage:FindFirstChild(World.AssetFolder)
	local kites = assets and assets:FindFirstChild(World.KitesFolder)
	local template = kites and kites:FindFirstChild(kiteId)

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
		local part = makePlaceholder(kiteId)
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
