local PrefloodModule = {}

local services = script.Parent.Parent.Parent.services
local utils = script.Parent.Parent.Parent.utils
local Players = game:GetService("Players")
local Announcer = require(utils.Announcer)
local HTTPServiceModule = require(services.HTTPService)
local TeamServiceModule = require(services.TeamService)
local Settings = require(utils.Settings)
local GroupFinderModule = require(script.GroupFinderModule)
local MinimumPlayers = Settings.minimumPlayers
local YourGroupId = Settings.groupId
local Placeid = game.PlaceId

function PrefloodModule.AlertIfRaidersDetected()
	if not PrefloodModule.PrefloodSent and #Players:GetPlayers() >= MinimumPlayers then
		local RaiderGroup = GroupFinderModule:GetRaidingGroup()

		local DiscordEmbed = {
			content = "@here",
			embeds = {
				{
					title = "Raiders Detected at " .. Settings.placeName,
					description = string.format(Settings.placeName .. " has been preflooded by **[%s](https://www.roblox.com/groups/%d)**, rally up here!\n \n"..Settings.placeURL.."\n\n__**Raiders:**__\n%s", RaiderGroup.Name, RaiderGroup.Id, TeamServiceModule.PlayersOnTeamString(Players)),
					thumbnail = {
						url = Settings.placeThumbnail
					},
					footer = {
						text = string.format(">> %d player(s) connected", #Players:GetPlayers()),
						icon_url = Settings.groupDecal
					},
					color = Settings.webhookColor
				}
			}
		}

		if RaiderGroup.Id ~= YourGroupId then
			local success, result = pcall(function()
				HTTPServiceModule.SendWebhook(DiscordEmbed, Settings.webhooks.preflood)
			end)
			if success then
				Announcer.SayMessage("Preflood successfully sent!")
				PrefloodModule.PrefloodSent = true
			else
				Announcer.SendError("Failed to send preflood: " ..tostring(result))
			end
		else
			Announcer.SendError("Skipping webhook request as practice raid is detected.")
		end
	end
end

return PrefloodModule
