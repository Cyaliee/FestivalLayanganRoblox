--!strict
--[[
	Tema UI: gelap metalik (mengikuti script Fusion DonationMenu/Hotbar & referensi Inventory).
	Semua warna, font, ukuran, dan animasi ada di sini.
]]

local function rgb(r: number, g: number, b: number): Color3
	return Color3.fromRGB(r, g, b)
end

return table.freeze({
	Fonts = table.freeze({
		Black = Font.fromEnum(Enum.Font.GothamBlack),
		Bold = Font.fromEnum(Enum.Font.GothamBold),
		Regular = Font.fromEnum(Enum.Font.Gotham),
	}),

	Colors = table.freeze({
		Panel = rgb(25, 25, 25), -- jendela
		PanelSoft = rgb(35, 35, 35), -- kotak di dalam jendela (input, baris)
		Bar = rgb(20, 18, 26), -- hotbar / sidebar
		Button = rgb(63, 63, 63),
		ButtonDark = rgb(35, 33, 43), -- tombol toggle
		Slot = rgb(30, 30, 32),
		SlotActive = rgb(62, 61, 63), -- slot terpilih (HOTBAR_DEFAULT_COLOR)
		Stroke = rgb(255, 255, 255),
		StrokeSubtle = rgb(70, 68, 80),
		Text = rgb(255, 255, 255),
		TextDim = rgb(200, 200, 200),
		TextMuted = rgb(150, 148, 160),
		Money = rgb(255, 206, 60),
		ExpFill = rgb(200, 200, 200),
		Track = rgb(45, 45, 48),
		Danger = rgb(200, 60, 60),
		Success = rgb(70, 170, 90),
		Backdrop = rgb(0, 0, 0),
	}),

	-- Gradient metalik (dipakai tombol & judul)
	MetallicGradient = ColorSequence.new({
		ColorSequenceKeypoint.new(0, rgb(153, 153, 153)),
		ColorSequenceKeypoint.new(1, rgb(77, 77, 77)),
	}),

	Transparency = table.freeze({
		Bar = 0.1,
		PanelStroke = 0.5,
		ButtonStroke = 0.8,
		SlotStroke = 0.5,
		SlotStrokeIdle = 0.5,
	}),

	Sizes = table.freeze({
		Corner = UDim.new(0, 10),
		PanelCorner = UDim.new(0, 12),
		BarCorner = UDim.new(0, 14),

		SlotSize = 44,
		SlotGap = 2,
		BarPadding = 6,

		SidebarButton = 52,
		SidebarGap = 6,

		TextTitle = 20,
		TextBody = 14,
		TextSmall = 11,

		ScreenMargin = 14,
		ToastWidth = 360,
		ToastHeight = 40,
	}),

	Animation = table.freeze({
		HoverScale = 1.05,
		PressScale = 0.94,
		ButtonSpeed = 30,
		ButtonDamping = 0.7,

		WindowSpeed = 28, -- slide dari bawah (seperti DonationMenu)
		WindowDamping = 0.85,
		WindowHiddenOffset = 800,

		CollapseSpeed = 40, -- hotbar & sidebar buka/tutup
		CollapseDamping = 1,
		CollapseHideDelay = 0.3,

		BarSpeed = 14,
		BarDamping = 1,

		BumpScale = 1.12,
		BumpSpeed = 22,
		BumpDamping = 0.5,

		ToastSpeed = 22,
		ToastDamping = 0.8,
		ToastShownY = 64, -- di bawah topbar Roblox (IgnoreGuiInset = true)
		ToastHiddenY = -120,
	}),

	-- Skala responsif: tinggi layar / ReferenceHeight, dibatasi Min..Max (x pilihan Ukuran UI di Setting)
	ReferenceHeight = 1080,
	MinScale = 0.6,
	MaxScale = 1.2,

	-- Warna stroke banner pengumuman (server kirim nama warna)
	AnnouncementColors = table.freeze({
		Gold = rgb(255, 179, 49),
		Red = rgb(255, 53, 67),
		Blue = rgb(24, 143, 255),
		Green = rgb(80, 225, 61),
		Purple = rgb(165, 108, 255),
	}),
})
