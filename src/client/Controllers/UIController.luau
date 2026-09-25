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
local ShopsConfig = require(ReplicatedStorage.Shared.Config.Shops)
local ItemKey = require(ReplicatedStorage.Shared.Rules.ItemKey)

local State = script.Parent.Parent.State
local PlayerState = require(State.PlayerState)
local UIState = require(State.UIState)

local Screens = script.Parent.Parent.UI.Screens
local HUD = require(Screens.HUD)
local Hotbar = require(Screens.Hotbar)
local UpgradeUI = require(Screens.UpgradeUI)
local BagUI = require(Screens.BagUI)
local ShopUI = require(Screens.ShopUI)
local CraftUI = require(Screens.CraftUI)
local Announcement = require(Screens.Announcement)
local HotbarController = require(script.Parent.HotbarController)

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
			DisplayName = Players.LocalPlayer.DisplayName,
			UserId = Players.LocalPlayer.UserId,
			MoneyText = view.MoneyText,
			LevelCardText = view.LevelCardText,
			ExpShortText = view.ExpShortText,
			ExpProgress = view.ExpProgress,
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
			Selected = UIState.SelectedItem,
			OnSelect = HotbarController.activateSlot,
			Scale = UIState.Scale,
			FlightVisible = scope:Computed(function(use)
				return use(UIState.FlightKite) ~= nil
			end),
			FlightProgress = scope:Computed(function(use)
				local remaining = use(UIState.FlightEndsAt) - use(UIState.ServerTime)
				return math.clamp(remaining / math.max(use(UIState.FlightDuration), 1), 0, 1)
			end),
			FlightText = scope:Computed(function(use)
				local kiteKey = use(UIState.FlightKite)
				if kiteKey == nil or not ItemKey.isValid(kiteKey) then
					return ""
				end
				local remaining = math.max(0, math.ceil(use(UIState.FlightEndsAt) - use(UIState.ServerTime)))
				return string.format(UIText.FlightText, ItemKey.displayName(kiteKey), string.format(UIText.Seconds, remaining))
			end),
		})
	)

	local tableUpgradeBridge = Net.bridge(NetworkConfig.Bridges.RequestTableUpgrade)
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
			CostText = view.TableCostText,
			InfoText = view.TableInfoText,
			UpgradeText = scope:Computed(function(use)
				if use(view.TableIsMax) then
					return UIText.MaxLevel
				end
				return if use(view.TableCanAfford) then UIText.UpgradeButton else UIText.BagNotEnoughCoins
			end),
			UpgradeDisabled = scope:Computed(function(use)
				return use(view.TableIsMax) or not use(view.TableCanAfford)
			end),
			-- Hanya intent; server cek kepemilikan, jarak, koin
			OnUpgrade = function()
				tableUpgradeBridge:Fire({})
			end,
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

	-- Pasar: satu jendela per shop
	local tradeBridge = Net.bridge(NetworkConfig.Bridges.RequestTrade)
	for shopId, shop in ShopsConfig.Shops do
		local screenName = ShopsConfig.screenName(shopId)
		mount(
			screenName,
			10,
			ShopUI(scope, {
				Shop = shop,
				Open = UIState.Open[screenName],
				OnClose = function()
					UIState.close(screenName)
				end,
				Inventory = PlayerState.Inventory,
				Coins = PlayerState.Coins,
				OnTrade = function(itemKey, mode)
					tradeBridge:Fire({ ShopId = shopId, ItemKey = itemKey, Mode = mode })
				end,
				Scale = UIState.Scale,
			})
		)
	end

	-- Crafting
	local craftBridge = Net.bridge(NetworkConfig.Bridges.RequestCraft)
	mount(
		"CraftUI",
		10,
		CraftUI(scope, {
			Open = UIState.Open.CraftUI,
			OnClose = function()
				UIState.close("CraftUI")
			end,
			Inventory = PlayerState.Inventory,
			TableLevel = PlayerState.TableLevel,
			ActiveRecipe = PlayerState.ActiveCraftRecipe,
			ActiveEndsAt = PlayerState.ActiveCraftEndsAt,
			ServerTime = UIState.ServerTime,
			OnCraft = function(recipeId, useBooster)
				craftBridge:Fire({ RecipeId = recipeId, UseBooster = useBooster })
			end,
			Luck = UIState.Luck,
			DragonActive = scope:Computed(function(use)
				return use(PlayerState.PlacedDragon) ~= ""
			end),
			Scale = UIState.Scale,
		})
	)

	-- Pengumuman global
	mount(
		"Announcement",
		20,
		Announcement(scope, {
			Text = UIState.AnnouncementText,
			Palette = UIState.AnnouncementPalette,
			Visible = UIState.AnnouncementVisible,
			Scale = UIState.Scale,
		})
	)
	Net.bridge(NetworkConfig.Bridges.Announce):Connect(function(content)
		if type(content) == "table" and type(content.Text) == "string" then
			UIState.announce(content.Text, if type(content.Palette) == "string" then content.Palette else nil)
		end
	end)

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
