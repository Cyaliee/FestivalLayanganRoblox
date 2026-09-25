--!strict
--[[
	DataService: memuat & menyimpan data pemain via ProfileStore.
	Data (profile.Data) adalah sumber kebenaran yang disimpan; system ECS membacanya
	lewat DataService.getData(player) dan mengubahnya HANYA di server.
]]
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileStore = require(ServerScriptService.ServerPackages.ProfileStore)
local PlayerDataConfig = require(ReplicatedStorage.Shared.Config.PlayerData)

export type Data = PlayerDataConfig.Data

local DataService = {}

local store = ProfileStore.New(PlayerDataConfig.StoreName, PlayerDataConfig.buildTemplate())
local profiles: { [Player]: any } = {}

local function onPlayerAdded(player: Player)
	local profile = store:StartSessionAsync(tostring(player.UserId), {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if profile == nil then
		-- Session gagal dimulai (mis. server lain belum lepas, atau pemain keluar duluan)
		if player.Parent == Players then
			player:Kick("Gagal memuat data. Silakan join ulang.")
		end
		return
	end

	profile:AddUserId(player.UserId) -- GDPR
	profile:Reconcile() -- isi key baru dari template
	-- Migrasi: field lama BagTier -> BagLevel
	if profile.Data.BagTier ~= nil then
		profile.Data.BagLevel = profile.Data.BagTier
		profile.Data.BagTier = nil
	end

	profile.OnSessionEnd:Connect(function()
		profiles[player] = nil
		if player.Parent == Players then
			player:Kick("Data kamu dibuka di server lain. Silakan join ulang.")
		end
	end)

	if player.Parent == Players then
		profiles[player] = profile
	else
		profile:EndSession()
	end
end

local function onPlayerRemoving(player: Player)
	local profile = profiles[player]
	if profile ~= nil then
		profile:EndSession()
	end
end

function DataService.start()
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
end

function DataService.isLoaded(player: Player): boolean
	return profiles[player] ~= nil
end

-- Data mutable milik pemain. nil kalau belum dimuat.
function DataService.getData(player: Player): Data?
	local profile = profiles[player]
	return if profile then profile.Data else nil
end

return DataService
