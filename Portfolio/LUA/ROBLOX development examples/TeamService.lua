local TeamServiceModule = {}
local Teams = game:GetService("Teams")

function TeamServiceModule.PlayersOnTeamString(Team)
	local TeamString = ""
	for _, v in pairs(Team:GetPlayers()) do
		if v then
			TeamString = TeamString .. v.Name .. "\n"
		end
	end
	return TeamString
end

function TeamServiceModule.GetTeamFromColor(color)
	for _, team in pairs(Teams:GetTeams()) do
		if team.TeamColor == color then
			return team
		end
	end
	return nil
end

return TeamServiceModule
