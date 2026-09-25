--!strict
--[[
	UIRef: cari elemen UI buatan Studio berdasarkan NAMA.
	Tidak pernah error; kalau elemen tidak ketemu, kasih warn sekali per path
	supaya layout bisa diubah tanpa bikin game crash.

	UIRef.find(root, "StatusPanel/ExpBar/Fill")
	UIRef.screen("HUD")                 -- ScreenGui di PlayerGui (client)
	UIRef.template("HotbarSlot")        -- template di ReplicatedStorage/UITemplates
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIRef = {}

UIRef.TemplatesFolderName = "UITemplates"
UIRef.WaitTimeout = 5

local warned: { [string]: boolean } = {}

local function warnOnce(key: string, message: string)
	if warned[key] then
		return
	end
	warned[key] = true
	warn(`[UIRef] {message}`)
end

local function describe(root: Instance?): string
	return if root then root:GetFullName() else "nil"
end

-- Cari elemen dengan path "A/B/C" relatif ke root. Return nil + warn kalau tidak ketemu.
function UIRef.find(root: Instance?, path: string): Instance?
	if root == nil then
		warnOnce(`nilroot:{path}`, `Root nil saat mencari "{path}"`)
		return nil
	end

	local current: Instance = root
	for _, segment in string.split(path, "/") do
		if segment ~= "" then
			local child = current:FindFirstChild(segment)
			if child == nil then
				warnOnce(
					`{describe(root)}:{path}`,
					`Elemen tidak ketemu: {describe(root)}/{path} (berhenti di "{segment}"). Cek UI_CONTRACT.md`
				)
				return nil
			end
			current = child
		end
	end
	return current
end

-- Sama seperti find, tapi juga cek ClassName (IsA). Return nil + warn kalau class salah.
function UIRef.findOfClass(root: Instance?, path: string, className: string): any
	local instance = UIRef.find(root, path)
	if instance and not instance:IsA(className) then
		warnOnce(
			`class:{describe(root)}:{path}`,
			`{describe(root)}/{path} harus {className}, tapi ketemu {instance.ClassName}`
		)
		return nil
	end
	return instance
end

-- Client: ambil ScreenGui dari PlayerGui (menunggu sebentar karena StarterGui di-clone saat spawn).
function UIRef.screen(name: string): ScreenGui?
	local player = Players.LocalPlayer
	if player == nil then
		warnOnce(`screen:{name}`, `UIRef.screen("{name}") hanya bisa dipanggil di client`)
		return nil
	end
	local playerGui = player:WaitForChild("PlayerGui")
	local gui = playerGui:WaitForChild(name, UIRef.WaitTimeout)
	if gui == nil then
		warnOnce(`screen:{name}`, `ScreenGui "{name}" tidak ada di StarterGui/PlayerGui. Cek UI_CONTRACT.md`)
		return nil
	end
	if not gui:IsA("LayerCollector") then
		warnOnce(`screenclass:{name}`, `"{name}" harus ScreenGui, ketemu {gui.ClassName}`)
		return nil
	end
	return gui :: ScreenGui
end

-- Ambil template dari ReplicatedStorage/UITemplates (belum di-clone).
function UIRef.template(name: string): Instance?
	local folder = ReplicatedStorage:FindFirstChild(UIRef.TemplatesFolderName)
	if folder == nil then
		warnOnce("templates", `Folder ReplicatedStorage/{UIRef.TemplatesFolderName} tidak ada`)
		return nil
	end
	return UIRef.find(folder, name)
end

return UIRef
