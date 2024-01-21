local LeaderboardModule = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")

script.tick.Parent = StarterPlayer.StarterPlayerScripts
script.Ping.Parent = ReplicatedStorage
script.KillstreakNotify.Parent = ReplicatedStorage

local pingRemote = ReplicatedStorage:FindFirstChild("Ping")
local notifyRemote = ReplicatedStorage:FindFirstChild("KillstreakNotify")

local Announcer = require(script.Parent.Parent.Parent.utils.Announcer)

local scriptLeaderstats = script.leaderstats
local scriptKills = script.Kills

local killsName = scriptLeaderstats.Kills.Name
local deathsName = scriptLeaderstats.Deaths.Name

local streakTable = {}
local killTable = {}

local function updatePingAsync(player)
	local plrPing = player.leaderstats:WaitForChild("Ping")

	while wait(0.5) do
		local one = tick()

		local success, errorOrResult = pcall(function()
			pingRemote:InvokeClient(player)
		end)

		local two = tick() - one

		if success then
			plrPing.Value = math.floor(two * 1000)
		else
			warn("Error invoking client for player " .. player.Name .. ": " .. tostring(errorOrResult))
		end
	end
end


local function incrementKD(player, char)
	local deaths = player.leaderstats.Deaths
	deaths.Value = deaths.Value + 1
	streakTable[player.Name] = 0

	local humanoid = char:FindFirstChild("Humanoid")
	local creator = humanoid and humanoid:FindFirstChild("creator")

	if creator then
		local killerPlayer = Players:FindFirstChild(creator.Value.Name)
		local killerStats = killerPlayer and killerPlayer:FindFirstChild("leaderstats")

		local kills = killerStats and killerStats:FindFirstChild(killsName)

		if kills then
			kills.Value = kills.Value + 1

			streakTable[creator.Value.Name] = streakTable[creator.Value.Name] + 1
			local streakValue = streakTable[creator.Value.Name]

			local killTableEntry = killTable[tostring(streakValue)]
			if killTableEntry then
				local message = creator.Value.Name .. " is on a " .. tostring(streakValue) .. " killstreak!"
				Announcer.AnnounceKillstreak(message, killTableEntry)

				local sound = scriptKills[tostring(streakValue)].Sound:Clone()
				sound.Parent = Workspace
				sound:Play()
				task.wait(5)
				sound:Destroy()
			end
		end
	end
end

function LeaderboardModule.HandleCharacterDeath(player, char)
	streakTable[player.Name] = 0
	incrementKD(player, char)
end

function LeaderboardModule.HandlePlayerLeave(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	local killsValue = leaderstats and leaderstats:FindFirstChild("Kills") and leaderstats.Kills.Value or 0
	local deathsValue = leaderstats and leaderstats:FindFirstChild("Deaths") and leaderstats.Deaths.Value or 0
	Announcer.SayMessage(player.Name .. " has left the server with " .. killsValue .. " Kills and " .. deathsValue .. " Deaths", "All")
end

function LeaderboardModule.InitializeLeaderstats(player)
	Announcer.SayMessage(player.Name .. " has joined the server.", "All")

	for _, v in ipairs(scriptKills:GetChildren()) do
		killTable[v.Name] = v["Text Color"].Color3
	end

	local leaderstats = scriptLeaderstats:Clone()
	leaderstats.Parent = player

	streakTable[player.Name] = 0

	coroutine.wrap(function()
		updatePingAsync(player)
	end)()
end

return LeaderboardModule