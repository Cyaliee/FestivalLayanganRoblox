--!strict
-- Terapkan pengaturan di client: musik latar (Sound "Music" di SoundService, opsional).
-- Nametag diatur system nametags; ukuran UI diatur UIController.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local SettingsConfig = require(ReplicatedStorage.Shared.Config.Settings)
local PlayerState = require(script.Parent.Parent.State.PlayerState)

local peek = Fusion.peek

local SettingsController = {}

local function applyMusic()
	local sound = SoundService:FindFirstChild(SettingsConfig.MusicSoundName)
	if sound == nil or not sound:IsA("Sound") then
		return
	end
	local on = peek(PlayerState.Settings).Music ~= false
	sound.Looped = true
	sound.Volume = if on then SettingsConfig.MusicVolume else 0
	if on and not sound.IsPlaying then
		sound:Play()
	end
end

function SettingsController.start()
	local scope = Fusion.scoped(Fusion)
	scope:Observer(PlayerState.Settings):onChange(applyMusic)
	SoundService.ChildAdded:Connect(applyMusic)
	applyMusic()
end

return SettingsController
