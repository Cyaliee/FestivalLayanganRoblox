--!strict
--[[
	Hotbar: klik slot atau tombol 1-9.
	  Kapak    -> pilih/lepas (server memasang tool)
	  Layangan -> langsung diterbangkan (server cek Area Festival), pilihan tidak disimpan
	  Bahan    -> hanya dipilih (lepas tool)
	Client hanya kirim id yang dipilih; server yang memvalidasi.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Net = require(ReplicatedStorage.Shared.Net)
local Items = require(ReplicatedStorage.Shared.Config.Items)
local HotbarConfig = require(ReplicatedStorage.Shared.Config.Hotbar)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)

local State = script.Parent.Parent.State
local UIState = require(State.UIState)
local PlayerState = require(State.PlayerState)

local peek = Fusion.peek

local HotbarController = {}

local slotByKey: { [Enum.KeyCode]: number } = {}
for index, keyCode in HotbarConfig.KeyCodes do
	if index <= HotbarConfig.SlotCount then
		slotByKey[keyCode] = index
	end
end

local equipBridge: any = nil

local function sendEquip(id: string?)
	if equipBridge then
		equipBridge:Fire({ Id = id })
	end
end

function HotbarController.activateSlot(index: number)
	local item = peek(PlayerState.view.HotbarItems)[index]
	if item == nil then
		return
	end
	local def = Items[item.Id]
	if def and def.Category == "Kite" then
		-- Aksi sekali: terbangkan, lalu kembali ke pilihan sebelumnya
		sendEquip(item.Id)
		local current = peek(UIState.SelectedItem)
		sendEquip(current)
		return
	end
	sendEquip(UIState.toggleItem(item.Id))
end

function HotbarController.start()
	equipBridge = Net.bridge(NetworkConfig.Bridges.RequestEquip)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		local index = slotByKey[input.KeyCode]
		if index then
			HotbarController.activateSlot(index)
		end
	end)

	-- Setelah respawn tool terlepas; samakan pilihan hotbar
	Players.LocalPlayer.CharacterAdded:Connect(function()
		UIState.SelectedItem:set(nil)
	end)

	-- Item terpilih habis (mis. terjual) -> batal pilih
	local scope = Fusion.scoped(Fusion)
	scope:Observer(PlayerState.view.HotbarItems):onChange(function()
		local selected = peek(UIState.SelectedItem)
		if selected == nil then
			return
		end
		for _, item in peek(PlayerState.view.HotbarItems) do
			if item.Id == selected then
				return
			end
		end
		UIState.SelectedItem:set(nil)
		sendEquip(nil)
	end)
end

return HotbarController
