--!strict
-- Ayunan kapak: server cari pohon terdekat, kurangi HP, tumbangkan & beri bambu
-- (+ peluang Bambu Emas; pohon emas memberi Bambu Emas pasti & diumumkan ke semua pemain).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Components = require(ReplicatedStorage.Shared.Components)
local World = require(ReplicatedStorage.Shared.Config.World)
local Farming = require(ReplicatedStorage.Shared.Config.Farming)
local Messages = require(ReplicatedStorage.Shared.Config.Messages)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)

local Server = script.Parent.Parent
local DataService = require(Server.Services.DataService)
local InventoryService = require(Server.Services.InventoryService)
local ProgressionService = require(Server.Services.ProgressionService)
local ToolService = require(Server.Services.ToolService)
local GamepassService = require(Server.Services.GamepassService)
local GoldenTrees = require(Server.Services.GoldenTrees)
local IntentQueue = require(Server.Util.IntentQueue)
local Validation = require(Server.Util.Validation)
local notify = require(Server.Util.Notify)
local announce = require(Server.Util.Announce)

local BambooTree = Components.BambooTree
local TreeHealth = Components.TreeHealth
local Felled = Components.Felled
local GoldenTree = Components.GoldenTree
local Golden = Farming.Golden
local rng = Random.new()
local Bamboo = Farming.Bamboo
local Axe = Farming.Axe

local BRIDGE = NetworkConfig.Bridges.RequestChop
IntentQueue.listen(BRIDGE)

local lastSwing: { [Player]: number } = {}
Players.PlayerRemoving:Connect(function(player)
	lastSwing[player] = nil
end)

local function felledFolder(): Folder
	local folder = ServerStorage:FindFirstChild(World.FelledTreesFolder)
	if folder == nil then
		folder = Instance.new("Folder")
		folder.Name = World.FelledTreesFolder
		folder.Parent = ServerStorage
	end
	return folder :: Folder
end

local function nearestTree(world, position: Vector3): (number?, any)
	local bestId, bestTree, bestDistance = nil, nil, math.huge
	for id, tree in world:query(BambooTree, TreeHealth):without(Felled) do
		local distance = (tree.position - position).Magnitude
		if distance < bestDistance then
			bestId, bestTree, bestDistance = id, tree, distance
		end
	end
	return bestId, bestTree
end

local function handle(world, player: Player)
	if player.Parent ~= Players or DataService.getData(player) == nil then
		return
	end
	local now = os.clock()
	if lastSwing[player] and now - lastSwing[player] < Axe.SwingCooldown then
		return
	end
	if not ToolService.isHoldingAxe(player) then
		notify(player, Messages.NeedAxe)
		return
	end
	local root = Validation.getRootPart(player)
	if root == nil then
		return
	end
	lastSwing[player] = now
	ToolService.playSwing(player)

	local treeId, tree = nearestTree(world, root.Position)
	if treeId == nil or not Validation.isWithinDistance(player, tree.position, Axe.Range) then
		return
	end

	local health = world:get(treeId, TreeHealth)
	local newHp = health.hp - Axe.Damage
	local isGolden = world:get(treeId, GoldenTree) ~= nil

	if newHp > 0 then
		world:insert(treeId, TreeHealth({ hp = newHp }))
		tree.model:SetAttribute(Bamboo.HpAttribute, newHp)
		return
	end

	-- Hasil tumbang: bambu biasa + Bambu Emas (pohon emas, atau drop langka x Luck)
	local loot: { [string]: number } = { [Bamboo.YieldItem] = Bamboo.YieldAmount }
	local goldenAmount = 0
	if isGolden then
		goldenAmount = Golden.YieldAmount
	elseif rng:NextNumber() < Golden.DropChance * GamepassService.luckMultiplier(player) then
		goldenAmount = 1
	end
	if goldenAmount > 0 then
		loot[Golden.ItemId] = goldenAmount
	end
	if not InventoryService.canAddMany(player, loot) then
		InventoryService.notifyBagFull(player)
		return -- pohon tidak tumbang; coba lagi setelah tas dikosongkan
	end

	for key, amount in loot do
		InventoryService.tryAdd(player, key, amount)
	end
	ProgressionService.addExp(player, Bamboo.ExpPerFell)
	if isGolden then
		announce(string.format(Messages.GoldenTreeFelled, player.DisplayName), "Gold")
		GoldenTrees.revert(world, treeId)
	elseif goldenAmount > 0 then
		notify(player, Messages.GoldenDrop)
	end

	world:insert(treeId, TreeHealth({ hp = 0 }), Felled({ respawnAt = os.clock() + Bamboo.RespawnTime }))
	tree.model:SetAttribute(Bamboo.HpAttribute, 0)
	tree.model.Parent = felledFolder()
end

local function chopping(world)
	for _, intent in IntentQueue.drain(BRIDGE) do
		handle(world, intent.player)
	end
end

return { system = chopping, priority = 45 }
