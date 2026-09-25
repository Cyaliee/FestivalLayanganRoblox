--!strict
-- Pasang semua ScreenGui (dibuat dengan Fusion) dan sambungkan ke state & bridge.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Net = require(ReplicatedStorage.Shared.Net)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)
local HotbarConfig = require(ReplicatedStorage.Shared.Config.Hotbar)
local TableConfig = require(ReplicatedStorage.Shared.Config.CraftingTable)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local UIText = require(ReplicatedStorage.Shared.Config.UIText)

local State = script.Parent.Parent.State
local PlayerState = require(State.PlayerState)
local UIState = require(State.UIState)

local Screens = script.Parent.Parent.UI.Screens
local HUD = require(Screens.HUD)
local Hotbar = require(Screens.Hotbar)
local UpgradeUI = require(Screens.UpgradeUI)
local BagUI = require(Screens.BagUI)

local Children = Fusion.Children

local UIController = {}

local scope = Fusion.scoped(Fusion)

local function mount(name: string, displayOrder: number, content: Instance)
	scope:New("ScreenGui")({
		Name = name,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = displayOrder,
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
		[Children] = { content },
	})
end

-- Skala UI mengikuti ukuran layar, relatif ke Theme.ReferenceResolution
local function trackScreenScale()
	local function update()
		local camera = workspace.CurrentCamera
		if camera == nil then
			return
		end
		local viewport = camera.ViewportSize
		local reference = Theme.ReferenceResolution
		local scale = math.min(viewport.X / reference.X, viewport.Y / reference.Y)
		UIState.Scale:set(math.clamp(scale, Theme.MinScale, Theme.MaxScale))
	end

	local connection: RBXScriptConnection? = nil
	local function bindCamera()
		if connection then
			connection:Disconnect()
		end
		local camera = workspace.CurrentCamera
		if camera then
			connection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
		end
		update()
	end

	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
	bindCamera()
end

function UIController.start()
	if HotbarConfig.DisableDefaultBackpack then
		pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		end)
	end

	trackScreenScale()

	local view = PlayerState.view

	mount(
		"HUD",
		1,
		HUD(scope, {
			LevelText = view.LevelText,
			ExpProgress = view.ExpProgress,
			ExpText = view.ExpText,
			CoinsText = view.CoinsText,
			BambooText = view.BambooText,
			KiteText = view.KiteText,
			BagText = view.BagText,
			BagFull = view.BagFull,
			NotificationText = UIState.NotificationText,
			NotificationVisible = UIState.NotificationVisible,
			Scale = UIState.Scale,
			OnBagClick = function()
				UIState.open("BagUI")
			end,
		})
	)

	mount(
		"Hotbar",
		1,
		Hotbar(scope, {
			Items = view.HotbarItems,
			Selected = UIState.SelectedSlot,
			OnSelect = UIState.toggleSlot,
			Scale = UIState.Scale,
		})
	)

	mount(
		"UpgradeUI",
		10,
		UpgradeUI(scope, {
			Open = UIState.Open.UpgradeUI,
			OnClose = function()
				UIState.close("UpgradeUI")
			end,
			CurrentLevel = view.TableLevel,
			MaxLevel = TableConfig.MaxLevel,
			CostText = UIText.CostUnknown, -- Fase 4
			UpgradeText = UIText.ComingSoon, -- Fase 4
			UpgradeDisabled = true, -- Fase 4
			OnUpgrade = function() end,
			Scale = UIState.Scale,
		})
	)

	local bagUpgradeBridge = Net.bridge(NetworkConfig.Bridges.RequestBagUpgrade)
	mount(
		"BagUI",
		10,
		BagUI(scope, {
			Open = UIState.Open.BagUI,
			OnClose = function()
				UIState.close("BagUI")
			end,
			BagLevelText = view.BagLevelText,
			BagUsageText = view.BagUsageText,
			BagNextText = view.BagNextText,
			BagCostText = view.BagCostText,
			BagIsMax = view.BagIsMax,
			BagCanAfford = view.BagCanAfford,
			-- Hanya intent; server yang validasi koin & level
			OnUpgrade = function()
				bagUpgradeBridge:Fire({})
			end,
			Scale = UIState.Scale,
		})
	)

	Net.bridge(NetworkConfig.Bridges.OpenUI):Connect(function(content)
		if type(content) == "table" and type(content.Name) == "string" then
			UIState.open(content.Name)
		end
	end)

	Net.bridge(NetworkConfig.Bridges.Notify):Connect(function(content)
		if type(content) == "table" and type(content.Text) == "string" then
			UIState.notify(content.Text)
		end
	end)
end

return UIController
