--!strict
-- Koin pemain. Semua perubahan koin di server lewat sini.
local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ServerScriptService.Server.Services.DataService)

local WalletService = {}

function WalletService.getCoins(player: Player): number
	local data = DataService.getData(player)
	return if data then data.Coins else 0
end

-- Kurangi koin kalau cukup. true = berhasil.
function WalletService.trySpend(player: Player, amount: number): boolean
	local data = DataService.getData(player)
	if data == nil or amount < 0 or amount ~= amount or data.Coins < amount then
		return false
	end
	data.Coins -= amount
	return true
end

function WalletService.add(player: Player, amount: number)
	local data = DataService.getData(player)
	if data == nil or amount <= 0 or amount ~= amount then
		return
	end
	data.Coins += math.floor(amount)
end

return WalletService
