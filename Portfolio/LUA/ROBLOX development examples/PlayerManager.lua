local PlayerManager = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local services = script.Parent.Parent.services
local utils = script.Parent.Parent.utils

local CharacterMeshRemoverModule = require(script.CharacterMeshRemoverModule)
local PrefloodModule = require(script.PrefloodModule)
local ToolGiverModule = require(script.ToolGiverModule)
local LeaderboardModule = require(script.LeaderboardModule)
local SettingsModule = require(utils.Settings)

local function HandlePlayerAdded(player)		
	if not PrefloodModule.PrefloodSent and game.PrivateServerId == "" and SettingsModule.Prefloodable then
		PrefloodModule.AlertIfRaidersDetected()
	end

	CharacterMeshRemoverModule.RemoveCharacterMesh(player)
	LeaderboardModule.InitializeLeaderstats(player)
end

local function HandleCharacterDeath(player, character)
	LeaderboardModule.HandleCharacterDeath(player, character)
end

local function HandleCharacterAdded(player, character)
	local Humanoid = character:FindFirstChild("Humanoid")
	if Humanoid then
		Humanoid.Died:Connect(function()
			HandleCharacterDeath(player, character)
		end)
	end
	ToolGiverModule.GiveToolsToPlayer(player)
end

local function HandlePlayerRemoved(player)
	LeaderboardModule.HandlePlayerLeave(player)
end

function PlayerManager.init()
	Players.PlayerAdded:Connect(function(player)
		HandlePlayerAdded(player)

		player.CharacterAdded:Connect(function(character)
			HandleCharacterAdded(player, character)
		end)

	end)

	Players.PlayerRemoving:Connect(HandlePlayerRemoved)
end

for _, player in pairs(Players:GetPlayers()) do
	HandlePlayerAdded(player)

	if not player.Character then
		player.CharacterAdded:Wait()
	end
	
	HandleCharacterAdded(player, player.Character)
end

return PlayerManager