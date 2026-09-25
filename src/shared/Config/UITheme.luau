--!strict
--[[
	Tampilan UI gaya "Studded" (meniru kit StuddedUI):
	- warna solid + tekstur stud transparan di atasnya
	- outline & bayangan bawah memakai warna gelap dari warna yang sama
	- teks FredokaOne putih dengan outline hitam
	Semua warna, font, ukuran, dan animasi ada di sini. Ubah file ini untuk ganti gaya.

	Palette = { Surface = warna utama, Dark = warna outline + bayangan }
]]

local function rgb(r: number, g: number, b: number): Color3
	return Color3.fromRGB(r, g, b)
end

local function palette(surface: Color3, dark: Color3)
	return table.freeze({ Surface = surface, Dark = dark })
end

-- Warna diambil dari kit StuddedUI
local Palettes = table.freeze({
	Red = palette(rgb(255, 53, 67), rgb(133, 13, 27)),
	Close = palette(rgb(255, 32, 70), rgb(120, 10, 28)),
	Green = palette(rgb(80, 225, 61), rgb(24, 105, 36)),
	Lime = palette(rgb(85, 255, 0), rgb(8, 109, 36)),
	Blue = palette(rgb(24, 143, 255), rgb(0, 57, 132)),
	Cyan = palette(rgb(27, 202, 226), rgb(0, 92, 121)),
	Teal = palette(rgb(5, 205, 174), rgb(0, 105, 84)),
	Orange = palette(rgb(255, 154, 34), rgb(153, 81, 20)),
	Gold = palette(rgb(255, 179, 49), rgb(162, 92, 8)),
	Purple = palette(rgb(165, 108, 255), rgb(72, 37, 131)),
	Pink = palette(rgb(255, 102, 175), rgb(143, 20, 95)),
	White = palette(rgb(255, 255, 255), rgb(120, 120, 130)),
	Grey = palette(rgb(170, 170, 178), rgb(88, 88, 98)),
	Dark = palette(rgb(58, 58, 72), rgb(20, 20, 28)),
})

return table.freeze({
	Font = Font.fromEnum(Enum.Font.FredokaOne),
	TitleFont = Font.fromEnum(Enum.Font.FredokaOne),

	Colors = table.freeze({
		Text = rgb(255, 255, 255),
		TextStroke = rgb(0, 0, 0),
		Backdrop = rgb(0, 0, 0),
	}),

	Palettes = Palettes,

	-- Warna per fungsi. Isi dengan nama palette di atas.
	Roles = table.freeze({
		Primary = "Green",
		Secondary = "Blue",
		Danger = "Close",
		Disabled = "Grey",
		Coin = "Gold",
		Bamboo = "Green",
		Kite = "Cyan",
		Bag = "Purple",
		BagFull = "Red",
		Level = "Gold",
		Exp = "Lime",
		ExpTrack = "Dark",
		Toast = "Blue",
		Slot = "Blue",
		SlotSelected = "Orange",
		SlotEmpty = "Grey",
		UpgradeWindow = "Orange",
	}),

	-- Kartu profil (kiri bawah), gaya Studded
	Profile = table.freeze({
		Palette = "Teal", -- warna panel
		BadgePalette = "Gold", -- lencana level
		MoneyPalette = "Coin", -- kapsul uang
		Width = 300,
		Height = 112,
		AvatarSize = 88,
	}),

	-- Tekstur stud dari kit StuddedUI
	Studs = table.freeze({
		Image = "rbxassetid://118347284107187",
		TileSize = 90,
		ButtonTransparency = 0.5, -- di tombol & header
		PanelTransparency = 0.85, -- di badan jendela putih
	}),

	Sizes = table.freeze({
		Outline = 3,
		TextStroke = 2,
		Corner = UDim.new(0.16, 0), -- relatif ukuran (seperti kit)
		PanelCorner = UDim.new(0, 16),
		ShadowOffset = 5, -- tinggi bayangan bawah (px)
		MaxTextSize = 30,

		PillWidth = 200,
		PillHeight = 42,
		SlotSize = 64,
		SlotGap = 8,
		ScreenMargin = 16,
		ToastWidth = 440,
		ToastHeight = 56,
	}),

	Animation = table.freeze({
		HoverScale = 1.06,
		PressScale = 0.92,
		SelectedScale = 1.1,
		ButtonSpeed = 30,
		ButtonDamping = 0.5,
		PressSink = 3, -- px tombol turun saat ditekan

		WindowSpeed = 24,
		WindowOpenDamping = 0.6,
		WindowCloseDamping = 1,

		BarSpeed = 14,
		BarDamping = 1,

		BumpScale = 1.15, -- "membal" saat angka berubah (koin, bambu, ...)
		BumpSpeed = 22,
		BumpDamping = 0.45,

		ToastSpeed = 22,
		ToastDamping = 0.7,
		ToastShownY = 12,
		ToastHiddenY = -140,
	}),

	-- Resolusi desain. UI diskalakan otomatis ke layar lain (HP/tablet/monitor besar).
	ReferenceResolution = Vector2.new(1280, 720),
	MinScale = 0.55,
	MaxScale = 1.3,
})
