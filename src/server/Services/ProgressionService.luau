--!strict
-- EXP & level pemain. Naik level otomatis saat EXP cukup.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Messages = require(ReplicatedStorage.Shared.Config.Messages)
local Progression = require(ReplicatedStorage.Shared.Rules.Progression)
local DataService = require(script.Parent.DataService)
local notify = require(script.Parent.Parent.Util.Notify)

local ProgressionService = {}

function ProgressionService.addExp(player: Player, amount: number)
	local data = DataService.getData(player)
	if data == nil or amount <= 0 or amount ~= amount then
		return
	end
	data.Exp += math.floor(amount)

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
end

return ProgressionService
