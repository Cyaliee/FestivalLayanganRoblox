--!strict
-- Buka/tutup ScreenGui buatan Studio (UpgradeUI, ShopUI, ...).
-- Server membuka lewat bridge OpenUI; tombol Frame/CloseButton menutup.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Net = require(ReplicatedStorage.Shared.Net)
local UIRef = require(ReplicatedStorage.Shared.UI.UIRef)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)
local UIConfig = require(ReplicatedStorage.Shared.Config.UI)

local OnEvent = Fusion.OnEvent

local ScreenController = {}

local scope = Fusion.scoped(Fusion)
local openStates: { [string]: any } = {}

function ScreenController.setOpen(name: string, open: boolean)
	local state = openStates[name]
	if state then
		state:set(open)
	end
end

local function bindScreen(name: string)
	local gui = UIRef.screen(name)
	if gui == nil then
		return
	end

	local isOpen = scope:Value(false)
	openStates[name] = isOpen

	scope:Hydrate(gui)({
		Enabled = isOpen,
	})

	local closeButton = UIRef.findOfClass(gui, "Frame/CloseButton", "GuiButton")
	if closeButton then
		scope:Hydrate(closeButton)({
			[OnEvent("Activated")] = function()
				isOpen:set(false)
			end,
		})
	end
end

function ScreenController.start()
	for name in UIConfig.OpenableScreens do
		task.spawn(bindScreen, name)
	end

	Net.bridge(NetworkConfig.Bridges.OpenUI):Connect(function(content)
		if type(content) ~= "table" or type(content.Name) ~= "string" then
			return
		end
		if not UIConfig.OpenableScreens[content.Name] then
			return
		end
		ScreenController.setOpen(content.Name, true)
	end)
end

return ScreenController
