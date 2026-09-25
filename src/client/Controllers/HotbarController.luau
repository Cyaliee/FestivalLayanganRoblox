--!strict
-- Tombol angka 1-9 memilih slot hotbar. (Equip item ke server disambungkan di Fase 4.)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local HotbarConfig = require(ReplicatedStorage.Shared.Config.Hotbar)
local UIState = require(script.Parent.Parent.State.UIState)

local HotbarController = {}

local slotByKey: { [Enum.KeyCode]: number } = {}
for index, keyCode in HotbarConfig.KeyCodes do
	if index <= HotbarConfig.SlotCount then
		slotByKey[keyCode] = index
	end
end

function HotbarController.start()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		local index = slotByKey[input.KeyCode]
		if index then
			UIState.toggleSlot(index)
		end
	end)
end

return HotbarController
