--!strict
-- Selesaikan crafting yang waktunya habis: hasil masuk inventory (kalau tas muat).
-- Kalau tas penuh, hasil menunggu di meja sampai ada ruang.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.Shared.Components)
local Recipes = require(ReplicatedStorage.Shared.Config.Recipes)
local Items = require(ReplicatedStorage.Shared.Config.Items)
local Messages = require(ReplicatedStorage.Shared.Config.Messages)

local Server = script.Parent.Parent
local DataService = require(Server.Services.DataService)
local InventoryService = require(Server.Services.InventoryService)
local ProgressionService = require(Server.Services.ProgressionService)
local notify = require(Server.Util.Notify)

local CHECK_INTERVAL = 0.25

local function craftJobs(world)
	if not Matter.useThrottle(CHECK_INTERVAL) then
		return
	end
	local now = workspace:GetServerTimeNow()
	for _, entity in world:query(Components.PlayerEntity) do
		local player = entity.player
		local data = DataService.getData(player)
		local craft = data and data.ActiveCraft
		if data == nil or craft == nil or now < craft.EndsAt then
			continue
		end
		local recipe = Recipes[craft.RecipeId]
		if recipe == nil then
			data.ActiveCraft = nil -- resep sudah dihapus dari config
			continue
		end
		if InventoryService.tryAdd(player, recipe.Output, recipe.OutputAmount) then
			data.ActiveCraft = nil
			ProgressionService.addExp(player, recipe.Exp)
			notify(player, string.format(Messages.CraftDone, Items[recipe.Output].DisplayName))
		end
	end
end

return { system = craftJobs, priority = 60 }
