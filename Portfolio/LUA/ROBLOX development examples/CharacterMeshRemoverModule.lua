local CharacterMeshRemoverModule = {}

function CharacterMeshRemoverModule.RemoveCharacterMesh(player)
	player.CharacterAppearanceLoaded:Connect(function(char)
		for _, v in pairs(char:GetChildren()) do
			if v:IsA("CharacterMesh") then
				v:Destroy()
			end
		end
	end)
end

return CharacterMeshRemoverModule