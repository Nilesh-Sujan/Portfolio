--| Stables
--| Manages the mechanics for horses, stables, and carts

--[[ DOCUMENTATION
 
	- All Horses and carts that spawn in game will be directly controlled by the behavior defined below
	
]]

-----------------------------------------------------------------------------------------------------------

--| Services
local CS = game:GetService("CollectionService")
local Physics = game:GetService("PhysicsService")
local Chat = game:GetService("Chat")
local Core = require(game.ServerScriptService.CoreServer.CoreServerModule)
local HorseLibrary = require(game.ReplicatedStorage.Modules.HorseStats)
local Library = require(game.ReplicatedStorage.Modules.Library)
local Storage = require(game.ServerStorage.Modules.DataStorage)

--| Variables
local Events = game.ReplicatedStorage.Events
local Event = Events:FindFirstChild("Horse") 
local H = {}
local Horse = {}
local Cart = {}
local Stable = {}
Cart.__index = Cart
Horse.__index = Horse
Stable.__index = Stable
local Animations = game.ReplicatedStorage.Animations.Horse
local HorseModels = game.ReplicatedStorage.Models.Horses
local CartModels = game.ReplicatedStorage.Models.Spawnable
local DEBUG_MODE = false
local DespawnTime = 60
H.List = {}
H.Carts = {}
H.Stables = {}
H.Type = {}


local function Print(Message) 
	if not DEBUG_MODE then return end
	print("[Stables] ", Message)
end

local function SetHorsePhysics(Model)
	for _, Part in pairs(Model:GetDescendants()) do
		if Part.ClassName == "Part" or Part.ClassName == "MeshPart" or Part.ClassName == "UnionOperation" then
			Physics:SetPartCollisionGroup(Part, "Horses")
		end
	end
end

-----------------------------------------------------------------------------------------------------------
Print("Loading Cart Methods.")
-----------------------------------------------------------------------------------------------------------
H.Type["Medical Cart"] = function(Model)
	local Cargo = {{}, {}}
	local Cart = Model
	local Max = 4
	local DB 
	local Model = game.ReplicatedStorage.Models.CorpseModel

	local function LocateCargo(Object)
		if table.find(Cargo[1], Object) then return true end
		if table.find(Cargo[2], Object) then return true end
		return
	end

	local function AddBody(Stack, StackAttachment, OldBody)
		if OldBody:FindFirstChild("CarryBodyWeld") then
			OldBody["CarryBodyWeld"]:Destroy()
		end
		game.Debris:AddItem(OldBody, 1)
		local Corpse = Model:Clone()
		local Weld = Instance.new("Weld")
		for _, Part in pairs(Corpse:GetDescendants()) do
			if Part.ClassName == "Part" or Part.ClassName == "UnionOperation" or Part.ClassName == "MeshPart" then
				Part.CanCollide = false
				Part.Anchored = false
				Part.Massless = true
			end
		end
		local Offset = CFrame.new(StackAttachment.WorldPosition) 
		local CD = Instance.new("ClickDetector")
		CD.Parent = Corpse
		Corpse.Parent = Cart.Cart
		Corpse.Name = OldBody.Name
		Weld.Parent = Corpse.PrimaryPart
		Weld.Part0 = Cart.Cart.Base
		Weld.Part1 = Corpse.PrimaryPart
		Weld.C0 = Cart.Cart.Base.CFrame:ToObjectSpace(Offset) * CFrame.new(0, (Corpse.PrimaryPart.Size.Y * .65) * #Stack, 0)  * CFrame.fromEulerAnglesXYZ(0, math.rad(-25,25), 0)

		CD.MouseHoverEnter:Connect(function(p)
			Events.Core:FireClient(p, "HoverGui", Corpse.Name, true)
		end)
		CD.MouseHoverLeave:Connect(function(p)
			Events.Core:FireClient(p, "HoverGui", p.Name, false)
		end)
	end

	Cart.Cart.DETECT.Touched:Connect(function(Part)
		local Model = Part.Parent
		if Model and Model.ClassName == 'Model' and CS:HasTag(Model.PrimaryPart, "Corpse") and Part.Parent:FindFirstChild("Humanoid") and not DB and not LocateCargo(Part.Parent) then
			if Part.Parent.Torso:FindFirstChild("CarryBodyWeld") then
				local Character = Part.Parent.Torso["CarryBodyWeld"].Part1.Parent
				local Player = game.Players:GetPlayerFromCharacter(Character)
				local RecoveryBonus = 5
				Player.GearEnabled.Value = true
				Events.Core:FireClient(Player, "Alert", "You have been paid " .. RecoveryBonus .. " gold for recovering a fallen comrade.", "Bonus")
				local UserData = Storage.Session[Player.Name]["UserData"]
				Core.DataManagementFunctions:SetValue(Player, "UserData", "Gold", UserData.Gold + RecoveryBonus)				
				Part.Parent.Torso["CarryBodyWeld"]:Destroy()
				for _, Track in pairs(Character.Humanoid:GetPlayingAnimationTracks()) do
					Track:Stop()
				end
			end
			DB = true
			if #Cargo[1] < Max then 
				table.insert(Cargo[1], Part.Parent)
				AddBody(Cargo[1], Cart.Cart.Base.Stack1, Part.Parent)
				wait(1)
				DB = false
			elseif #Cargo[2] < Max then
				table.insert(Cargo[2], Part.Parent)
				AddBody(Cargo[2], Cart.Cart.Base.Stack2, Part.Parent)
				wait(1)
				DB = false
			else
				print("[Stables] Medical Cart is full.")
			end
		end
	end)	
end

H.Type["Merchant Cart"] = function(Model)
	CS:AddTag(Model, "Construction Supplies")
end

function Cart:Connect(Function)
	table.insert(self.Conn, #self.Conn + 1, Function)
end

function Cart:Died()
	if self.Cart:FindFirstChildOfClass("Humanoid") then
		self.Cart.Humanoid.Health = 0
		self.Cart:BreakJoints()
	end
	game.Debris:AddItem(self.Cart, 3)
	wait()
	for Slot, Meta in pairs(H.Carts) do
		if Meta.Cart == self.Cart then
			table.remove(H.Carts, Slot)
		end
	end
	for _, Conn in pairs(self.Conn) do
		Conn:Disconnect()
	end
	self = nil
end

function Cart:Animate(Name)
	for TrackName, Track in pairs(self.Anim) do
		if Name ~= TrackName then 
			Track:Stop()
		else
			Track:Play()
		end
	end
	if Name == "Idle" then self.Sound:Stop() else self.Sound:Play() end
end

function Cart:SetNetworkOwner(User)
	for _, Part in pairs(self.Cart:GetDescendants()) do
		if Part:IsA("BasePart") then
			Part:SetNetworkOwner(User)
		end
	end	
end

function Cart:UpdateRider(Player, IsRiding, Seat)
	if not Player then return end
	local Success, err = pcall(function()
		if IsRiding then
			for _, Track in pairs(Player.Character.Humanoid:GetPlayingAnimationTracks()) do
				Track:Stop()
			end
			Player.Mounted.Value = true
			if Player.Character:FindFirstChild(script.HorseInput.Name) then return end
			local Controller = script.HorseInput:Clone()
			if Seat.Name == "Passenger" then Controller.IsPassenger.Value = true end
			Controller.Parent = Player.Character
			Controller.Horse.Value = self.Cart
			Controller.Type.Value = self.Breed
			Player.Mounted.Value = true	
			Controller.Disabled = false		
			table.insert(self.Passengers, Player)
			local RiderTrack
			if Seat.Name == "Seat" then
				self:SetNetworkOwner(Player)
				self.Player = Player
				RiderTrack = Player.Character.Humanoid:LoadAnimation(Animations.CartDriver)
				print(Player.Name .. " is the new cart driver!")
			elseif Seat.Name == "Passenger" then
				table.insert(self.Passengers, Player)
				RiderTrack = Player.Character.Humanoid:LoadAnimation(Animations.CartPassenger)
			end
			RiderTrack.Name = "CartAnimation"
			RiderTrack:Play()
		else
			--Print(Player.Name .. " has dismounted " .. self.Cart.Name .. ".")
			Player.Mounted.Value = false
			if Seat.Name == "Seat" then
				self.Player = nil
			elseif Seat.Name == "Passenger" then
				for Slot, Passenger in pairs(self.Passengers) do
					if Passenger == Player then
						table.remove(self.Passengers, Slot)
					end
				end				
			end

			for Slot, Rider in pairs(self.Passengers) do
				if Rider == Player then table.remove(self.Passengers, Slot) end
			end

			for _, Track in pairs(Player.Character.Humanoid:GetPlayingAnimationTracks()) do
				if Track.Name == "CartAnimation" then
					Track:Stop()
					Track:Destroy()
				end
			end
		end
	end)
	if not Success then Print(err) end
end


function Cart:Summon()
	if not CartModels:FindFirstChild(self.Breed) or not HorseLibrary[self.Breed] then 
		Print("The " .. (self.Breed) .. " Cart Type does not exist, or isn't configured in the Stables library.") 
		return end
	--Part:SetNetworkOwner(self.Player)
	self.Cart = CartModels:FindFirstChild(self.Breed):Clone()
	self.Stats = HorseLibrary[self.Cart.Name]

	for Name, Func in pairs(H.Type) do
		if self.Cart.Name == Name then
			Func(self.Cart)
		end
	end

	if self.Stats.Type == "Stationary Cart" then
		self.Cart.Parent = game.Workspace.Horses
		self.Cart:MoveTo(self.SpawnPosition + Vector3.new(0, 7, 0) or self.Player.Character.PrimaryPart.Position + Vector3.new(math.random(-20, 20), 0, (math.random(-20, 20))))
		CS:AddTag(self.Cart, "Horse")
		return	
	end

	self.Sound = game.ReplicatedStorage.Sounds.Horse:Clone()
	self.Sound.Parent = self.Cart:FindFirstChild("Head")
	self.Sound.PlaybackSpeed = .8
	self.HatchOpen = false
	self.BodyVelo = Instance.new("BodyVelocity")
	self.Gyro = Instance.new("BodyGyro")
	self.BodyVelo.Velocity = Vector3.new()
	self.BodyVelo.MaxForce = Vector3.new(1,0,1) * 50000
	self.Gyro.MaxTorque = Vector3.new(1, 1, 1) * 50000000000
	self.Gyro.P = 2000
	self.Gyro.D = 250
	self.Gyro.Parent, self.BodyVelo.Parent = self.Cart.PrimaryPart, self.Cart.PrimaryPart
	self.Cart.PrimaryPart.Anchored = true
	self.Cart.Parent = game.Workspace.Horses
	self.Cart:MoveTo(self.SpawnPosition + Vector3.new(0, 2, 0) or self.Player.Character.PrimaryPart.Position + Vector3.new(math.random(-20, 20), 0, (math.random(-20, 20))))
	CS:AddTag(self.Cart, "Horse")
	SetHorsePhysics(self.Cart)
	self.Cart.PrimaryPart.Anchored = false
	self.Anim = {
		Idle = self.Cart.Humanoid:LoadAnimation(Animations.Idle);
		Walk = self.Cart.Humanoid:LoadAnimation(Animations.Walk);
		Rear = self.Cart.Humanoid:LoadAnimation(Animations.Rear);
		Gallop = self.Cart.Humanoid:LoadAnimation(Animations.Gallop);
		Sprint = self.Cart.Humanoid:LoadAnimation(Animations.Sprint);
		JumpAndFall = self.Cart.Humanoid:LoadAnimation(Animations.JumpAndFall);
		Jump = self.Cart.Humanoid:LoadAnimation(Animations.Jump);
		Fall = self.Cart.Humanoid:LoadAnimation(Animations.Fall);
	}

	self.Anim.Idle.Name = "Idle"
	self.Anim.Walk.Name = "Walk"
	self.Anim.Rear.Name = "Rear"
	self.Anim.Gallop.Name = "Gallop"
	self.Anim.Sprint.Name = "Sprint"
	self.Anim.Jump.Name = "Jump"
	self.Anim.JumpAndFall.Name = "JumpAndFall"
	-- self.Horse.Seat.Disabled = true
	-- self.Horse.Passenger.Disabled = true
	self.Anim.Fall.Name = "Fall"
	self.Anim.Idle:Play()

	for _, Seat in pairs(self.Cart:GetDescendants()) do
		if (Seat.ClassName == "VehicleSeat" or Seat.ClassName == "Seat") then
			Seat.Disabled = false
			--CS:AddTag(Seat, "Interactive")
			--CS:AddTag(Seat, "HorseSeat")
			--CS:AddTag(Seat, "Cart")
			self:Connect(Seat.ChildAdded:Connect(function(Inst)
				if Inst.ClassName == "Weld" and Inst.Part1 then
					local User = game.Players:GetPlayerFromCharacter(Inst.Part1.Parent)
					if CS:HasTag(Inst.Part1.Parent, "Horse") or not User then Inst:Destroy() return end
					self:UpdateRider(User, true, Seat)
					if Seat.Name == "Seat" then 
						self.TimesMounted = self.TimesMounted + 1 
					end
				end
			end))
			self:Connect(Seat.ChildRemoved:Connect(function(Inst)
				if Inst.ClassName == "Weld" and Inst.Part1 then
					local User = game.Players:GetPlayerFromCharacter(Inst.Part1.Parent)
					self:UpdateRider(User, false, Seat)
				end
			end))
		elseif Seat.ClassName == "Attachment" and Seat.Name == "Hatch" then
			CS:AddTag(Seat, "Interactive")
			CS:AddTag(Seat, "Cart")
		end
	end


	--[[self:Connect(self.Horse.Seat.ChildAdded:Connect(function(Inst)
		if Inst.ClassName == "Weld" then
			local User = game.Players:GetPlayerFromCharacter(Inst.Part1.Parent)
			if User ~= self.Player then Inst:Destroy() end
			if not User.Character:FindFirstChild(script.HorseInput.Name) then					
				self:SetController(User)
			end
		end
	end))
	]]
	if self.Cart:FindFirstChildOfClass("Humanoid") then
		self:Connect(self.Cart.Humanoid.Died:Connect(function()
			self:Died()
		end))
	end

	pcall(function()
		for _,State in pairs(Enum.HumanoidStateType:GetEnumItems()) do
			if State and State ~= Enum.HumanoidStateType.None and State ~= Enum.HumanoidStateType.Running and State ~= Enum.HumanoidStateType.Dead and State ~= Enum.HumanoidStateType.None then
				self.Cart.Humanoid:SetStateEnabled(State, false)
			end
		end
		self.Cart.Humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end)
end

function Cart:IsPassenger(Player)

end

function Cart:ToggleHatch()
	if not self.Cart.Cart:FindFirstChild("Gate") then return end
	self.HatchOpen = not self.HatchOpen 
	if not self.HatchConn then
		self.HatchConn = true
		self:Connect(self.Cart.Cart.Gate.Motor:GetPropertyChangedSignal("CurrentAngle"):Connect(function()
			if self.Cart.Cart.Gate.Motor.CurrentAngle == 210 and self.HatchOpen then
				if not self.Cart.Cart.Gate.CanCollide then self.Cart.Cart.Gate.CanCollide = true end
			else
				if self.Cart.Cart.Gate.CanCollide then self.Cart.Cart.Gate.CanCollide = false end	
			end
		end))
	end
	if self.HatchOpen then
		self.Cart.Cart.Gate.Motor.TargetAngle = 195
	else
		self.Cart.Cart.Gate.Motor.TargetAngle = 90
	end
end

function Cart:Mount(Player, Seat)
	if Seat:FindFirstChildOfClass("Weld") then return end
	local Weld = Instance.new("Weld")
	Weld.Name = "Passenger"
	Weld.Parent = Seat
	Weld.Part0 = Seat
	Weld.Part1 = Player.Character.HumanoidRootPart
	Player.Mounted.Value = true
	Weld.C0 = CFrame.new(0, 0, 0.01)
	self:UpdateRider(Player, true, Seat)
end

function Cart:Unmount(Player)
	for _, Seat in pairs(self.Cart:GetDescendants()) do
		if (Seat.ClassName == "VehicleSeat" or Seat.ClassName == "Seat") and Seat:FindFirstChildOfClass("Weld") then
			local Weld = Seat:FindFirstChildOfClass("Weld")
			if Weld.Part1:IsDescendantOf(Player.Character) then
				Weld:Destroy()
				Player.Mounted.Value = false
				self:UpdateRider(Player, false, Seat)
				if Seat.Name == "Seat" then self:Animate("Idle") end
			end
		end
	end
end

function Cart:PassEvent(Player, Args)
	if Args[1] == "Mount" then	
		self:Mount(Player, Args[2])
	elseif Args[1] == "Unmount" then
		self:Unmount(Player, Args[2])
	elseif Args[1] == "PlayAnimation" then
		self:Animate(Args[2])
	elseif Args[1] == "ToggleHatch" then
		self:ToggleHatch()
	end
end

-----------------------------------------------------------------------------------------------------------
Print("Loading Horse Methods.")
-----------------------------------------------------------------------------------------------------------
function Horse:Connect(Function)
	table.insert(self.Conn, #self.Conn + 1, Function)
end

function Horse:Died()
	pcall(function()
		self.Horse.Humanoid.Health = 0
		for _, Weld in pairs(self.Horse:GetDescendants()) do
			if Weld.ClassName == "Weld" and (Weld.Parent.ClassName == "Seat" or Weld.Parent.ClassName == "VehicleSeat") then
				Weld:Destroy()
			end
		end
		self.Horse.PrimaryPart.Anchored = true
		local Sound = game.ReplicatedStorage.Sounds["Horse Neigh"]:Clone()
		Sound.Parent = self.Horse.PrimaryPart
		Sound.PlaybackSpeed = math.random(100, 125) / 100
		self.Horse:SetPrimaryPartCFrame(self.Horse.PrimaryPart.CFrame * CFrame.new(0, -2, 0) * CFrame.fromEulerAnglesXYZ(0, 0, 90))
		--self.Horse:BreakJoints()
		Sound:Play()
		for Slot, Meta in pairs(H.List) do
			if Meta.Player == self.Player then
				H.List[Slot] = nil
				--Print("Removing Horse Slot #" .. Slot .. " Containing " .. self.Player.Name .. "'s Horse Data. Remaining Horses: " .. #H.List)
			end
		end
		game.Debris:AddItem(self.Horse, 3)
		if game.ReplicatedStorage.ServerInfo.PDEnabled.Value then
			local v = self.Player:FindFirstChild("DeadHorse") or Instance.new("BoolValue")
			v.Name = "DeadHorse"
			v.Parent = self.Player
		end
		self.Player.Requests.serverCore:FireClient(self.Player, "Notify", "Your horse has fallen.", BrickColor.new("Really red"))
		self.Player.Mounted.Value = false
		for _, Obj in pairs(self.Player:GetDescendants()) do
			if CS:HasTag(Obj, "HorseSound") then Obj:Destroy() end
		end
		for _, Conn in pairs(self.Conn) do
			Conn:Disconnect()
		end
	end)
	self = nil
end

function Horse:ToggleDustTrails(Bool)
	if self.Horse then
		for _, Emitter in pairs(self.Horse:GetDescendants()) do
			if Emitter.Parent.Name == "Dust" then
				Emitter.Enabled = Bool
			end
		end
	end
end

function Horse:Animate(Name)
	if self.Anim then
		for TrackName, Track in pairs(self.Anim) do
			if Name ~= TrackName then 
				Track:Stop()
			else
				Track:Play()
			end
		end
		if Name == "Idle" then 
			if self.Sound then self.Sound:Stop() end
			self:ToggleDustTrails(false)
		else 
			if self.Sound then self.Sound:Play() end
			self:ToggleDustTrails(true)
		end
	end
end

function Horse:PlaySound(Name, Parent)
	for _, SoundObj in pairs(game.ReplicatedStorage.Sounds:GetChildren()) do
		if SoundObj.Name == Name then
			local S = SoundObj:Clone()
			S.Parent = Parent
			S:Play()
			CS:AddTag(S, "HorseSound")
			delay(S.TimeLength + 0.5, function()
				S:Destroy()
			end)			
			break
		end
	end
end

function Horse:UpdateRider(Player, IsRiding, Seat)
	if not Player then return end
	local Success, err = pcall(function()
		if IsRiding then
			--Print(Player.Name .. " mounted " .. self.Horse.Name .. ".")
			Player.Mounted.Value = true
			if Player.Character:FindFirstChild(script.HorseInput.Name) then Player.Character[script.HorseInput.Name]:Destroy() end
			local Controller = script.HorseInput:Clone()
			Controller.Disabled = false
			Controller.Parent = Player.Character
			Controller.Horse.Value = self.Horse
			if Seat.Name == "Passenger" then Controller.IsPassenger.Value = true end
			Controller.Type.Value = self.Breed
			Controller.Disabled = false
			Player.Mounted.Value = true	

			for _, Track in pairs(Player.Character.Humanoid:GetPlayingAnimationTracks()) do
				Track:Stop()
			end
			if self.Stats.Type ~= "Cart" then
				local RiderTrack = Player.Character.Humanoid:LoadAnimation(Animations.Rider)
				RiderTrack.Name = "Rider"
				RiderTrack:Play()
			end
		else
			--Print(Player.Name .. " dismounted " .. self.Horse.Name .. ".")
			Player.Mounted.Value = false
			for _, Track in pairs(Player.Character.Humanoid:GetPlayingAnimationTracks()) do
				if Track.Name == "Rider" then
					Track:Stop()
					Track:Destroy()
				end
			end
		end
	end)
	if not Success then Print(err) end
end

function Horse:SetController(Player)
end

function Horse:Mount(Player, Seat)
	if Seat:FindFirstChildOfClass("Weld") then return end -- or (Seat.Name == "Seat" and not Player == self.Player) 
	local Weld = Instance.new("Weld")
	Weld.Name = "Passenger"
	Weld.Parent = Seat
	Weld.Part0 = Seat
	Weld.Part1 = Player.Character.HumanoidRootPart
	Weld.C0 = CFrame.new(0, 0, -0.375)
	self:UpdateRider(Player, true, Seat)
end

function Horse:Unmount(Player)
	if self.Horse then
		for _, Seat in pairs(self.Horse:GetDescendants()) do
			if (Seat.ClassName == "VehicleSeat" or Seat.ClassName == "Seat") and Seat:FindFirstChildOfClass("Weld") then
				local Weld = Seat:FindFirstChildOfClass("Weld")
				if Weld.Part1:IsDescendantOf(Player.Character) then
					Weld:Destroy()
					if Seat.Name == "Seat" then self:Animate("Idle") end
				end
			end
		end
	end
end

function Horse:Summon(SummonPosition)
	spawn(function()
		local Whistle = game.ReplicatedStorage.Sounds.Whistle:Clone()
		Whistle.Parent = self.Player.Character.PrimaryPart
		Whistle.Stopped:Connect(function() Whistle:Destroy() end)
		Whistle:Play()
	end)

	if self.Horse and self.Horse:IsDescendantOf(game.Workspace) then
		if self.Called or self.Mounted then return end
		self.Called = true
		self.Horse.Humanoid.HipHeight = 2
		self.Horse.Humanoid.WalkSpeed = self.Stats.MaxSpeed / 2
		self.Sound = game.ReplicatedStorage.Sounds.Horse:Clone()
		self.Sound.Parent = self.Horse.Head
		self.Sound.PlaybackSpeed = 1
		self.Sound:Play()
		spawn(function()
			if self.Player:DistanceFromCharacter(self.Horse.PrimaryPart.Position) >= 2000 then
				self.Horse:MoveTo(self.Player.Character.PrimaryPart.Position + Vector3.new(math.random(-20, 20), 0, (math.random(-20, 20))))
				return
			end
			self:Animate("Sprint")
			local dir = (self.Player.Character.Head.Position - self.Horse.PrimaryPart.Position).unit * Vector3.new(1,0,1)
			self.BodyVelo.Velocity = dir * (20)
			self.Gyro.CFrame = CFrame.new(self.Horse.PrimaryPart.Position, self.Horse.PrimaryPart.Position + (dir * 10000))
			repeat wait(.365) 
				dir = (self.Player.Character.Head.Position - self.Horse.PrimaryPart.Position).unit * Vector3.new(1,0,1) 
				self.BodyVelo.Velocity = dir * (20)
				self.Gyro.CFrame = CFrame.new(self.Horse.PrimaryPart.Position, self.Horse.PrimaryPart.Position + (dir * 10000)) 
			until 
			self.Player:DistanceFromCharacter(self.Horse.PrimaryPart.Position) <= 11
			self:Animate("Idle")
			--Horse.PrimaryPart.CFrame = CFrame.new(Horse.PrimaryPart.Position, Vector3.new(Player.Character.Head.Position.X, Horse.PrimaryPart.Position.Y, Player.Character.Head.Position.Z))
			self.Sound:Stop()
			self.BodyVelo.Velocity = Vector3.new()
			self.Called = false
			self.Anim.Sprint:Stop()
			self.Anim.Walk:Stop()
			self.Horse.Humanoid.WalkSpeed = self.Stats.WalkSpeed
		end)		
		return
	end

	if not HorseModels:FindFirstChild(self.Breed) or not HorseLibrary[self.Breed] then 
		Print("The " .. (self.Breed) .. " Horse Breed does not exist, or isn't configured in the horse library.") 
		return end

	self.Horse = HorseModels:FindFirstChild(self.Breed):Clone()
	self.Stats = HorseLibrary[self.Horse.Name]
	self.UserData = Core.DataManagementFunctions:Get(self.Player, "UserData")
	self.UserInventory = Core.DataManagementFunctions:Get(self.Player, "Inventory")

	self.Sound = game.ReplicatedStorage.Sounds.Horse:Clone()
	self.Sound.Parent = self.Horse:FindFirstChild("Head")
	self.Sound.PlaybackSpeed = .8
	self.BodyVelo = Instance.new("BodyVelocity")
	self.Gyro = Instance.new("BodyGyro")
	self.Owner = Instance.new("StringValue")
	self.Owner.Name = "Owner"
	self.Owner.Value = self.Player.Name
	self.Owner.Parent = self.Horse
	self.BodyVelo.Velocity = Vector3.new()
	self.BodyVelo.MaxForce = Vector3.new(1,0,1) * 500000
	self.Gyro.MaxTorque = Vector3.new(1, 1, 1) * 50000000000
	self.Gyro.P = 2000
	self.Gyro.D = 250
	self.Horse.Humanoid.Health = self.Stats.Health or 100
	self.Horse.Humanoid.MaxHealth = self.Stats.Health or 100
	self.Gyro.Parent, self.BodyVelo.Parent = self.Horse.PrimaryPart, self.Horse.PrimaryPart
	self.Horse.Name = self.UserData.Horse.HorseName or self.Player.Name .. "'s Horse"
	self.Horse.Parent = game.Workspace.Horses
	CS:AddTag(self.Horse, "Horse")
	SetHorsePhysics(self.Horse)

	for _, Seat in pairs(self.Horse:GetChildren()) do
		if Seat.ClassName == "VehicleSeat" then
			Seat.Disabled = true
			CS:AddTag(Seat, "Interactive")
			CS:AddTag(Seat, "HorseSeat")
			self:Connect(Seat.ChildAdded:Connect(function(Inst)
				if Inst.ClassName == "Weld" then
					repeat wait() until Inst.Part1
					local User = game.Players:GetPlayerFromCharacter(Inst.Part1.Parent)
					if self.Stats.Type == "Standard" then
						self:UpdateRider(User, true, Seat)
						Inst.C0 = Inst.C0 * CFrame.new(0, 0.985, 0)
					end
					self.TimesMounted = self.TimesMounted + 1 
				end
			end))
			self:Connect(Seat.ChildRemoved:Connect(function(Inst)
				if Inst.ClassName == "Weld" then
					if CS:HasTag(Inst.Part1.Parent, "Horse") then return end
					local User = game.Players:GetPlayerFromCharacter(Inst.Part1.Parent)
					self:UpdateRider(User, false, Seat)
				end
			end))
		end
	end

	if SummonPosition then
		Print("Summoning " .. self.Player.Name .. "'s Horse via Stable.")
		local Part = SummonPosition.Parent
		self.Horse:SetPrimaryPartCFrame(CFrame.new(Part.StableShop.WorldPosition, Part.SpawnLocation.WorldPosition))
		self:Mount(self.Player, self.Horse.Seat)
	else
		self.Horse:MoveTo(self.Player.Character.PrimaryPart.Position + Vector3.new(math.random(-20, 20), 0, (math.random(-20, 20))))
	end

	self.Anim = {
		Idle = self.Horse.Humanoid:LoadAnimation(Animations.Idle);
		Walk = self.Horse.Humanoid:LoadAnimation(Animations.Walk);
		Rear = self.Horse.Humanoid:LoadAnimation(Animations.Rear);
		Gallop = self.Horse.Humanoid:LoadAnimation(Animations.Gallop);
		Sprint = self.Horse.Humanoid:LoadAnimation(Animations.Sprint);
		JumpAndFall = self.Horse.Humanoid:LoadAnimation(Animations.JumpAndFall);
		Jump = self.Horse.Humanoid:LoadAnimation(Animations.Jump);
		Fall = self.Horse.Humanoid:LoadAnimation(Animations.Fall);
	}

	self.Anim.Idle.Name = "Idle"
	self.Anim.Walk.Name = "Walk"
	self.Anim.Rear.Name = "Rear"
	self.Anim.Gallop.Name = "Gallop"
	self.Anim.Sprint.Name = "Sprint"
	self.Anim.Jump.Name = "Jump"
	self.Anim.JumpAndFall.Name = "JumpAndFall"
	-- self.Horse.Seat.Disabled = true
	-- self.Horse.Passenger.Disabled = true
	self.Anim.Fall.Name = "Fall"
	self.Anim.Idle:Play()


	--[[self:Connect(self.Horse.Seat.ChildAdded:Connect(function(Inst)
		if Inst.ClassName == "Weld" then
			local User = game.Players:GetPlayerFromCharacter(Inst.Part1.Parent)
			if User ~= self.Player then Inst:Destroy() end
			if not User.Character:FindFirstChild(script.HorseInput.Name) then					
				self:SetController(User)
			end
		end
	end))
	]]
	self:Connect(self.Horse.Humanoid.Died:Connect(function()
		self:Died()
	end))
	self:Connect(self.Player.CharacterRemoving:Connect(function()
		self:Died()
	end))
	self:Connect(self.Player.Character.Humanoid.Died:Connect(function()
		self:Died()
	end))
	pcall(function()
		for _,State in pairs(Enum.HumanoidStateType:GetEnumItems()) do
			if State and State ~= Enum.HumanoidStateType.None and State ~= Enum.HumanoidStateType.Running and State ~= Enum.HumanoidStateType.Dead and State ~= Enum.HumanoidStateType.None then
				Horse.Humanoid:SetStateEnabled(State, false)
			end
		end
		Horse.Humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end)

	if self.UserInventory.HasCustomHorse then
		self.CustomInfo = self.UserData.Horse
	end

	for _, Part in pairs(self.Horse:GetDescendants()) do
		if (Part.ClassName == "Part" or Part.ClassName == "UnionOperation" or Part.ClassName == "MeshPart") and not Part.Anchored then
			Part:SetNetworkOwner(self.Player)
			if self.Breed == "Custom" and self.CustomInfo then
				if Part.Name == "Eyes" and self.CustomInfo.EyeColor then
					Part.BrickColor = BrickColor.new(self.CustomInfo.EyeColor)
				elseif Part.Name == "Saddle" and self.CustomInfo.SaddleColor then
					Part.BrickColor = BrickColor.new(self.CustomInfo.SaddleColor)
				elseif (Part.Name == "Mane" or Part.Name == "Tail") and self.CustomInfo.ManeColor then
					Part.BrickColor = BrickColor.new(self.CustomInfo.ManeColor)
				else
					Part.BrickColor = BrickColor.new(self.CustomInfo.BodyColor)
				end
			end
		end 
	end
end

function Horse:Call()
	if self.Horse and self.Horse:IsDescendantOf(game.Workspace) then
		if self.Called or self.Mounted then return end
		self.Called = true
		self.Horse.Humanoid.HipHeight = 2
		self.Horse.Humanoid.WalkSpeed = self.Stats.MaxSpeed / 2
		local Sound = game.ReplicatedStorage.Sounds.Whistle:Clone()
		Sound.Parent = self.Player.Character.Head
		Sound.PlaybackSpeed = .8
		Sound.PlaybackSpeed = 1
		Sound:Play()
		delay(Sound.TimeLength, function()
			Sound:Destroy()
		end)

		spawn(function()
			local Distance = self.Player:DistanceFromCharacter(self.Horse.PrimaryPart.Position)
			local Speed 
			local AnimType = "Walk"

			local function CheckDistance()
				Distance = self.Player:DistanceFromCharacter(self.Horse.PrimaryPart.Position)
				if Distance > 20 then
					if not  self.Anim.Sprint.IsPlaying then
						self:Animate("Sprint")
					end
					Speed = 85
				else
					if not  self.Anim.Walk.IsPlaying then
						self:Animate("Walk")
					end
					Speed = 20
				end
			end

			CheckDistance()
			local dir = (self.Player.Character.Head.Position - self.Horse.PrimaryPart.Position).unit * Vector3.new(1,0,1)
			self.BodyVelo.Velocity = dir * (Speed)
			self.Gyro.CFrame = CFrame.new(self.Horse.PrimaryPart.Position, self.Horse.PrimaryPart.Position + (dir * 10000))
			repeat wait(.365) 
				CheckDistance()
				dir = (self.Player.Character.Head.Position - self.Horse.PrimaryPart.Position).unit * Vector3.new(1,0,1) 
				self.BodyVelo.Velocity = dir * (Speed)
				self.Gyro.CFrame = CFrame.new(self.Horse.PrimaryPart.Position, self.Horse.PrimaryPart.Position + (dir * 10000)) 
			until 
			Distance <= 11
			self:Animate("Idle")
			--Horse.PrimaryPart.CFrame = CFrame.new(Horse.PrimaryPart.Position, Vector3.new(Player.Character.Head.Position.X, Horse.PrimaryPart.Position.Y, Player.Character.Head.Position.Z))
			self.Sound:Stop()
			self.BodyVelo.Velocity = Vector3.new()
			self.Called = false
			self.Anim.Sprint:Stop()
			self.Anim.Walk:Stop()
			self.Horse.Humanoid.WalkSpeed = self.Stats.WalkSpeed
		end)		
		return
	end	
end

function Horse:PassEvent(Player, Args)
	if Args[1] == "Mount" then	
		self:Mount(Player, Args[2])
	elseif Args[1] == "Unmount" then
		self:Unmount(Player)
	elseif Args[1] == "Summon" then
		self:Summon(Args[2])
	elseif Args[1] == "Call" then
		self:Call()
	elseif Args[1] == "PlayAnimation" then
		self:Animate(Args[2])
	elseif Args[1] == "PlaySound" then
		self:PlaySound(Args[2], Args[3], Args[4])
	end
end

-----------------------------------------------------------------------------------------------------------
Print("Loading Interactive Stable Methods.")
-----------------------------------------------------------------------------------------------------------
function Stable:Enter(Player, Attachment)
	if not Attachment.Parent then
		Events.Core:FireClient(Player, "Alert", "Stable Error Code 101. Stable slot not properly configured.", "Stables")
		return	
	end	
	if table.find(self.InUse, Attachment.Parent.Name) then
		Events.Core:FireClient(Player, "Alert", Attachment.Parent.Name .. " is already in use by " .. self.InUse[Attachment.Parent.Name].Name .. ". Please wait until they are finished.", "Stables")
		return 		
	end
	Print(Player.Name .. " has entered " .. Attachment.Parent.Name)
	local UI = game.ReplicatedStorage.UI.HorseShop:Clone()
	UI.Stable.Value = Attachment
	UI.Parent = Player.PlayerGui
	table.insert(self.InUse, Attachment.Parent.Name)
end

function Stable:Exit(Player, Attachment)
	Print(Player.Name .. " has left " .. Attachment.Parent.Name)
	local Slot = table.find(self.InUse, Attachment.Parent.Name)
	if Slot then 
		table.remove(self.InUse, Slot)
	end
	if Player.PlayerGui:FindFirstChild("HorseShop") then
		Player.PlayerGui["HorseShop"]:Destroy()
	end
end

function Stable:SaveCustomConfig(Player, Args)
	local UserData = Storage.Session[Player.Name]["UserData"]
	local Inventory = Storage.Session[Player.Name]["Inventory"]
	local ColorTable = Args[1]
	if not Inventory.HasCustomHorse and not Core:IsExecutive(Player) then return end

	for Name, Value in pairs(ColorTable) do
		if UserData.Horse[Name] then
			UserData.Horse[Name] = Value
		end
	end
end

function Stable:PassEvent(Player, Args)
	if Args[1] == "EnterStable" then	
		self:Enter(Player, Args[2])
	elseif Args[1] == "ExitStable" then
		self:Exit(Player, Args[2])
	elseif Args[1] == "SaveHorseConfig" then
		self:SaveCustomConfig(Player, Args[2])
	end
end

function H.newStable(Model)
	Print(Model.Name .. " has been configured!")
	local self = setmetatable({}, Stable)
	self.Model = Model
	CS:AddTag(self.Model, "Horse")
	self.Conn = {}
	self.InUse = {}	
	for _, Attachment in pairs(self.Model:GetDescendants()) do
		if Attachment.ClassName == "Attachment" and Attachment.Name == "StableShop" then
			CS:AddTag(Attachment, "Interactive")
			CS:AddTag(Attachment, "Stables")
			self.InUse[Attachment.Name] = nil
		end
	end
	table.insert(H.Stables, #H.Stables, self)
	return self	
end

for _, Model in pairs(game.Workspace:GetDescendants()) do
	if string.find(string.lower(Model.Name), "stable") and Model.ClassName == "Model" and Model:FindFirstChild("StableBase") then
		H.newStable(Model)
	end
end

-----------------------------------------------------------------------------------------------------------
Print("Listening to remote requests.")
-----------------------------------------------------------------------------------------------------------
function H:Retrieve(Player, Args)
	if Args[1] == "Stable" then
		for _, Slot in pairs(H.Stables) do
			if Args[3] and Slot.Model and (Args[3] == Slot.Model or Args[3]:IsDescendantOf(Slot.Model)) then
				table.remove(Args, 1)
				--Print("Retrieved Stable Area configuration for " .. Player.Name)
				return Slot, Args
			end
		end	
	elseif Args[1] == "Cart" then
		for _, Slot in pairs(H.Carts) do
			if Args[3] and Slot.Cart and (Args[3] == Slot.Cart or Args[3]:IsDescendantOf(Slot.Cart)) then
				table.remove(Args, 1)
				--Print("Returning cart configuration for " .. Player.Name)
				return Slot, Args
			end
		end		
	elseif Args[1] == "Horse" then
		for _, Slot in pairs(H.List) do
			if (not Args[3] or Args[3] and typeof(Args[3]) ~= "Instance") and (Slot.Player and Slot.Player == Player) then 
				--Print("Retrieved horse configuration for " .. Slot.Player.Name .. "'s Horse via: Player Object")
				table.remove(Args, 1)
				return Slot, Args
			elseif Args[3] and typeof(Args[3]) == "Instance" and Slot.Horse and (Args[3] == Slot.Horse or Args[3]:IsDescendantOf(Slot.Horse))  then
				--Print("Retrieved horse configuration for " .. Slot.Player.Name .. "'s Horse via: Descendant Object")
				table.remove(Args, 1)
				return Slot, Args
			end
		end		
	end
	Print("Creating new Horse instance for " .. Player.Name)
	table.remove(Args, 1)
	return H.new(Player), Args
end

function H:CanSummon(Player, HorseBreed) 
	if HorseBreed == "White" and (Player:IsInGroup(Library.Groups["Main Group"]) and Player:GetRankInGroup(Library.Groups["Main Group"]) == 20 or  Player:GetRankInGroup(Library.Groups["Main Group"]) == 48 or  Player:GetRankInGroup(Library.Groups["Main Group"]) == 50 or  Player:GetRankInGroup(Library.Groups["UP"]) >= 23) then 
		return true
	elseif HorseBreed == "Black" and (Player:IsInGroup(Library.Groups["Main Group"]) and Player:GetRankInGroup(Library.Groups["Main Group"]) == 20 or  Player:GetRankInGroup(Library.Groups["Main Group"]) == 48 or  Player:GetRankInGroup(Library.Groups["Main Group"]) == 50 or Player:GetRankInGroup(Library.Groups["UP"]) >= 23) then 
		return true
	elseif HorseBreed == "Custom" then
		local Inventory = Core.DataManagementFunctions:Get(Player, "Inventory")
		local UserData = Core.DataManagementFunctions:Get(Player, "UserData")		
		if Inventory.HasCustomHorse then 
			self.CustomInfo = UserData.Horse
			return true
		end
	elseif Core.PlayerManagementFunctions:PlayerOwnsProduct(Player, HorseBreed .. " Horse") or Player:GetRankInGroup(Library.Groups["UP"]) >= 23 then 
		return true
	elseif HorseBreed == "Standard" then 
		return true		
	end	
	return false
end

function H.new(Player)
	--Print("Creating new horse configuration for " .. Player.Name)
	local self
	--self = H:Retrieve(Player)
	--if self then self:Summon() return end
	local HorseBreed = Player.Data.Settings:FindFirstChild("Horse Breed")
	if not HorseBreed then
		HorseBreed = Instance.new("StringValue")
		HorseBreed.Value = "Standard"
		HorseBreed.Name = "Horse Breed"
		HorseBreed.Parent = Player.Data.Settings
	end

	local Breed = HorseBreed.Value
	if not Player.Character or not H:CanSummon(Player, Breed) then return end
	self = setmetatable({}, Horse)
	self.Breed = Breed
	self.Player = Player
	self.Mounted = false
	self.Called = false
	self.Sprinting = false
	self.Conn = {}
	self.Passengers = {}
	self.TimesMounted = 0	

	table.insert(H.List, self)	
	delay(DespawnTime, function()
		if self.TimesMounted == 0 then
			self:Died()
		end
	end)
	return self
end

function H.newCart(Player, Args)
	local Name = Args[1]
	local Position = Args[2]
	if not HorseLibrary[Name] then return Print(Name .. " is not a valid cart type. Cannot spawn.") end
	Print("A " .. Name .. " has been summoned!")
	local self = setmetatable({}, Cart)
	self.Breed = Name
	self.SpawnPosition = Position 
	Print(Player.Name .. " has spawned a " .. self.Breed .. " Cart.")
	self.Mounted = false
	self.Called = false
	self.Sprinting = false
	self.Conn = {}
	self.Passengers = {}
	self.TimesMounted = 0	

	table.insert(H.Carts, #H.Carts, self)
	delay(DespawnTime * 2, function()
		if self.TimesMounted == 0 then
			self:Died()
		end
	end)	
	self:Summon()
	return self	
end

function GetInfo(Player, ...)
	Print("Recieved.")
	local Args = {...}
	if Args[1] == "GetHorse" then
		for _, Slot in pairs(H.List) do
			if Slot.Player and Slot.Player == Player then
				return Slot.Horse
			end
		end		
	elseif Args[1] == "ChangeHorseName" then
		local Name = game.TextService:FilterStringAsync(Args[2], Player, Player)
		Storage.Session[Player.Name]["UserData"]["Horse"]["Name"] = Name
		Print("Changed ", Player.Name, "'s Horse Name to:", Name)
		return true
	end
end

Event.OnServerEvent:Connect(function(Player, ...)
	local Args = {...}
	if Args[1] == "SpawnCart" then
		table.remove(Args, 1)
		H.newCart(Player, Args)
		return
	elseif Args[1] == "RequestHorse" then
		H.new(Player)
	elseif Args[1] == "ChangeHorseName" then
		local Meta = H:Retrieve(Player, {"Horse"}) 
		Core.DataManagementFunctions:SetValue(Player, "UserData", "HorseName", Args[2])
		if Meta and Meta.Horse then
			Meta.Horse.Name = game.TextService:FilterStringAsync(Args[2], Player, Player)
		end
		return true	
	elseif Args[1] == "ChangeHorseColors" then
		local UserData = Core.DataManagementFunctions:Get(Player, "UserData")	
		for Name, Value in pairs(Args[2]) do
			UserData.Horse[Name] = Value
		end
		Events.Core:FireClient(Player, "Notify", "Custom horse saved!", BrickColor.new("Hot pink"))
		return true
	end

	local Object, NewArgs = H:Retrieve(Player, Args)

	if Object then 
		Object:PassEvent(Player, NewArgs) 
	end
end)

Events.Information.OnServerInvoke = GetInfo

return H