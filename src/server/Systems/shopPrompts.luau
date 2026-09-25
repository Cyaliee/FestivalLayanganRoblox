--!strict
-- Interaksi NPC pasar: buka jendela toko di client (setelah validasi jarak).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.Shared.Components)
local Net = require(ReplicatedStorage.Shared.Net)
local ShopsConfig = require(ReplicatedStorage.Shared.Config.Shops)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)
local Messages = require(ReplicatedStorage.Shared.Config.Messages)

local Util = script.Parent.Parent.Util
local RateLimiter = require(Util.RateLimiter)
local Validation = require(Util.Validation)
local notify = require(Util.Notify)

local limiter = RateLimiter.new(NetworkConfig.RateLimits.ShopPrompt)
local openUIBridge = Net.bridge(NetworkConfig.Bridges.OpenUI)

local function shopPrompts(world)
	for _, npc in world:query(Components.ShopNpc) do
		for _, player in Matter.useEvent(npc.prompt, "Triggered") do
			if not limiter:check(player) then
				continue
			end
			local maxDistance = ShopsConfig.InteractDistance + ShopsConfig.DistanceTolerance
			if not Validation.isWithinDistance(player, npc.position, maxDistance) then
				notify(player, Messages.TooFar)
				continue
			end
			openUIBridge:Fire(player, { Name = ShopsConfig.screenName(npc.shopId) })
		end
	end
end

return { system = shopPrompts, priority = 10 }
