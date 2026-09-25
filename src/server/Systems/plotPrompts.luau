--!strict
-- Interaksi Papan Nama: klaim kavling kosong, atau buka UpgradeUI di kavling sendiri.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.Shared.Components)
local Net = require(ReplicatedStorage.Shared.Net)
local PlotConfig = require(ReplicatedStorage.Shared.Config.Plot)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)
local Messages = require(ReplicatedStorage.Shared.Config.Messages)

local Util = script.Parent.Parent.Util
local RateLimiter = require(Util.RateLimiter)
local Validation = require(Util.Validation)
local Queries = require(Util.Queries)

local Plot = Components.Plot
local Owner = Components.Owner

local limiter = RateLimiter.new(NetworkConfig.RateLimits.PlotPrompt)
local notifyBridge = Net.bridge(NetworkConfig.Bridges.Notify)
local openUIBridge = Net.bridge(NetworkConfig.Bridges.OpenUI)

local function notify(player: Player, text: string)
	notifyBridge:Fire(player, { Text = text })
end

local function handleTrigger(world, plotId: number, plot, player: Player)
	if not limiter:check(player) then
		notify(player, Messages.TooFast)
		return
	end

	local maxDistance = PlotConfig.MaxActivationDistance + PlotConfig.DistanceTolerance
	if not Validation.isWithinDistance(player, plot.sign:GetPivot().Position, maxDistance) then
		notify(player, Messages.TooFar)
		return
	end

	local owner = world:get(plotId, Owner)
	if owner then
		if owner.player == player then
			openUIBridge:Fire(player, { Name = "UpgradeUI" })
		else
			notify(player, Messages.PlotTaken)
		end
		return
	end

	if not Queries.isPlayerLoaded(world, player) then
		notify(player, Messages.DataNotLoaded)
		return
	end

	if Queries.plotOwnedBy(world, player) ~= nil then
		notify(player, Messages.AlreadyOwnPlot)
		return
	end

	world:insert(plotId, Owner({ player = player, userId = player.UserId }))
	notify(player, Messages.PlotClaimed)
end

local function plotPrompts(world)
	for plotId, plot in world:query(Plot) do
		for _, player in Matter.useEvent(plot.prompt, "Triggered") do
			handleTrigger(world, plotId, plot, player)
		end
	end
end

return { system = plotPrompts, priority = 10 }
