--!strict
-- State UI lokal: screen yang terbuka, slot hotbar terpilih, notifikasi, skala layar.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UIConfig = require(ReplicatedStorage.Shared.Config.UI)
local ShopsConfig = require(ReplicatedStorage.Shared.Config.Shops)

local scope = Fusion.scoped(Fusion)
local peek = Fusion.peek

local UIState = {}

UIState.Scale = scope:Value(1)
UIState.SelectedItem = scope:Value(nil :: string?) -- id item/tool terpilih di hotbar
UIState.ServerTime = scope:Value(0) -- workspace:GetServerTimeNow(), diperbarui system clock

-- Layangan yang sedang terbang (dari attribute Player, diperbarui system flightStatus)
UIState.FlightKite = scope:Value(nil :: string?)
UIState.FlightEndsAt = scope:Value(0)
UIState.FlightDuration = scope:Value(1)
UIState.NotificationText = scope:Value("")
UIState.NotificationVisible = scope:Value(false)

UIState.Open = {} :: { [string]: any }
for name in UIConfig.OpenableScreens do
	UIState.Open[name] = scope:Value(false)
end
for shopId in ShopsConfig.Shops do
	UIState.Open[ShopsConfig.screenName(shopId)] = scope:Value(false)
end

-- Buka satu screen, tutup yang lain
function UIState.open(name: string)
	if UIState.Open[name] == nil then
		return
	end
	for other, value in UIState.Open do
		value:set(other == name)
	end
end

function UIState.close(name: string)
	local value = UIState.Open[name]
	if value then
		value:set(false)
	end
end

-- Pilih item hotbar; pilih yang sama lagi = batal pilih. return id terpilih sekarang.
function UIState.toggleItem(id: string?): string?
	local nextId = if peek(UIState.SelectedItem) == id then nil else id
	UIState.SelectedItem:set(nextId)
	return nextId
end

local notifyToken = 0
function UIState.notify(text: string)
	notifyToken += 1
	local token = notifyToken
	UIState.NotificationText:set(text)
	UIState.NotificationVisible:set(true)
	task.delay(UIConfig.NotificationDuration, function()
		if token == notifyToken then
			UIState.NotificationVisible:set(false)
		end
	end)
end

return UIState
