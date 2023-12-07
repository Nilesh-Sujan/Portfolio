local Players = game:GetService("Players")
local ScriptService = game:GetService("ServerScriptService")
local ChatService = require(ScriptService:WaitForChild("ChatServiceRunner").ChatService)
local MarketPlaceService = game:GetService("MarketplaceService")
local HTTP = game:GetService("HttpService")
local DS = require(script.DatabaseService)
local tagStorage = DS:GetDatabase("Tags")
local tags = {}
local Chat = game:GetService("Chat")

local function ownsgamepass(userid,gamepassid)
    local owns,res = pcall(MarketPlaceService.UserOwnsGamePassAsync,MarketPlaceService,userid,gamepassid)
    if not owns then
        res = false
    end

	
    return res
end

function setSpeaker(Speaker)
	local plr = Speaker:GetPlayer()
	
	if not tags[plr.UserId] then return end
	--Set tags after every message
	Speaker.SaidMessage:Connect(function(chatMessage, channelName)
		local playerTags = tags[plr.UserId]
		if playerTags then
			Speaker:SetExtraData("Tags", {{TagText = playerTags.TagText, TagColor = playerTags.TagColor}})
		end
	end)
		
	--Set Tags at the first chat
	local playerTags = tags[plr.UserId]
	if playerTags then
		Speaker:SetExtraData("Tags", {{TagText = playerTags.TagText, TagColor = playerTags.TagColor}})
	end
end

function playerAdded(player)
	if ownsgamepass(player.UserId,9137940) or ownsgamepass(player.UserId, 6943384) or player.Name == "" or player.Name == "chocolatemanlol" then 
		local playerTagStore = tagStorage:GetAsync(player.UserId)
		local playerTags = {
			TagText = player.Name,
			TagColor = BrickColor.Black().Color
		}
		
		if playerTagStore then
			local tagInfo = HTTP:JSONDecode(playerTagStore)
			playerTags = {
				TagText = tagInfo.TagText,
				TagColor = Color3.new(tagInfo.R, tagInfo.G, tagInfo.B)
			}
		end
		
		tags[player.UserId] = playerTags
		
		local playerSpeaker = ChatService:GetSpeaker(player.Name)
		setSpeaker(playerSpeaker)
		
		player.Chatted:Connect(function(msg)
			
			if msg:sub(1,5)==":tag " then
				local filteredmsg = Chat:FilterStringAsync(msg:sub(6,10),player,player)
				playerTags.TagText = filteredmsg -- 5 char max
			elseif msg:sub(1,10)==':tagcolor ' then
				local UTagColor = msg:sub(11)
				UTagColor = UTagColor:gsub("^%l", string.upper)
				local splitTag = UTagColor:split(",")
				local isHex = (UTagColor:sub(1, 1) == "#")
				
				if(BrickColor[UTagColor]) then
					playerTags.TagColor = BrickColor[UTagColor]().Color
				elseif(BrickColor.new(UTagColor) and #splitTag < 3 and not isHex) then
					playerTags.TagColor = BrickColor.new(UTagColor).Color
				elseif isHex then
					UTagColor = UTagColor:sub(2)
					local r = "0x" .. UTagColor:sub(1, 2)
					local g = "0x" .. UTagColor:sub(3, 4)
					local b = "0x" .. UTagColor:sub(5, 6)
					playerTags.TagColor = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
				elseif Color3.fromRGB(tonumber(splitTag[1]),tonumber(splitTag[2]),tonumber(splitTag[3])) ~= nil then
					playerTags.TagColor = Color3.fromRGB(tonumber(splitTag[1]),tonumber(splitTag[2]),tonumber(splitTag[3]))
				end
			end			
		end)
	end
end

function playerLeaving(player)
	if not tags[player.UserId] then return end
	
	local playerTags = tags[player.UserId]
	local tagsToStore = {
		TagText = playerTags.TagText,
		R = playerTags.TagColor.r,
		G = playerTags.TagColor.g,
		B = playerTags.TagColor.b
	}
	
	tagStorage:PostAsync(player.UserId, tagsToStore)
end

game.Players.PlayerAdded:Connect(playerAdded)
game.Players.PlayerRemoving:Connect(playerLeaving)	