--!strict
-- EXP & level pemain. Naik level otomatis saat EXP cukup.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Messages = require(ReplicatedStorage.Shared.Config.Messages)
local Progression = require(ReplicatedStorage.Shared.Rules.Progression)
local Dragon = require(ReplicatedStorage.Shared.Config.Dragon)
local DataService = require(script.Parent.DataService)
local GamepassService = require(script.Parent.GamepassService)
local AuraService = require(script.Parent.AuraService)
local notify = require(script.Parent.Parent.Util.Notify)

local ProgressionService = {}

-- Pengali EXP pemain: gamepass (menumpuk) x Social Buff Aura Naga
function ProgressionService.expMultiplier(player: Player): number
	local multiplier = GamepassService.expMultiplier(player)
	if AuraService.hasSocialBuff(player) then
		multiplier *= 1 + Dragon.SocialExpBonus
	end
	return multiplier
end

-- Tambah EXP (sudah termasuk pengali). return EXP yang benar-benar ditambahkan.
function ProgressionService.addExp(player: Player, amount: number): number
	local data = DataService.getData(player)
	if data == nil or amount <= 0 or amount ~= amount then
		return 0
	end
	local gained = math.floor(amount * ProgressionService.expMultiplier(player))
	data.Exp += gained

	local leveled = false
	while not Progression.isMaxLevel(data.Level) and data.Exp >= Progression.expToNext(data.Level) do
		data.Exp -= Progression.expToNext(data.Level)
		data.Level += 1
		leveled = true
	end
	if Progression.isMaxLevel(data.Level) then
		data.Exp = 0
	end
	if leveled then
		notify(player, string.format(Messages.LevelUp, data.Level))
	end
	return gained
end

return ProgressionService
