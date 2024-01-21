local ToolGiverModule = {}
local services = script.Parent.Parent.Parent.services
local TeamServiceModule = require(services.TeamService)

function ToolGiverModule.GiveToolsToPlayer(player)
	local team = TeamServiceModule.GetTeamFromColor(player.TeamColor)
	if team then
		player.Backpack:ClearAllChildren()

		local tools = team:GetChildren()
		for _, tool in pairs(tools) do
			if tool:IsA("Tool") then
				tool:Clone().Parent = player.Backpack
			end
		end
	end
end

return ToolGiverModule
