--!strict
-- Setiap SpawnInterval, satu pohon bambu acak jadi Pohon Bambu Emas (diumumkan ke semua pemain).
-- Pohon emas yang tidak ditebang dalam Lifetime kembali jadi pohon biasa.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.Shared.Components)
local Farming = require(ReplicatedStorage.Shared.Config.Farming)
local Messages = require(ReplicatedStorage.Shared.Config.Messages)

local Server = script.Parent.Parent
local GoldenTrees = require(Server.Services.GoldenTrees)
local announce = require(Server.Util.Announce)

local Golden = Farming.Golden
local rng = Random.new()

local GoldenSystem = {}

-- Paksa spawn sekarang (dipakai DevCommands)
GoldenSystem.forceSpawn = false

local nextSpawnAt: number? = nil

local function spawnGolden(world, now: number): boolean
	local candidates = {}
	for id in world:query(Components.BambooTree, Components.TreeHealth):without(Components.Felled, Components.GoldenTree) do
		table.insert(candidates, id)
	end
	if #candidates == 0 then
		return false
	end
	GoldenTrees.makeGolden(world, candidates[rng:NextInteger(1, #candidates)], now)
	announce(Messages.GoldenTreeSpawned, "Gold")
	return true
end

local function goldenTrees(world)
	if not Matter.useThrottle(1) then
		return
	end
	local now = os.clock()
	if nextSpawnAt == nil then
		nextSpawnAt = now + Golden.SpawnInterval
	end

	-- Kedaluwarsa
	local expired = {}
	for id, golden in world:query(Components.GoldenTree):without(Components.Felled) do
		if now >= golden.expiresAt then
			table.insert(expired, id)
		end
	end
	for _, id in expired do
		GoldenTrees.revert(world, id)
		world:insert(id, Components.TreeHealth({ hp = Farming.Bamboo.MaxHp }))
		local tree = world:get(id, Components.BambooTree)
		tree.model:SetAttribute(Farming.Bamboo.HpAttribute, Farming.Bamboo.MaxHp)
	end

	-- Hanya satu pohon emas sekaligus
	local hasGolden = false
	for _ in world:query(Components.GoldenTree) do
		hasGolden = true
		break
	end

	if GoldenSystem.forceSpawn or (not hasGolden and now >= (nextSpawnAt :: number)) then
		GoldenSystem.forceSpawn = false
		if spawnGolden(world, now) then
			nextSpawnAt = now + Golden.SpawnInterval
		end
	end
end

GoldenSystem.system = goldenTrees
GoldenSystem.priority = 47

return GoldenSystem
