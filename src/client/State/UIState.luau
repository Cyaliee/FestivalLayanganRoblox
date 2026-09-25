--!strict
-- State UI lokal: screen yang terbuka, slot hotbar terpilih, notifikasi, skala layar.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UIConfig = require(ReplicatedStorage.Shared.Config.UI)

local scope = Fusion.scoped(Fusion)
local peek = Fusion.peek

local UIState = {}

UIState.Scale = scope:Value(1)
UIState.SelectedSlot = scope:Value(nil :: number?)
UIState.NotificationText = scope:Value("")
UIState.NotificationVisible = scope:Value(false)

UIState.Open = {} :: { [string]: any }
for name in UIConfig.OpenableScreens do
	UIState.Open[name] = scope:Value(false)
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

-- Pilih slot; pilih slot yang sama lagi = batal pilih
function UIState.toggleSlot(index: number)
	if peek(UIState.SelectedSlot) == index then
		UIState.SelectedSlot:set(nil)
	else
		UIState.SelectedSlot:set(index)
	end
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
