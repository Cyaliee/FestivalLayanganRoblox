--!strict
-- Tampilkan notifikasi dari server di HUD/Notification (TextLabel buatan Studio).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Net = require(ReplicatedStorage.Shared.Net)
local UIRef = require(ReplicatedStorage.Shared.UI.UIRef)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)
local UIConfig = require(ReplicatedStorage.Shared.Config.UI)

local NotificationController = {}

local scope = Fusion.scoped(Fusion)
local text = scope:Value("")
local visible = scope:Value(false)
local showToken = 0

function NotificationController.show(message: string)
	showToken += 1
	local token = showToken
	text:set(message)
	visible:set(true)
	task.delay(UIConfig.NotificationDuration, function()
		if token == showToken then
			visible:set(false)
		end
	end)
end

function NotificationController.start()
	task.spawn(function()
		local label = UIRef.findOfClass(UIRef.screen("HUD"), "Notification", "TextLabel")
		if label then
			scope:Hydrate(label)({
				Text = text,
				Visible = visible,
			})
		end
	end)

	Net.bridge(NetworkConfig.Bridges.Notify):Connect(function(content)
		if type(content) == "table" and type(content.Text) == "string" then
			NotificationController.show(content.Text)
		end
	end)
end

return NotificationController
