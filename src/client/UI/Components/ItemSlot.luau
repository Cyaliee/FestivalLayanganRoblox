--!strict
--[[
	Slot item (hotbar & inventory), gaya referensi: kotak gelap sudut 10 dengan stroke putih tipis.
	- Transparent = true (hotbar): latar transparan, menyala warna aktif saat terpilih
	- Item ber-rarity: stroke berwarna rarity (Uncommon hijau ... Legendary emas)
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local Format = require(ReplicatedStorage.Shared.Util.Format)
local ItemKey = require(ReplicatedStorage.Shared.Rules.ItemKey)
local Style = require(script.Parent.Parent.Style)
local Icon = require(script.Parent.Icon)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Colors = Theme.Colors

export type Props = {
	Name: string?,
	Item: any, -- { Id: string, Count: number, IsTool: boolean? }? (state)
	Selected: any?, -- boolean (state)
	Marked: any?, -- boolean (state): tanda kecil (mis. item sudah di hotbar)
	KeyText: string?, -- angka slot hotbar
	Transparent: boolean?,
	Size: number?,
	LayoutOrder: any?,
	OnActivated: (() -> ())?,
}

local function rarityColor(item): Color3?
	if item == nil or item.IsTool then
		return nil
	end
	local tier = ItemKey.rarity(item.Id)
	if tier and tier.Id ~= "Common" then
		return tier.Color
	end
	return nil
end

return function(scope: any, props: Props): Instance
	local size = props.Size or Theme.Sizes.SlotSize
	local selected = scope:Computed(function(use)
		return use(props.Selected) == true
	end)

	return scope:New("TextButton")({
		Name = props.Name or "Slot",
		Size = UDim2.fromOffset(size, size),
		LayoutOrder = props.LayoutOrder,
		AutoButtonColor = false,
		Text = "",
		BackgroundColor3 = scope:Computed(function(use)
			return if use(selected) then Colors.SlotActive else Colors.Slot
		end),
		BackgroundTransparency = scope:Computed(function(use)
			if use(selected) then
				return 0.15
			end
			return if props.Transparent then 1 else 0.2
		end),
		[OnEvent("Activated")] = function()
			if props.OnActivated then
				props.OnActivated()
			end
		end,
		[Children] = Style.children(
			Style.corner(scope),
			Style.stroke(scope, {
				Thickness = 2,
				Color = scope:Computed(function(use)
					local color = rarityColor(use(props.Item))
					if color then
						return color
					end
					return if use(selected) then Colors.Stroke else Colors.StrokeSubtle
				end),
				Transparency = scope:Computed(function(use)
					if rarityColor(use(props.Item)) or use(selected) then
						return 0
					end
					return Theme.Transparency.SlotStroke
				end),
			}),
			Icon(scope, {
				Name = "Icon",
				Asset = scope:Computed(function(use)
					local item = use(props.Item)
					return if item then UIAssets.Items[(ItemKey.parse(item.Id))] else nil
				end),
				Size = UDim2.fromScale(0.8, 0.8),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
			}),
			props.KeyText and scope:New("TextLabel")({
				Name = "KeyLabel",
				Size = UDim2.fromOffset(14, 14),
				Position = UDim2.fromOffset(3, 1),
				BackgroundTransparency = 1,
				Text = props.KeyText,
				FontFace = Theme.Fonts.Bold,
				TextSize = 10,
				TextColor3 = Colors.TextMuted,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
			scope:New("TextLabel")({
				Name = "Count",
				Size = UDim2.new(1, -4, 0, 12),
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, -3, 1, -2),
				BackgroundTransparency = 1,
				Text = scope:Computed(function(use)
					local item = use(props.Item)
					return if item and item.Count > 1 then Format.number(item.Count) else ""
				end),
				FontFace = Theme.Fonts.Bold,
				TextSize = 11,
				TextColor3 = Colors.Text,
				TextXAlignment = Enum.TextXAlignment.Right,
			}),
			props.Marked and scope:New("Frame")({
				Name = "Mark",
				Size = UDim2.fromOffset(8, 8),
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -4, 0, 4),
				BackgroundColor3 = Colors.Stroke,
				Visible = scope:Computed(function(use)
					return use(props.Marked) == true
				end),
				[Children] = { Style.corner(scope, UDim.new(1, 0)) },
			})
		),
	})
end
