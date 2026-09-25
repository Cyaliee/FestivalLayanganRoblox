--!strict
--[[
	Layangan Naga terpasang di kavling (data.PlacedDragon):
	- munculkan/hapus visual mengikuti data & kepemilikan kavling
	- Mesin AFK: pemilik online (di mana saja) dapat koin & EXP tiap TickInterval
	- daftarkan Aura (Social Buff +EXP untuk pemain lain di sekitar kavling)
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Shared.Components)
local Dragon = require(ReplicatedStorage.Shared.Config.Dragon)

local Server = script.Parent.Parent
local DataService = require(Server.Services.DataService)
local DragonService = require(Server.Services.DragonService)
local ProgressionService = require(Server.Services.ProgressionService)
local WalletService = require(Server.Services.WalletService)
local AuraService = require(Server.Services.AuraService)

local DragonC = Components.Dragon
local Plot = Components.Plot
local Owner = Components.Owner
local CraftingTable = Components.CraftingTable

local function dragons(world)
	local now = workspace:GetServerTimeNow()

	-- Kavling dilepas -> turunkan visual (data tetap tersimpan)
	local orphaned = {}
	for id, dragon in world:query(DragonC):without(Owner) do
		table.insert(orphaned, { id = id, dragon = dragon })
	end
	for _, entry in orphaned do
		DragonService.destroy(entry.dragon.visual)
		world:remove(entry.id, DragonC)
	end

	local auras = {}
	for id, plot, owner, craftingTable in world:query(Plot, Owner, CraftingTable) do
		local data = DataService.getData(owner.player)
		local wanted = if data then data.PlacedDragon else nil
		local current = world:get(id, DragonC)

		if current and current.key ~= wanted then
			DragonService.destroy(current.visual)
			world:remove(id, DragonC)
			current = nil
		end
		if current == nil and wanted then
			local visual = DragonService.create(wanted, owner.player.Name, plot.model, craftingTable.model)
			world:insert(
				id,
				DragonC({
					key = wanted,
					visual = visual,
					nextTickAt = now + Dragon.TickInterval,
					center = craftingTable.model:GetPivot().Position,
				})
			)
			current = world:get(id, DragonC)
		end
		if current == nil then
			continue
		end

		DragonService.update(current.visual, current.center, now)
		table.insert(auras, { position = current.center, ownerUserId = owner.userId })

		if now >= current.nextTickAt and owner.player.Parent == Players then
			ProgressionService.addExp(owner.player, Dragon.ExpPerTick)
			WalletService.add(owner.player, Dragon.CoinsPerTick)
			world:insert(id, current:patch({ nextTickAt = current.nextTickAt + Dragon.TickInterval }))
		end
	end

	AuraService.set(auras)
end

return { system = dragons, priority = 55 }
