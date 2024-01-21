local ChatManager = {}

local ServerScriptService = game:GetService("ServerScriptService")
local ChatService = require(ServerScriptService:WaitForChild("ChatServiceRunner"):WaitForChild("ChatService"))
local Announcer = require(script.Parent.Parent.utils.Announcer)
local Settings = require(script.Parent.Parent.utils.Settings)
local Players = game:GetService("Players")

local isMuted = false 

function ChatManager.init()
	Announcer.init(ChatService)
end

function ChatManager.ToggleMute(Admin)
	Announcer.AnnounceTeamChat(Admin.Name, isMuted)
	isMuted = not isMuted
	
	local Global = ChatService:GetChannel("All")

	for _, v in pairs(Players:GetPlayers()) do
		if v then
			local action = isMuted and Global.MuteSpeaker or Global.UnmuteSpeaker
			action(Global, v.Name)
		end
	end

	Global.SpeakerJoined:Connect(function(speakerName)
		local action = isMuted and Global.MuteSpeaker or Global.UnmuteSpeaker
		action(Global, speakerName)
	end)
	
end

local function handleSpeaker(speakerName)
	local speaker = ChatService:GetSpeaker(speakerName)
	local player = speaker:GetPlayer()

	if player then
		local extraData = Settings.ChatTags[player.UserId]
		if extraData then
			for key, value in pairs(extraData) do
				speaker:SetExtraData(key, value)
			end
		end
	end
end

ChatService.SpeakerAdded:Connect(handleSpeaker)
for _, speakerName in pairs(ChatService:GetSpeakerList()) do
	handleSpeaker(speakerName)
end

return ChatManager