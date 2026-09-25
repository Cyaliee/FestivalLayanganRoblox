--!strict
-- Kirim snapshot data pemain ke client (BridgeNet2) setiap kali ada perubahan.
-- Client hanya MENAMPILKAN data ini; semua perubahan tetap terjadi di server.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.Shared.Components)
local Net = require(ReplicatedStorage.Shared.Net)
local Items = require(ReplicatedStorage.Shared.Config.Items)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)
local DataService = require(script.Parent.Parent.Services.DataService)
local RateLimiter = require(script.Parent.Parent.Util.RateLimiter)

local PlayerEntity = Components.PlayerEntity

local stateBridge = Net.bridge(NetworkConfig.Bridges.PlayerState)
local requestBridge = Net.bridge(NetworkConfig.Bridges.RequestState)
local requestLimiter = RateLimiter.new(NetworkConfig.RateLimits.RequestState)

local itemIds: { string } = {}
for id in Items do
	table.insert(itemIds, id)
end
table.sort(itemIds)

local lastSignature: { [Player]: string } = {}

-- Client minta kirim ulang (mis. baru selesai load). Tidak ada data dari client yang dipakai.
requestBridge:Connect(function(player: Player)
	if requestLimiter:check(player) then
		lastSignature[player] = nil
	end
end)

local function makeSnapshot(data: DataService.Data)
	local inventory = {}
	for _, id in itemIds do
		inventory[id] = data.Inventory[id] or 0
	end
	return {
		Coins = data.Coins,
		Level = data.Level,
		Exp = data.Exp,
		BagLevel = data.BagLevel,
		TableLevel = data.TableLevel,
		Inventory = inventory,
	}
end

local function makeSignature(snapshot): string
	local parts = { snapshot.Coins, snapshot.Level, snapshot.Exp, snapshot.BagLevel, snapshot.TableLevel }
	for _, id in itemIds do
		table.insert(parts, snapshot.Inventory[id])
	end
	return table.concat(parts, ",")
end

local function replicatePlayerState(world)
	if not Matter.useThrottle(NetworkConfig.ReplicationInterval) then
		return
	end

	local active: { [Player]: boolean } = {}
	for _, entity in world:query(PlayerEntity) do
		local player = entity.player
		local data = DataService.getData(player)
		if data == nil then
			continue
		end
		active[player] = true

		local snapshot = makeSnapshot(data)
		local signature = makeSignature(snapshot)
		if signature ~= lastSignature[player] then
			lastSignature[player] = signature
			stateBridge:Fire(player, snapshot)
		end
	end

	for player in lastSignature do
		if not active[player] then
			lastSignature[player] = nil
		end
	end
end

return { system = replicatePlayerState, priority = 100 }
