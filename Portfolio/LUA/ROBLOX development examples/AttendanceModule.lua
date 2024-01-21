local AttendanceModule = {}

local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

local Utils = script.Parent.Parent.Parent.utils
local Settings = require(Utils.Settings)
local Announcer = require(Utils.Announcer)
local HTTPServiceModule = require(script.Parent.Parent.Parent.services.HTTPService)

function AttendanceModule.groupMembers()
	local groupMembersStr = ''
	for _, player in ipairs(Players:GetPlayers()) do
		if player:IsInGroup(Settings.groupId) then
			groupMembersStr = groupMembersStr .. player.Name .. ', '
		end
	end
	return groupMembersStr:sub(1, -3)
end

function AttendanceModule.spairs(t, order)
	local keys = {}
	for key in pairs(t) do keys[#keys + 1] = key end

	if order then
		table.sort(keys, function(a, b) return order(t, a, b) end)
	else
		table.sort(keys)
	end

	local index = 0
	return function()
		index = index + 1
		if keys[index] then
			return keys[index], t[keys[index]]
		end
	end
end

function AttendanceModule.processTeam(team, teamName)
	local playerStats = {}
	local sortedString = ''

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Team == team then
			playerStats[player.Name] = player.leaderstats.Kills.Value
		end
	end

	for playerName, kills in AttendanceModule.spairs(playerStats, function(tbl, a, b) return tbl[a] > tbl[b] end) do
		sortedString = sortedString .. '`' .. playerName .. ' | ' .. kills .. '-' .. Players[playerName].leaderstats.Deaths.Value .. '`\n'
	end

	if sortedString == '' then
		return string.format('**No players on the %s team**', teamName:gsub("%[%d+%]", ""))
	end

	return sortedString:sub(1, -2)
end

function AttendanceModule.discord()
	--Announcer.SayMessage("Logging attendance...","All")
	local embedFields = {}

	for _, team in pairs(Teams:GetTeams()) do
		if team:IsA("Team") then
			table.insert(embedFields, {
				name = team.Name,
				value = AttendanceModule.processTeam(team, team.Name),
				inline = false
			})
		end
	end

	table.insert(embedFields, {
		name = 'Group Members',
		value = AttendanceModule.groupMembers(),
		inline = false
	})

	local embeddedMessage = {
		content = '@here',
		embeds = {
			{	title = 'Attendance Report for: '..Settings.placeName,
				author = {
					name = Settings.placeName,
					url = Settings.placeURL,
					icon_url = Settings.placeIcon
				},
				color = Settings.webhookColor,
				description = Settings.placeURL,
				thumbnail = {
					url = Settings.placeThumbnail,
				},
				timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
				fields = embedFields,
				footer = {
					text = "Attendance Logger",
					icon_url = Settings.groupDecal
				}
			}
		}
	}

	local success, result = pcall(function()
		HTTPServiceModule.SendWebhook(embeddedMessage, Settings.webhooks.attendancelogger)
	end)

	if not success then
		Announcer.SayMessage("Attendance successfully logged!","All")
	else
		Announcer.SendError("Failed to log attendance: " ..tostring(result))
	end
end

return AttendanceModule