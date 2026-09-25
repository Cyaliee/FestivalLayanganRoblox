--!strict
-- Layangan terbang: gerakkan visual, beri EXP & koin per tick (hanya di Area Festival),
-- dan turunkan layangan saat durasinya habis.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Shared.Components)
local Kites = require(ReplicatedStorage.Shared.Config.Kites)
local Messages = require(ReplicatedStorage.Shared.Config.Messages)

local Server = script.Parent.Parent
local ProgressionService = require(Server.Services.ProgressionService)
local WalletService = require(Server.Services.WalletService)
local KiteService = require(Server.Services.KiteService)
local FestivalArea = require(Server.Util.FestivalArea)
local notify = require(Server.Util.Notify)

local Flying = Components.Flying
local PlayerEntity = Components.PlayerEntity

local function clearAttributes(player: Player)
	player:SetAttribute(Kites.KiteAttribute, nil)
	player:SetAttribute(Kites.EndsAtAttribute, nil)
	player:SetAttribute(Kites.DurationAttribute, nil)
end

local function kiteFlights(world)
	local now = workspace:GetServerTimeNow()
	local landed = {}

	for id, flying, entity in world:query(Flying, PlayerEntity) do
		local player = entity.player
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if now >= flying.endsAt or player.Parent ~= Players then
			table.insert(landed, { id = id, player = player })
			continue
		end
		if root == nil or not root:IsA("BasePart") then
			continue -- sedang respawn; waktu terbang tetap berjalan
		end
		if flying.anchor and flying.anchor.Parent ~= root then
			flying.anchor.Parent = root -- pindahkan tali ke karakter baru
		end

		KiteService.updateVisual(flying.model, root, now)

		if now >= flying.nextTickAt then
			local stats = Kites.Stats[flying.kiteId]
			if FestivalArea.contains(root.Position) then
				ProgressionService.addExp(player, stats.ExpPerTick)
				WalletService.add(player, stats.CoinsPerTick)
			end
			world:insert(id, flying:patch({ nextTickAt = flying.nextTickAt + stats.TickInterval }))
		end
	end

	for _, entry in landed do
		world:remove(entry.id, Flying)
		if entry.player.Parent == Players then
			notify(entry.player, Messages.KiteLanded)
		end
	end

	-- Bersihkan visual setiap kali Flying hilang (mendarat, pemain keluar, entity dihapus)
	for _, record in world:queryChanged(Flying) do
		if record.new == nil and record.old then
			KiteService.destroyVisual(record.old.model, record.old.anchor)
		end
	end
	for _, entry in landed do
		clearAttributes(entry.player)
	end
end

return { system = kiteFlights, priority = 60 }
