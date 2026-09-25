--!strict
-- Pasang semua ScreenGui (Fusion, tone gelap metalik) dan sambungkan ke state & bridge.
local MarketplaceService = game:GetService("MarketplaceService")
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
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local ShopsConfig = require(ReplicatedStorage.Shared.Config.Shops)
local Gamepasses = require(ReplicatedStorage.Shared.Config.Gamepasses)
local SettingsConfig = require(ReplicatedStorage.Shared.Config.Settings)
local ItemKey = require(ReplicatedStorage.Shared.Rules.ItemKey)

local State = script.Parent.Parent.State
local PlayerState = require(State.PlayerState)
local UIState = require(State.UIState)
local HotbarController = require(script.Parent.HotbarController)

local Screens = script.Parent.Parent.UI.Screens
local HUD = require(Screens.HUD)
local Hotbar = require(Screens.Hotbar)
local Inventory = require(Screens.Inventory)
local BagUI = require(Screens.BagUI)
local ShopUI = require(Screens.ShopUI)
local MarketUI = require(Screens.MarketUI)
local CraftUI = require(Screens.CraftUI)
local UpgradeUI = require(Screens.UpgradeUI)
local SettingsUI = require(Screens.SettingsUI)
local InfoUI = require(Screens.InfoUI)
local Announcement = require(Screens.Announcement)

local Children = Fusion.Children
local peek = Fusion.peek

local UIController = {}

local scope = Fusion.scoped(Fusion)
local player = Players.LocalPlayer

local function mount(name: string, displayOrder: number, content: Instance)
	scope:New("ScreenGui")({
		Name = name,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = displayOrder,
		Parent = player:WaitForChild("PlayerGui"),
		[Children] = { content },
	})
end

-- Skala UI: tinggi layar / 1080 (dibatasi), dikali pilihan "Ukuran UI" di Setting
local function trackScreenScale()
	local function update()
		local camera = workspace.CurrentCamera
		if camera == nil then
			return
		end
		local base = math.clamp(camera.ViewportSize.Y / Theme.ReferenceHeight, Theme.MinScale, Theme.MaxScale)
		local choice = peek(PlayerState.Settings).UIScale
		UIState.Scale:set(base * (SettingsConfig.UIScaleValues[choice] or 1))
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
	scope:Observer(PlayerState.Settings):onChange(update)
	bindCamera()
end

-- Gamepass: status dimiliki (attribute Pass_<Key> dari server) & harga Robux
local function gamepassState()
	local owned = scope:Value({})
	local prices = scope:Value({})

	local function refreshOwned()
		local map = {}
		for key in Gamepasses.Passes do
			map[key] = player:GetAttribute(Gamepasses.OwnedAttributePrefix .. key) == true
		end
		owned:set(map)
	end
	player.AttributeChanged:Connect(function(name)
		if string.sub(name, 1, #Gamepasses.OwnedAttributePrefix) == Gamepasses.OwnedAttributePrefix then
			refreshOwned()
		end
	end)
	refreshOwned()

	task.spawn(function()
		local map = {}
		for key, pass in Gamepasses.Passes do
			if pass.Id ~= 0 then
				local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, pass.Id, Enum.InfoType.GamePass)
				if ok and info and info.PriceInRobux then
					map[key] = info.PriceInRobux
				end
			end
		end
		prices:set(map)
	end)

	local function buy(key: string)
		local pass = Gamepasses.Passes[key]
		if pass and pass.Id ~= 0 then
			MarketplaceService:PromptGamePassPurchase(player, pass.Id)
		end
	end

	return owned, prices, buy
end

local function flightProps()
	return {
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
	}
end

local function closer(name: string)
	return function()
		UIState.close(name)
	end
end

function UIController.start()
	if HotbarConfig.DisableDefaultBackpack then
		pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		end)
	end
	trackScreenScale()

	local view = PlayerState.view
	local scale = UIState.Scale

	-- HUD: profil kiri bawah + sidebar kiri + notifikasi
	mount(
		"HUD",
		1,
		HUD(scope, {
			DisplayName = player.DisplayName,
			UserId = player.UserId,
			MoneyText = view.MoneyText,
			LevelCardText = view.LevelCardText,
			ExpShortText = view.ExpShortText,
			ExpProgress = view.ExpProgress,
			SidebarEntries = {
				{ Name = "Shop", Icon = UIAssets.Icons.Shop, OnActivated = function() UIState.toggle("Shop") end },
				{ Name = "Inventory", Icon = UIAssets.Icons.Inventory, OnActivated = function() UIState.toggle("Inventory") end },
				{ Name = "Setting", Icon = UIAssets.Icons.Settings, OnActivated = function() UIState.toggle("SettingsUI") end },
				{ Name = "Information", Icon = UIAssets.Icons.Info, OnActivated = function() UIState.toggle("InfoUI") end },
			},
			SidebarOpen = UIState.SidebarOpen,
			NotificationText = UIState.NotificationText,
			NotificationVisible = UIState.NotificationVisible,
			Scale = scale,
		})
	)

	-- Hotbar
	local hotbarProps: any = {
		Items = view.HotbarItems,
		Selected = UIState.SelectedItem,
		OnSelect = HotbarController.activateSlot,
		Open = UIState.HotbarOpen,
		Scale = scale,
	}
	for key, value in flightProps() do
		hotbarProps[key] = value
	end
	mount("Hotbar", 2, Hotbar(scope, hotbarProps))

	-- Inventory (klik item -> pasang/lepas dari hotbar)
	local hotbarToggleBridge = Net.bridge(NetworkConfig.Bridges.RequestHotbarToggle)
	mount(
		"Inventory",
		10,
		Inventory(scope, {
			Open = UIState.Open.Inventory,
			OnClose = closer("Inventory"),
			Inventory = PlayerState.Inventory,
			Hotbar = PlayerState.Hotbar,
			BagText = view.InventoryBagText,
			OnToggleHotbar = function(key)
				hotbarToggleBridge:Fire({ Key = key })
			end,
			OnUpgradeBag = function()
				UIState.open("BagUI")
			end,
			Scale = scale,
		})
	)

	-- Upgrade Tas
	local bagUpgradeBridge = Net.bridge(NetworkConfig.Bridges.RequestBagUpgrade)
	mount(
		"BagUI",
		11,
		BagUI(scope, {
			Open = UIState.Open.BagUI,
			OnClose = closer("BagUI"),
			BagLevelText = view.BagLevelText,
			BagUsageText = view.BagUsageText,
			BagNextText = view.BagNextText,
			BagCostText = view.BagCostText,
			BagIsMax = view.BagIsMax,
			BagCanAfford = view.BagCanAfford,
			OnUpgrade = function()
				bagUpgradeBridge:Fire({})
			end,
			Scale = scale,
		})
	)

	-- Shop gamepass
	local owned, prices, buy = gamepassState()
	mount(
		"Shop",
		10,
		ShopUI(scope, {
			Open = UIState.Open.Shop,
			OnClose = closer("Shop"),
			Owned = owned,
			Prices = prices,
			OnBuy = buy,
			Scale = scale,
		})
	)

	-- Pasar NPC: satu jendela per shop
	local tradeBridge = Net.bridge(NetworkConfig.Bridges.RequestTrade)
	for shopId, shop in ShopsConfig.Shops do
		local screenName = ShopsConfig.screenName(shopId)
		mount(
			screenName,
			10,
			MarketUI(scope, {
				Shop = shop,
				Open = UIState.Open[screenName],
				OnClose = closer(screenName),
				Inventory = PlayerState.Inventory,
				Coins = PlayerState.Coins,
				OnTrade = function(itemKey, mode)
					tradeBridge:Fire({ ShopId = shopId, ItemKey = itemKey, Mode = mode })
				end,
				Scale = scale,
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
			OnClose = closer("CraftUI"),
			Inventory = PlayerState.Inventory,
			TableLevel = PlayerState.TableLevel,
			ActiveRecipe = PlayerState.ActiveCraftRecipe,
			ActiveEndsAt = PlayerState.ActiveCraftEndsAt,
			ServerTime = UIState.ServerTime,
			Luck = UIState.Luck,
			DragonActive = scope:Computed(function(use)
				return use(PlayerState.PlacedDragon) ~= ""
			end),
			OnCraft = function(recipeId, useBooster)
				craftBridge:Fire({ RecipeId = recipeId, UseBooster = useBooster })
			end,
			Scale = scale,
		})
	)

	-- Upgrade Meja Rakit
	local tableUpgradeBridge = Net.bridge(NetworkConfig.Bridges.RequestTableUpgrade)
	mount(
		"UpgradeUI",
		10,
		UpgradeUI(scope, {
			Open = UIState.Open.UpgradeUI,
			OnClose = closer("UpgradeUI"),
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
			OnUpgrade = function()
				tableUpgradeBridge:Fire({})
			end,
			Scale = scale,
		})
	)

	-- Setting (ubah langsung di client supaya responsif; server tetap memvalidasi & menyimpan)
	local settingBridge = Net.bridge(NetworkConfig.Bridges.RequestSetting)
	mount(
		"SettingsUI",
		10,
		SettingsUI(scope, {
			Open = UIState.Open.SettingsUI,
			OnClose = closer("SettingsUI"),
			Values = PlayerState.Settings,
			OnChange = function(key, value)
				local settings = table.clone(peek(PlayerState.Settings))
				settings[key] = value
				PlayerState.Settings:set(settings)
				settingBridge:Fire({ Key = key, Value = value })
			end,
			Scale = scale,
		})
	)

	-- Information
	mount("InfoUI", 10, InfoUI(scope, { Open = UIState.Open.InfoUI, OnClose = closer("InfoUI"), Scale = scale }))

	-- Pengumuman global
	mount(
		"Announcement",
		20,
		Announcement(scope, {
			Text = UIState.AnnouncementText,
			Palette = UIState.AnnouncementPalette,
			Visible = UIState.AnnouncementVisible,
			Scale = scale,
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
