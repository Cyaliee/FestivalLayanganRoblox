--!strict
-- Semua komponen Matter di satu tempat (dipakai server & client).
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.Matter)

export type PlotData = {
	model: Model,
	sign: PVInstance,
	prompt: ProximityPrompt,
	tableSpawn: CFrame,
	ownerText: TextLabel?,
}

export type OwnerData = {
	player: Player,
	userId: number,
}

export type CraftingTableData = {
	Level: number,
	model: Model,
	prompt: ProximityPrompt?,
}

export type PlayerEntityData = {
	player: Player,
	userId: number,
}

export type BambooTreeData = {
	model: Instance,
	parent: Instance, -- folder asal (untuk dikembalikan saat respawn)
	position: Vector3,
}

export type ShopNpcData = {
	shopId: string,
	model: Model,
	prompt: ProximityPrompt,
	position: Vector3,
}

export type FlyingData = {
	kiteId: string,
	endsAt: number,
	nextTickAt: number,
	model: Instance,
	anchor: Attachment?,
}

return {
	-- Kavling di Workspace/Plots/*
	Plot = Matter.component("Plot"),
	-- Pemilik kavling (dipasang saat klaim, dilepas saat pemain keluar)
	Owner = Matter.component("Owner"),
	-- Meja Rakit yang sudah di-spawn di kavling
	CraftingTable = Matter.component("CraftingTable"),
	-- Pemain yang datanya sudah selesai dimuat
	PlayerEntity = Matter.component("PlayerEntity"),
	-- Pohon bambu di Workspace/HutanBambu
	BambooTree = Matter.component("BambooTree"),
	TreeHealth = Matter.component("TreeHealth"), -- { hp }
	Felled = Matter.component("Felled"), -- { respawnAt }
	-- NPC pasar
	ShopNpc = Matter.component("ShopNpc"),
	-- Layangan yang sedang terbang (dipasang di entity PlayerEntity)
	Flying = Matter.component("Flying"),
}
