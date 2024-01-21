local Announcer = {}
local Settings = require(script.Parent.Settings)

function Announcer.init(ChatService)
	if not Announcer.chat then
		local success, speaker = pcall(function()
			return ChatService:AddSpeaker(Settings.Announcer.Name)
		end)

		if success then
			Announcer.chat = speaker
			Announcer.chat:JoinChannel("All")
			Announcer.UpdateChatSettings(Settings.Announcer.Color, Settings.Announcer.Color, Settings.Announcer.Font)
		else
			warn("Failed to add Announcer chat speaker:", speaker)
		end
	else
		warn("Announcer chat speaker is already initialized.")
	end
end

function Announcer.UpdateChatSettings(nameColor, chatColor, font)
	if Announcer.chat then
		Announcer.chat:SetExtraData("NameColor", nameColor)
		Announcer.chat:SetExtraData("ChatColor", chatColor)
		Announcer.chat:SetExtraData("Font", font)
	end
end

function Announcer.SayMessage(message, channel)
	if Announcer.chat then
		Announcer.chat:SayMessage(message, channel)
	else
		warn("Announcer chat speaker not initialized. Call AnnouncerModule.init(ChatService) first.")
	end
end

function Announcer.AnnounceKillstreak(message, color)
	if Announcer.chat then
		local originalNameColor, originalChatColor = Announcer.GetChatSettings()
		Announcer.UpdateChatSettings(color, color, Settings.Announcer.Font)
		Announcer.SayMessage(message, "All")
		Announcer.UpdateChatSettings(originalNameColor, originalChatColor, Settings.Announcer.Font)
	else
		warn("Announcer chat speaker not initialized. Call AnnouncerModule.init(ChatService) first.")
	end
end

function Announcer.AnnounceTeamChat(player, state)
	local status = state and "disabled" or "enabled"
	Announcer.SayMessage(player .. " has " .. status .. " team-chat only.", "All")
end

function Announcer.SendError(message)
	local errorMessage = "[ERROR] " .. message

	if Announcer.chat then
		local originalNameColor, originalChatColor = Announcer.GetChatSettings()
		Announcer.UpdateChatSettings(Color3.new(1, 0, 0), Color3.new(1, 0, 0), Settings.Announcer.Font)
		Announcer.SayMessage(errorMessage, "All")
		Announcer.UpdateChatSettings(originalNameColor, originalChatColor, Settings.Announcer.Font)
	else
		warn("Announcer chat speaker not initialized. Call AnnouncerModule.init(ChatService) first.")
	end
end

function Announcer.GetChatSettings()
	if Announcer.chat then
		return Announcer.chat:GetExtraData("NameColor"), Announcer.chat:GetExtraData("ChatColor")
	end
end

function Announcer.PerformWithTemporarySettings(action, ...)
	local originalNameColor, originalChatColor = Announcer.GetChatSettings()
	action(...)
	Announcer.UpdateChatSettings(originalNameColor, originalChatColor, Settings.Announcer.Font)
end

return Announcer