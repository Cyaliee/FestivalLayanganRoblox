--!strict
--[[
	Tampilan UI gaya "cartoon simulator": outline tebal, sudut bulat, gradient, tombol timbul.
	Semua warna, font, ukuran, dan animasi ada di sini. Ubah file ini untuk ganti gaya.

	Palette = { Top, Bottom, Shadow }  -> gradient atas ke bawah + warna bayangan tombol
]]

local function rgb(r: number, g: number, b: number): Color3
	return Color3.fromRGB(r, g, b)
end

return table.freeze({
	Font = Font.fromEnum(Enum.Font.FredokaOne),
	TitleFont = Font.fromEnum(Enum.Font.LuckiestGuy),

	Colors = table.freeze({
		Outline = rgb(38, 24, 52),
		Text = rgb(255, 255, 255),
		Backdrop = rgb(0, 0, 0),
		Track = rgb(52, 36, 72),
	}),

	Palettes = table.freeze({
		Panel = { rgb(255, 246, 220), rgb(255, 214, 150), rgb(196, 140, 72) },
		PanelDark = { rgb(110, 84, 168), rgb(66, 46, 112), rgb(40, 26, 70) },
		Primary = { rgb(128, 236, 96), rgb(46, 178, 66), rgb(24, 112, 40) },
		Secondary = { rgb(104, 204, 255), rgb(40, 132, 232), rgb(22, 78, 150) },
		Danger = { rgb(255, 116, 104), rgb(222, 52, 62), rgb(140, 24, 36) },
		Gold = { rgb(255, 234, 96), rgb(255, 172, 32), rgb(178, 100, 10) },
		Slot = { rgb(128, 104, 186), rgb(84, 62, 138), rgb(46, 30, 82) },
		SlotEmpty = { rgb(96, 84, 120), rgb(70, 60, 92), rgb(42, 34, 58) },
		Disabled = { rgb(196, 196, 196), rgb(144, 144, 144), rgb(88, 88, 88) },
		Exp = { rgb(150, 255, 128), rgb(44, 204, 96), rgb(20, 120, 50) },
	}),

	Sizes = table.freeze({
		Outline = 3,
		TextStroke = 2,
		Corner = UDim.new(0, 14),
		CornerSmall = UDim.new(0, 10),
		ShadowOffset = 5, -- tinggi "timbul" tombol (px)
		MaxTextSize = 30,

		PillWidth = 200,
		PillHeight = 42,
		SlotSize = 68,
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
