--!strict
-- Data pemain di client (Fusion Value), diisi dari snapshot server via BridgeNet2.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local PlayerData = require(ReplicatedStorage.Shared.Config.PlayerData)
local Items = require(ReplicatedStorage.Shared.Config.Items)
local PlayerView = require(script.Parent.PlayerView)

local scope = Fusion.scoped(Fusion)
local defaults = PlayerData.buildTemplate()

local PlayerState = {}

PlayerState.Loaded = scope:Value(false)
PlayerState.Coins = scope:Value(defaults.Coins)
PlayerState.Level = scope:Value(defaults.Level)
PlayerState.Exp = scope:Value(defaults.Exp)
PlayerState.BagLevel = scope:Value(defaults.BagLevel)
PlayerState.TableLevel = scope:Value(defaults.TableLevel)
PlayerState.Inventory = scope:Value(defaults.Inventory)

PlayerState.view = PlayerView.derive(scope, PlayerState)

local NUMBER_FIELDS = { "Coins", "Level", "Exp", "BagLevel", "TableLevel" }

local function isNumber(value: any): boolean
	return type(value) == "number" and value == value
end

-- Terapkan snapshot dari server. Field yang tidak valid diabaikan.
function PlayerState.apply(snapshot: any)
	if type(snapshot) ~= "table" then
		return
	end

	for _, field in NUMBER_FIELDS do
		local value = snapshot[field]
		if isNumber(value) then
			(PlayerState :: any)[field]:set(value)
		end
	end

	if type(snapshot.Inventory) == "table" then
		local inventory = {}
		for id in Items do
			local count = snapshot.Inventory[id]
			inventory[id] = if isNumber(count) then count else 0
		end
		PlayerState.Inventory:set(inventory)
	end

	PlayerState.Loaded:set(true)
end

return PlayerState
