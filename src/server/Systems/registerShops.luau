--!strict
-- Daftarkan NPC di Workspace/Pasar yang namanya cocok dengan Config/Shops (NpcName).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.Shared.Components)
local World = require(ReplicatedStorage.Shared.Config.World)
local ShopsConfig = require(ReplicatedStorage.Shared.Config.Shops)
local warnOnce = require(script.Parent.Parent.Util.WarnOnce)

local PROMPT_NAME = "ShopPrompt"
local scannedWorlds: { [any]: boolean } = setmetatable({}, { __mode = "k" }) :: any

local function shopForNpc(name: string)
	for id, shop in ShopsConfig.Shops do
		if shop.NpcName == name then
			return id, shop
		end
	end
	return nil, nil
end

local function promptParent(npc: Model): BasePart?
	local root = npc:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root
	end
	return npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart", true)
end

local function registerNpc(world, npc: Instance)
	if not npc:IsA("Model") then
		return
	end
	local shopId, shop = shopForNpc(npc.Name)
	if shopId == nil then
		warnOnce(`npc:{npc.Name}`, `[Shops] NPC {npc:GetFullName()} tidak ada di Config/Shops (NpcName)`)
		return
	end
	local parent = promptParent(npc)
	if parent == nil then
		warn(`[Shops] NPC {npc:GetFullName()} tidak punya BasePart untuk ProximityPrompt`)
		return
	end

	local prompt = npc:FindFirstChild(PROMPT_NAME, true)
	if prompt == nil or not prompt:IsA("ProximityPrompt") then
		prompt = Instance.new("ProximityPrompt")
		prompt.Name = PROMPT_NAME
		prompt.Parent = parent
	end
	local p = prompt :: ProximityPrompt
	p.ActionText = shop.PromptText
	p.ObjectText = shop.Title
	p.HoldDuration = 0
	p.MaxActivationDistance = ShopsConfig.InteractDistance
	p.RequiresLineOfSight = false

	world:spawn(Components.ShopNpc({
		shopId = shopId,
		model = npc,
		prompt = p,
		position = parent.Position,
	}))
end

local function registerShops(world)
	local folder = workspace:FindFirstChild(World.MarketFolder)
	if folder == nil then
		warnOnce("marketfolder", `[Shops] Workspace/{World.MarketFolder} tidak ada`)
		return
	end
	if not scannedWorlds[world] then
		scannedWorlds[world] = true
		for _, child in folder:GetChildren() do
			registerNpc(world, child)
		end
	end
	for _, child in Matter.useEvent(folder, "ChildAdded") do
		registerNpc(world, child)
	end
end

return { system = registerShops, priority = 0 }
