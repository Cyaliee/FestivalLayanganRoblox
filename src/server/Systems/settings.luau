--!strict
-- Ubah pengaturan pemain: { Key, Value } divalidasi terhadap Config/Settings.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SettingsConfig = require(ReplicatedStorage.Shared.Config.Settings)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)

local Server = script.Parent.Parent
local DataService = require(Server.Services.DataService)
local IntentQueue = require(Server.Util.IntentQueue)
local RateLimiter = require(Server.Util.RateLimiter)

local BRIDGE = NetworkConfig.Bridges.RequestSetting
IntentQueue.listen(BRIDGE)
local limiter = RateLimiter.new(NetworkConfig.RateLimits.Setting)

local function isValid(setting: SettingsConfig.Setting, value: any): boolean
	if setting.Type == "Toggle" then
		return type(value) == "boolean"
	end
	if setting.Type == "Choice" and type(value) == "string" and setting.Options then
		return table.find(setting.Options, value) ~= nil
	end
	return false
end

local function handle(player: Player, payload: any)
	if player.Parent ~= Players or not limiter:check(player) or type(payload) ~= "table" then
		return
	end
	local data = DataService.getData(player)
	local setting = SettingsConfig.Settings[payload.Key]
	if data == nil or setting == nil or not isValid(setting, payload.Value) then
		return
	end
	data.Settings[setting.Key] = payload.Value
end

local function settings(_world)
	for _, intent in IntentQueue.drain(BRIDGE) do
		handle(intent.player, intent.payload)
	end
end

return { system = settings, priority = 50 }
