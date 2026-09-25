--!strict
-- Kepemilikan gamepass (dicek server) & pengali EXP/Luck. Efek menumpuk (dikali).
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Gamepasses = require(ReplicatedStorage.Shared.Config.Gamepasses)

local GamepassService = {}

local owned: { [Player]: { [string]: boolean } } = {}
-- Override khusus Studio (DevCommands): { [Player]: { [passKey]: true } }
local devOverrides: { [Player]: { [string]: boolean } } = {}

local function publishAttributes(player: Player)
	player:SetAttribute(Gamepasses.ExpAttribute, GamepassService.expMultiplier(player))
	player:SetAttribute(Gamepasses.LuckAttribute, GamepassService.luckMultiplier(player))
end

local function refresh(player: Player)
	local list = {}
	for key, pass in Gamepasses.Passes do
		if pass.Id ~= 0 then
			local ok, result = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, pass.Id)
			list[key] = ok and result == true
		end
	end
	if player.Parent == Players then
		owned[player] = list
		publishAttributes(player)
	end
end

function GamepassService.owns(player: Player, passKey: string): boolean
	local dev = devOverrides[player]
	if dev and dev[passKey] then
		return true
	end
	local list = owned[player]
	return list ~= nil and list[passKey] == true
end

local function multiplier(player: Player, field: "ExpMultiplier" | "LuckMultiplier"): number
	local result = 1
	for key, pass in Gamepasses.Passes do
		local value = pass[field]
		if value and GamepassService.owns(player, key) then
			result *= value
		end
	end
	return result
end

function GamepassService.expMultiplier(player: Player): number
	return multiplier(player, "ExpMultiplier")
end

function GamepassService.luckMultiplier(player: Player): number
	return multiplier(player, "LuckMultiplier")
end

-- Studio saja: nyalakan/matikan gamepass untuk testing
function GamepassService.setDevOverride(player: Player, passKey: string, enabled: boolean)
	devOverrides[player] = devOverrides[player] or {}
	devOverrides[player][passKey] = enabled or nil
	publishAttributes(player)
end

function GamepassService.start()
	for _, player in Players:GetPlayers() do
		task.spawn(refresh, player)
	end
	Players.PlayerAdded:Connect(refresh)
	Players.PlayerRemoving:Connect(function(player)
		owned[player] = nil
		devOverrides[player] = nil
	end)
	-- Beli di tengah game -> langsung aktif
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
		if not purchased then
			return
		end
		for key, pass in Gamepasses.Passes do
			if pass.Id == passId then
				owned[player] = owned[player] or {}
				owned[player][key] = true
				publishAttributes(player)
			end
		end
	end)
end

return GamepassService
