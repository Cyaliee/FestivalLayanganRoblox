--!strict
-- Prompt "Rakit Layangan" di MejaRakit: hanya pemilik (dan dalam jarak) yang bisa membuka CraftUI.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.Shared.Components)
local Net = require(ReplicatedStorage.Shared.Net)
local TableConfig = require(ReplicatedStorage.Shared.Config.CraftingTable)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)
local Messages = require(ReplicatedStorage.Shared.Config.Messages)

local Util = script.Parent.Parent.Util
local RateLimiter = require(Util.RateLimiter)
local Validation = require(Util.Validation)
local notify = require(Util.Notify)

local limiter = RateLimiter.new(NetworkConfig.RateLimits.CraftPrompt)
local openUIBridge = Net.bridge(NetworkConfig.Bridges.OpenUI)

local function craftPrompts(world)
	for _, craftingTable, owner in world:query(Components.CraftingTable, Components.Owner) do
		if craftingTable.prompt == nil then
			continue
		end
		for _, player in Matter.useEvent(craftingTable.prompt, "Triggered") do
			if not limiter:check(player) then
				continue
			end
			if player ~= owner.player then
				notify(player, Messages.NotYourTable)
				continue
			end
			local maxDistance = TableConfig.InteractDistance + TableConfig.DistanceTolerance
			if not Validation.isWithinDistance(player, craftingTable.model:GetPivot().Position, maxDistance) then
				notify(player, Messages.TooFar)
				continue
			end
			openUIBridge:Fire(player, { Name = "CraftUI" })
		end
	end
end

return { system = craftPrompts, priority = 10 }
