warn("Initializing Athenist Engine v1.0 [SERVER] ...")
warn("By: lightwxve & chocolatemanlol")

------------------------------------------------------------------------------------------
local managers = script.managers

local function requireModule(module)
	local success, moduleInstance = pcall(require, module)
	if success then
		warn("[" .. os.date("%Y-%m-%d %H:%M:%S") .. "] Loading: " .. module.Name .. " ...")
		return moduleInstance
	else
		warn("Failed to load: " .. module.Name)
		warn("Error message: " .. tostring(moduleInstance))
		return nil
	end
end

local function initializeManager(managerScript)
	if managerScript:IsA("ModuleScript") then
		local managerInstance = requireModule(managerScript)
		if managerInstance then
			local initFunction = managerInstance.init
			if type(initFunction) == "function" then
				local success, initError = pcall(initFunction)
				if success then
					warn(managerScript.Name .. " manager has been initialized")
				else
					warn(managerScript.Name .. " manager failed to initialize")
					warn("Initialization error: " .. tostring(initError))
				end
			else
				warn(managerScript.Name .. " manager does not have an init function")
			end
		end
	end
end

local function initializeManagers(managers)
	local playerManagerScript = managers:FindFirstChild("PlayerManager")
	
	for _, managerScript in pairs(managers:GetChildren()) do
		if managerScript ~= playerManagerScript then
			initializeManager(managerScript)
		end
	end
	
	initializeManager(playerManagerScript)

end

initializeManagers(managers)
------------------------------------------------------------------------------------------

warn("Athenist Engine v1.0 initialized successfully on server")