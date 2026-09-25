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
}

export type PlayerEntityData = {
	player: Player,
	userId: number,
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
}
