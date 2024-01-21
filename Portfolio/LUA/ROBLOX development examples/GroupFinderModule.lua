local GroupService = game:GetService("GroupService")
local Players = game:GetService("Players")
local GroupFinderModule = {}

local IdCount = {} 
local IdIgnoreList = {4560126}

local function isInTable(tab, value)
	for i = 1, #tab do
		if tab[i] == value then return true end
	end
	return false
end

local function getMaxId()
	local Max = 0
	local MaxId
	for i, v in pairs(IdCount) do
		if v > Max then
			Max = v
			MaxId = i
		end
	end
	return MaxId
end

local function incrementId(Id, increment)
	if isInTable(IdIgnoreList, Id) then return end

	Id = tostring(Id)
	if IdCount[Id] == nil then 
		IdCount[Id] = increment
	else
		IdCount[Id] = IdCount[Id] + increment
	end 
end

local function getAllGroupIds()
	for _, v in pairs(Players:GetPlayers()) do
		if v then
			local PlayersGroups = GroupService:GetGroupsAsync(v.UserId)
			for i, j in pairs(PlayersGroups) do
				if j.IsPrimary then
					incrementId(j.Id, 2)
				else
					incrementId(j.Id, 1)
				end
			end
		end
	end

	local mostFrequentId = getMaxId()
	print("Most frequent group ID:", mostFrequentId)
	return mostFrequentId
end

function GroupFinderModule.GetRaidingGroup()
	local raidingGroupId = getAllGroupIds()
	local raidingGroupInfo = GroupService:GetGroupInfoAsync(raidingGroupId)
	print("Raiding group name:", raidingGroupInfo.Name)
	return raidingGroupInfo
end

return GroupFinderModule