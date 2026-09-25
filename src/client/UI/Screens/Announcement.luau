--!strict
-- Banner pengumuman global (Bambu Emas, Legendary, Layangan Naga, live event).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Toast = require(script.Parent.Parent.Components.Toast)

local Children = Fusion.Children

export type Props = {
	Text: any,
	Palette: any,
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
				Palette = props.Palette,
				Size = UDim2.fromOffset(620, 72),
				ShownY = 84,
				MaxTextSize = 34,
				Scale = props.Scale,
			}),
		},
	})
end
