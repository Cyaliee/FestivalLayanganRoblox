--!strict
-- Daftarkan pohon bambu di Workspace/HutanBambu sebagai entity (BambooTree + TreeHealth).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.Shared.Components)
local World = require(ReplicatedStorage.Shared.Config.World)
local Farming = require(ReplicatedStorage.Shared.Config.Farming)
local warnOnce = require(script.Parent.Parent.Util.WarnOnce)

local Bamboo = Farming.Bamboo
local scannedWorlds: { [any]: boolean } = setmetatable({}, { __mode = "k" }) :: any

local function registerTree(world, folder: Instance, tree: Instance)
	if not (tree:IsA("Model") or tree:IsA("BasePart")) then
		return
	end
	tree:SetAttribute(Bamboo.HpAttribute, Bamboo.MaxHp)
	tree:SetAttribute(Bamboo.MaxHpAttribute, Bamboo.MaxHp)
	world:spawn(
		Components.BambooTree({
			model = tree,
			parent = folder,
			position = (tree :: PVInstance):GetPivot().Position,
		}),
		Components.TreeHealth({ hp = Bamboo.MaxHp })
	)
end

local function registerTrees(world)
	local folder = workspace:FindFirstChild(World.BambooFolder)
	if folder == nil then
		warnOnce("bamboofolder", `[Bamboo] Workspace/{World.BambooFolder} tidak ada`)
		return
	end

	if not scannedWorlds[world] then
		scannedWorlds[world] = true
		for _, child in folder:GetChildren() do
			registerTree(world, folder, child)
		end
	end

	for _, child in Matter.useEvent(folder, "ChildAdded") do
		-- Pohon yang kembali dari respawn sudah terdaftar
		local known = false
		for _, tree in world:query(Components.BambooTree) do
			if tree.model == child then
				known = true
				break
			end
		end
		if not known then
			registerTree(world, folder, child)
		end
	end
end

return { system = registerTrees, priority = 0 }
