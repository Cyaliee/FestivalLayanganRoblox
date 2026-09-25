--!strict
-- Banner pengumuman global (Bambu Emas, Legendary, Layangan Naga, live event).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local Toast = require(script.Parent.Parent.Components.Toast)

local Children = Fusion.Children

export type Props = {
	Text: any,
	Palette: any, -- nama warna (Theme.AnnouncementColors)
	Visible: any,
	Scale: any?,
}

return function(scope: any, props: Props): Instance
	return scope:New("Frame")({
		Name = "Announcement",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		[Children] = {
			Toast(scope, {
				Name = "Banner",
				Text = props.Text,
				Visible = props.Visible,
				AccentColor = scope:Computed(function(use)
					return Theme.AnnouncementColors[use(props.Palette)] or Theme.Colors.Stroke
				end),
				Size = UDim2.fromOffset(520, 52),
				ShownY = 112,
				TextSize = 16,
				Scale = props.Scale,
			}),
		},
	})
end
