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
local Recipes = require(ReplicatedStorage.Shared.Config.Recipes)
local ItemKey = require(ReplicatedStorage.Shared.Rules.ItemKey)

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
	-- Migrasi Fase 4.5: item lama -> item ber-rarity; key tidak dikenal dibuang
	local inventory = profile.Data.Inventory
	local renamed = { KiteBiasa = "Kite@Common", KiteNaga = "Kite@Rare" }
	for oldKey, newKey in renamed do
		if inventory[oldKey] then
			inventory[newKey] = (inventory[newKey] or 0) + inventory[oldKey]
			inventory[oldKey] = nil
		end
	end
	for key, count in inventory do
		if not ItemKey.isValid(key) or type(count) ~= "number" then
			inventory[key] = nil
		end
	end
	local craft = profile.Data.ActiveCraft
	if craft and Recipes[craft.RecipeId] == nil then
		profile.Data.ActiveCraft = nil
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
