local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService('UserInputService')

local FRAME_RATE = 60

local module = {

	Name = 'Air Jab';
	Description = ' An offensive action that fires small amounts of compressed air. Jabs can be used in quick succession and provide an easy means of sustained pressure.';

	FrameData = {

		Movement = 'Horizontal'; -- Describes the general thrust direction that the move will tend to follow 
		Target = 'N/A'; -- String value used to demonstrate the limb that can be impacted; may be used in the future to perform possible damage multipliers/ disabilities 
		Range = 'N/A'; -- String value used to easily present information about the constraints of the hitbox(es)

		Cooldown = .15;
		ResourceCost = 0;

		StartUp = 2;
		Active = 14; 
		Recovery = 12;
		Cancel = 0;

	};

	PhysicsData = {
		HorizontalThrust = Vector3.new(0,0,50);
		HorizontalThrustRelativeToTarget = true;
	};

	HitboxData = {
		['Hitbox_1'] = {				
			DelayTime = 0;
			Duration = 1000; 
			Size = Vector3.new(8, 8, 8);
			RelativeToOwner = true;
			FixedCoordinates = CFrame.new(0,0,0);
			FixedToOwner = false;
			DamageInterval = 1; 
			RepeatCount = nil; 
			RepeatFrameDelay = nil;
			MaxTargets = nil;
			Velocity = Vector3.new(0, 0, -300);
			VelocityRelativeToOwner = true;

			HitDamage = 2; -- Damage inflicted on target directly
			ImpactDamage = 2; -- Damage inflicted to target directly while guarding
			GuardDamage = 2; -- Damage inflicted on the target's guard

			HitStun = .75;
			BlockStun = .5;

			KnockbackOnHit = Vector3.new(0, 0, 50);
			KnockbackOnHitRelativeToTarget = true;

			KnockbackOnGuard = Vector3.new(0, 0, 50);
			KnockbackOnGuardRelativeToTarget = true;

			selfDamaging = false; -- Probably won't use these special properties but it would be cool to do something with them
			canClash = true; -- at a later date 
			canGuardBreak = false;
			canCounter = false;
			canParry = false;

			CompletionCallback = function(self)

				if self.HitboxObject then
					self.HitboxObject:Stop()
					self.HitboxObject = nil
				end

				if self.ActiveConnection then
					self.ActiveConnection:Disconnect()
					self.ActiveConnection = nil
				end	

				if self.CollisionBox then
					self.CollisionBox:Destroy()
					self.CollisionBox = nil
				end

			end, 

			CollisionCallback = function(self, object)
				
				local Humanoid = self.HitboxModule:FindHumanoidFromInstance(object)

				if Humanoid and self.PreviousCollisions and not self.PreviousCollisions[Humanoid] then

					local hitbox_damage = self.HitDamage

					self.PreviousCollisions[Humanoid] = tick()
					Humanoid:TakeDamage(hitbox_damage)

					if self.MaxTargets and typeof(self.MaxTargets) == 'number' and self.MaxTargets > 0 then 
						self.MaxTargets -= 1
					elseif self.MaxTargets and typeof(self.MaxTargets) == 'number' and self.MaxTargets <= 0 then 
						self.CompletionCallback(self)
					end 
					
				end 

				if self.DamageInterval and typeof(self.DamageInterval) == 'number' then 

					task.delay(self.DamageInterval, function()
						if self and self.PreviousCollisions and self.PreviousCollisions[Humanoid] then 
							self.PreviousCollisions[Humanoid] = nil; 
						end
					end)

				end 

			end,
		}; 
		
		['Hitbox_2'] = {				
			DelayTime = 0;
			Duration = 1000; 
			Size = Vector3.new(8, 8, 8);
			RelativeToOwner = true;
			FixedCoordinates = CFrame.new(0,0,0);
			FixedToOwner = false;
			DamageInterval = 1; 
			RepeatCount = 1; 
			RepeatFrameDelay = 2;
			MaxTargets = nil;
			Velocity = Vector3.new(0, 0, -300);
			VelocityRelativeToOwner = true;

			HitDamage = 2; -- Damage inflicted on target directly
			ImpactDamage = 2; -- Damage inflicted to target directly while guarding
			GuardDamage = 2; -- Damage inflicted on the target's guard

			HitStun = .75;
			BlockStun = .5;

			KnockbackOnHit = Vector3.new(0, 0, 50);
			KnockbackOnHitRelativeToTarget = true;

			KnockbackOnGuard = Vector3.new(0, 0, 50);
			KnockbackOnGuardRelativeToTarget = true;

			selfDamaging = false; -- Probably won't use these special properties but it would be cool to do something with them
			canClash = true; -- at a later date 
			canGuardBreak = false;
			canCounter = false;
			canParry = false;
			
			CreationCallback = function(self)
				
				if not self.Size or not self.RepeatCount or not self.proxyRepeatIndex or not self.CollisionBox or not self.Owner or not self.Owner.PrimaryPart then
					return 
				end
				
				local function Line_Segment_Subdivision(p1, p2, k)
					if not p1 or not p2 or not k then
						return
					end
					return p1 + k*(p2-p1)
				end

				local function Line_Segment_Given_Midpoint(m, distance)

					if not m or not distance then
						return
					end

					local x1 = (m - (distance/2))
					local x2 = (m + (distance/2))

					return x1, x2

				end
				
				local amount = self.RepeatCount + 1
				local index = self.proxyRepeatIndex
				local size = self.Size.Magnitude
					
				local offset = 5
				local right_displacement = -size/2
				local height_displacement = 0
				local look_displacement = 0

				local x1, x2 = Line_Segment_Given_Midpoint(right_displacement, offset*amount)

				local p1 = amount > 1 and Line_Segment_Subdivision(x1, x2, (index-1)/(amount-1)) or right_displacement
								
				self.CollisionBox.CFrame = self.Owner.PrimaryPart.CFrame:ToWorldSpace(CFrame.new(p1 + size/2 , height_displacement , look_displacement ))	
				
			end;

			CompletionCallback = function(self)

				if self.HitboxObject then
					self.HitboxObject:Stop()
					self.HitboxObject = nil
				end

				if self.ActiveConnection then
					self.ActiveConnection:Disconnect()
					self.ActiveConnection = nil
				end	

				if self.CollisionBox then
					self.CollisionBox:Destroy()
					self.CollisionBox = nil
				end

			end, 

			CollisionCallback = function(self, object)

				local Humanoid = self.HitboxModule:FindHumanoidFromInstance(object)

				if Humanoid and self.PreviousCollisions and not self.PreviousCollisions[Humanoid] then

					local hitbox_damage = self.HitDamage

					self.PreviousCollisions[Humanoid] = tick()
					Humanoid:TakeDamage(hitbox_damage)

					if self.MaxTargets and typeof(self.MaxTargets) == 'number' and self.MaxTargets > 0 then 
						self.MaxTargets -= 1
					elseif self.MaxTargets and typeof(self.MaxTargets) == 'number' and self.MaxTargets <= 0 then 
						self.CompletionCallback(self)
					end 

				end 

				if self.DamageInterval and typeof(self.DamageInterval) == 'number' then 

					task.delay(self.DamageInterval, function()
						if self and self.PreviousCollisions and self.PreviousCollisions[Humanoid] then 
							self.PreviousCollisions[Humanoid] = nil; 
						end
					end)

				end 

			end,
		}; 
		
		['Hitbox_3'] = {				
			DelayTime = 0;
			Duration = 1000; 
			Size = Vector3.new(8, 8, 8);
			RelativeToOwner = true;
			FixedCoordinates = CFrame.new(0,0,0);
			FixedToOwner = false;
			DamageInterval = 1; 
			RepeatCount = 2; 
			RepeatFrameDelay = 2;
			MaxTargets = nil;
			Velocity = Vector3.new(0, 0, -300);
			VelocityRelativeToOwner = true;

			HitDamage = 1.5; -- Damage inflicted on target directly
			ImpactDamage = 1.5; -- Damage inflicted to target directly while guarding
			GuardDamage = 1.5; -- Damage inflicted on the target's guard

			HitStun = .75;
			BlockStun = .5;

			KnockbackOnHit = Vector3.new(0, 0, 50);
			KnockbackOnHitRelativeToTarget = true;

			KnockbackOnGuard = Vector3.new(0, 0, 50);
			KnockbackOnGuardRelativeToTarget = true;

			selfDamaging = false; -- Probably won't use these special properties but it would be cool to do something with them
			canClash = true; -- at a later date 
			canGuardBreak = false;
			canCounter = false;
			canParry = false;

			CompletionCallback = function(self)

				if self.HitboxObject then
					self.HitboxObject:Stop()
					self.HitboxObject = nil
				end

				if self.ActiveConnection then
					self.ActiveConnection:Disconnect()
					self.ActiveConnection = nil
				end	

				if self.CollisionBox then
					self.CollisionBox:Destroy()
					self.CollisionBox = nil
				end

			end, 
			
			CreationCallback = function(self)

				if not self.Size or not self.RepeatCount or not self.proxyRepeatIndex or not self.CollisionBox or not self.Owner or not self.Owner.PrimaryPart then
					return 
				end

				local function Line_Segment_Subdivision(p1, p2, k)
					if not p1 or not p2 or not k then
						return
					end
					return p1 + k*(p2-p1)
				end

				local function Line_Segment_Given_Midpoint(m, distance)

					if not m or not distance then
						return
					end

					local x1 = (m - (distance/2))
					local x2 = (m + (distance/2))

					return x1, x2

				end

				local amount = self.RepeatCount + 1
				local index = self.proxyRepeatIndex
				local size = self.Size.Magnitude

				local offset = 5
				local right_displacement = -size/2
				local height_displacement = 0
				local look_displacement = 0

				local x1, x2 = Line_Segment_Given_Midpoint(right_displacement, offset*amount)

				local p1 = amount > 1 and Line_Segment_Subdivision(x1, x2, (index-1)/(amount-1)) or right_displacement

				self.CollisionBox.CFrame = self.Owner.PrimaryPart.CFrame:ToWorldSpace(CFrame.new(p1 + size/2 , height_displacement , look_displacement ))	

			end;

			CollisionCallback = function(self, object)

				local Humanoid = self.HitboxModule:FindHumanoidFromInstance(object)

				if Humanoid and self.PreviousCollisions and not self.PreviousCollisions[Humanoid] then

					local hitbox_damage = self.HitDamage

					self.PreviousCollisions[Humanoid] = tick()
					Humanoid:TakeDamage(hitbox_damage)

					if self.MaxTargets and typeof(self.MaxTargets) == 'number' and self.MaxTargets > 0 then 
						self.MaxTargets -= 1
					elseif self.MaxTargets and typeof(self.MaxTargets) == 'number' and self.MaxTargets <= 0 then 
						self.CompletionCallback(self)
					end 

				end 

				if self.DamageInterval and typeof(self.DamageInterval) == 'number' then 

					task.delay(self.DamageInterval, function()
						if self and self.PreviousCollisions and self.PreviousCollisions[Humanoid] then 
							self.PreviousCollisions[Humanoid] = nil; 
						end
					end)

				end 

			end,
		};  
	};

	ActionInputs = {

		'MouseButton1';

	};

}

local function ConvertSecondsToMilliseconds(Milliseconds)
	if not Milliseconds or typeof(Milliseconds) ~= 'number' then
		return
	end

	local conversion = Milliseconds * 1000;

	return conversion
end

local function RayCast(origin, range, ignore)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = ignore
	raycastParams.IgnoreWater = true


	local raycastResult = workspace:Raycast(origin, range, raycastParams)

	return raycastResult	
end

local function Destroyed(x)
	if x.Parent then return false end
	local _, result = pcall(function() x.Parent = x end)
	return result:match("locked") and true or false
end

local function ProjectileVelocityMovement(options)

	if not options.Projectile then
		return
	end

	local callback = options.Callback

	local Projectile = options.Projectile
	local Direction = options.Direction or Projectile.CFrame.LookVector
	local Speed = options.Speed or 5
	local Velocity = options.Velocity or (Direction and Speed and Direction * Speed) or Vector3.new(0,1,0)
	local Position = options.Position or Projectile.CFrame.Position
	local Duration = options.Timeout or 100

	local g = options.Gravity or 0
	local Gravity = Vector3.new(0, -g, 0)

	local ProjectileMovementConnection
	local callbackThread 
	
	local function CompletedCallback()
		if callback and type(callback) == 'function' then
			callback()
		end
	end
	
	local function Update(dt)
		
		if Destroyed(Projectile) then
			ProjectileMovementConnection:Disconnect()
			
			if callbackThread then 
				task.cancel(callbackThread)
			end
			
			CompletedCallback()
			
		end
		
		Velocity = Velocity + Gravity * dt 
		Position = Position + Velocity * dt
		Projectile.CFrame = CFrame.new(Position, Position + Velocity)
	end

	ProjectileMovementConnection = RunService.Heartbeat:Connect(Update)

	callbackThread = task.delay(Duration, function()
		ProjectileMovementConnection:Disconnect()
		ProjectileMovementConnection = nil

		CompletedCallback()

	end)

end

local function CreateHitBox(options)
	
	if not options.Owner or typeof(options.Owner) ~= 'Instance' or not options.Owner:IsA('Model') or not options.Owner.PrimaryPart then 
		return 
	end
	
	local function ResetPreviousBodyMovers(instance)
		for _, inst in pairs(instance:GetDescendants()) do
			if inst and typeof(inst) == 'Instance' and inst:IsA('BodyMover') then
				inst:Destroy()
			end
		end

	end

	local function EstablishPrimaryBodyMovers(owner)
		
		if not owner or typeof(owner) ~= 'Instance' or not owner:IsA('BasePart') then
			return 
		end

		ResetPreviousBodyMovers(owner)

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.Name = '';
		BodyVelocity.Velocity = Vector3.new();
		BodyVelocity.MaxForce = Vector3.new(1e9,1e9,1e9);
		BodyVelocity.Parent = owner;

		local BodyGyro = Instance.new('BodyGyro')
		BodyGyro.Name = '';
		BodyGyro.CFrame = CFrame.new(Vector3.new(), Vector3.new());
		BodyGyro.MaxTorque = Vector3.new(1e9,1e9,1e9);
		BodyGyro.P = 1e9
		BodyGyro.D = 1e9*.025
		BodyGyro.Parent = owner;

		return BodyVelocity, BodyGyro
	end

	local function EstablishSecondaryBodyMovers(owner)
		
		if not owner or typeof(owner) ~= 'Instance' or not owner:IsA('BasePart') then
			return 
		end

		ResetPreviousBodyMovers(owner)

		local BodyPosition = Instance.new("BodyPosition")
		BodyPosition.Name = '';
		BodyPosition.Position = Vector3.new();
		BodyPosition.MaxForce = Vector3.new(0,0,0);
		BodyPosition.P = 1e9
		BodyPosition.D = 1e9*.00025
		BodyPosition.Parent = owner;


		local BodyGyro = Instance.new('BodyGyro')
		BodyGyro.Name = '';
		BodyGyro.CFrame = CFrame.new(Vector3.new(), Vector3.new());
		BodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000);
		BodyGyro.P = 1e9
		BodyGyro.D = 1e9*.00025
		BodyGyro.Parent = owner;

		return BodyPosition, BodyGyro
	end
	
	local hitbox_proxy = Instance.new('Part')
	hitbox_proxy.Shape = options.Shape or Enum.PartType.Block
	hitbox_proxy.Size = options.Size or Vector3.new()
	hitbox_proxy.RootPriority = -127 
	hitbox_proxy.CFrame = options.RelativeTo and typeof(options.RelativeTo) == 'Instance' and options.RelativeTo:IsA('BasePart') and options.CFrame and typeof(options.CFrame) == 'CFrame' and options.RelativeTo.CFrame:ToWorldSpace(options.CFrame) 
		or options.CFrame ~= nil and typeof(options.CFrame) == 'CFrame' and options.CFrame 
		or CFrame.new()
	
	if options.Velocity and typeof(options.Velocity) == 'Vector3' and options.Velocity.Magnitude > 0 then 		
		--local hitboxVelocity, hitboxGyro = EstablishPrimaryBodyMovers(hitbox_proxy)
		--hitboxVelocity.Velocity = options.VelocityRelativeToOwner and options.Owner.PrimaryPart.CFrame:VectorToWorldSpace(options.Velocity) or options.Velocity
		--hitboxGyro.CFrame = CFrame.lookAt(hitbox_proxy.Position, hitbox_proxy.CFrame.lookVector * 100)
		
		-- [[ ENCOUNTERED ISSUE WITH NETWORKOWNERSHIP | RESPONSIVENESS WAS DELAYED SIGNIFICANTLY | DETERMINED CFRAME PROJECTION WAS FAR MORE OPTIMAL | POSSIBLE SOLUTION : BUFFER HITBOX]]
		hitbox_proxy.Anchored = true
		task.delay(options.ProjectileDelay or 0, function()
			ProjectileVelocityMovement({
				Projectile = hitbox_proxy;
				Velocity = options.VelocityRelativeToOwner and options.Owner.PrimaryPart.CFrame:VectorToWorldSpace(options.Velocity) or options.Velocity;
			})
		end)
		
	elseif options.FixedTo and typeof(options.FixedTo) == 'Instance' and options.FixedTo:IsA('BasePart') then 	
		local constraint = Instance.new('WeldConstraint')
		constraint.Part0 = hitbox_proxy
		constraint.Part1 = options.FixedTo	
		constraint.Parent = hitbox_proxy
	else
		hitbox_proxy.Anchored = if options.Anchored ~= nil and options.Anchored ~= true and typeof(options.Anchored) == 'boolean' then options.Anchored else true 
	end
	
	hitbox_proxy.Name = '_Hitbox'
	hitbox_proxy.CanCollide = false -- It wouldn't be a hitbox detector if it could collide with objects 
	hitbox_proxy.Massless = true
	hitbox_proxy.Material = Enum.Material.SmoothPlastic -- Causes minimal influences in terms of memory
	hitbox_proxy.Transparency = options.Transparency or 1
	hitbox_proxy.Parent = options.Container or workspace
	
	local networkOwner = if options.FixedTo or hitbox_proxy.Anchored then false else nil 
	
	if networkOwner ~= false then 
		hitbox_proxy:SetNetworkOwner(networkOwner)
	end

	if options.Duration and typeof(options.Duration) == 'number' then 
		task.delay(options.Duration, function()
			hitbox_proxy:Destroy()
		end)
	end

	CollectionService:AddTag(hitbox_proxy, '_Hitbox')
	return hitbox_proxy
end

function module:ExecuteAbility_Server(playerData)

	if not playerData or typeof(playerData) ~= 'table' or not playerData.Repository.Timer or not playerData.Repository.Utilities or not playerData.Repository.NetworkManager or not playerData.Repository.HitboxModuleMain then
		return
	end
	
	local player = playerData.User
	local character = player.Character

	if not player or not character then
		return 
	end

	local function Cooldown()

		local convertedCooldown = ConvertSecondsToMilliseconds(module.FrameData.Cooldown)

		local CooldownID = playerData.Repository.Timer.SetTimeout(function()
			if playerData.Cooldowns and playerData.Cooldowns[module.Name] then 
				playerData.Cooldowns[module.Name] = nil
			end
		end, convertedCooldown)

		playerData.Cooldowns[module.Name] = {
			CooldownTimer = CooldownID;
			CooldownTime = module.FrameData.Cooldown;
		};

	end

	local function StartupCancel()
		if player then 
			playerData.Repository.NetworkManager:FireClient(player, 'ToolInputData' , {
				Ability = module.Name;
				Action = 'CancelMovement';
			})
		end
	end

	local function ActiveCancel()
		StartupCancel()
	end

	local function RecoveryCancel()
		ActiveCancel()
	end

	local function FrameDataCancel()
		RecoveryCancel()
	end

	local function Cancel(frameCancel)
		
		local convertedCancelFrames = module.FrameData.Cancel/FRAME_RATE

		if not frameCancel and not playerData.ActiveMoves[module.Name].StartTime or playerData.ActiveMoves[module.Name].StartTime and tick() - playerData.ActiveMoves[module.Name].StartTime < convertedCancelFrames  then 
			return 
		end

		for _, signal in pairs(playerData.ActiveMoves[module.Name].FrameDataSignals) do 
			signal:Destroy()
		end

		for _, connection in pairs(playerData.ActiveMoves[module.Name].Connections) do 
			if connection and typeof(connection) == 'RBXScriptConnection' then
				connection:Disconnect()
			end
		end

		for _, ID in pairs(playerData.ActiveMoves[module.Name].FrameDataSchedules) do 
			playerData.Repository.Timer.Clear(ID)
		end

		if frameCancel then 	
			FrameDataCancel()
		else 

			if playerData.ActiveMoves[module.Name].CurrentFrameDataStage == 'Recovery' then
				RecoveryCancel()
			elseif playerData.ActiveMoves[module.Name].CurrentFrameDataStage == 'Active' then 
				ActiveCancel()
			elseif playerData.ActiveMoves[module.Name].CurrentFrameDataStage == 'Startup' then 
				StartupCancel()
			end

		end

		playerData.ActiveMoves[module.Name] = nil 

		Cooldown()
	end

	local function Recovery()
		local convertedRecoveryFrames = ConvertSecondsToMilliseconds(module.FrameData.Recovery/FRAME_RATE)
		playerData.ActiveMoves[module.Name].CurrentFrameDataStage = 'Recovery'
		------

		playerData.ActiveMoves[module.Name].CanCancelMove = false

		------

		if playerData.ActiveMoves[module.Name].Connections['ActiveHitboxDetection'] and typeof(playerData.ActiveMoves[module.Name].Connections['ActiveHitboxDetection']) == 'RBXScriptConnection' then 
			playerData.ActiveMoves[module.Name].Connections['ActiveHitboxDetection']:Disconnect()
		end

		for _, data in pairs(playerData.ActiveMoves[module.Name].HitBoxes) do 

			if data.HitboxObject then 
				data.HitboxObject:Stop()
			end

			if data.ActiveConnection and typeof(data.ActiveConnection) == 'RBXScriptConnection' then 
				data.ActiveConnection:Disconnect()
			end

			if data.CompletionCallback then 
				data.CompletionCallback(data)
			end 

		end

		------
		playerData.ActiveMoves[module.Name].FrameDataSchedules.Recovery = playerData.Repository.Timer.SetTimeout(Cancel, convertedRecoveryFrames)
	end

	local function Active()
		local convertedActiveFrames = ConvertSecondsToMilliseconds(module.FrameData.Active/FRAME_RATE)
		playerData.ActiveMoves[module.Name].CurrentFrameDataStage = 'Active'
		------

		playerData.ActiveMoves[module.Name].Connections['ActiveHitboxDetection'] = RunService.Stepped:Connect(function(dt)

			if playerData.ActiveMoves[module.Name].HitBoxes then 

				for _, data in pairs(playerData.ActiveMoves[module.Name].HitBoxes) do 

					if data and not data.ActiveConnection and data.CollisionBox and data.HitboxOverlapParams and data.CollisionCallback then 

						data.HitboxObject = playerData.Repository.HitboxModuleMain:CreateWithPart(data.CollisionBox, data.HitboxOverlapParams)
						data.HitboxObject:Start()

						data.ActiveConnection = data.HitboxObject.Touched:Connect(function(object)
							data.CollisionCallback(data, object)
						end)

					end

				end

			end

		end)

		------

		playerData.ActiveMoves[module.Name].FrameDataSchedules.Active = playerData.Repository.Timer.SetTimeout(Recovery, convertedActiveFrames)
	end

	local function Startup()

		local convertedStartupFrames = ConvertSecondsToMilliseconds(module.FrameData.StartUp/FRAME_RATE)
		playerData.ActiveMoves[module.Name].CurrentFrameDataStage = 'Startup'
		------

		local function SelectRandomHitboxFromData()

			local storage = {}
			local RNG = Random.new()

			for index, _ in pairs(module.HitboxData) do 
				table.insert(storage, index)
			end

			local selectedHitBoxIndex = storage[RNG:NextInteger(1, #storage)]
			
			return module.HitboxData[selectedHitBoxIndex]

		end

		local selectedHitboxData = SelectRandomHitboxFromData()
		local mouseDirection = Vector3.new()
		local mouseCFrame = playerData.RawActionInputs['MouseMovement']
		mouseDirection = mouseCFrame == mouseCFrame and mouseCFrame ~= nil and typeof(mouseCFrame) == 'CFrame' and mouseCFrame.Position or mouseDirection
		

		if not selectedHitboxData or typeof(selectedHitboxData) ~= 'table' then 
			Cancel(true)
		end

		local function StartHitbox()

			local function dataCopy(data)
				local copy = {}

				for k, v in pairs(data) do 

					if typeof(v) == 'table' then 
						v = dataCopy(v)
					end 

					copy[k] = v
				end 

				return copy 
			end 
			
			local function GenerateProxyHitbox(insertData)
				
				if not playerData or not playerData.ActiveMoves or not playerData.ActiveMoves[module.Name] or not playerData.ActiveMoves[module.Name].HitBoxes then
					return 
				end
				
				if insertData and typeof(insertData) ~= 'table' then
					return
				end
				
				local proxyHitboxData = dataCopy(selectedHitboxData)
				proxyHitboxData.Owner = character;
				
				if insertData then
					for index, value in pairs(insertData) do 
						proxyHitboxData[index] = value
					end
				end
				
				local ProxyOverlapParams = OverlapParams.new();
				ProxyOverlapParams.FilterDescendantsInstances = {character, unpack(CollectionService:GetTagged('ClientEffect'))}
				ProxyOverlapParams.FilterType = Enum.RaycastFilterType.Blacklist 
				
				local mouseDirectedVelocity = (mouseDirection-character.PrimaryPart.CFrame.Position).Unit*proxyHitboxData.Velocity.Magnitude
				
				local rawFixedCoordinates = CFrame.lookAt(character.PrimaryPart.Position, mouseDirection):ToWorldSpace(proxyHitboxData.FixedCoordinates)
				
				local ProxyCollisionBox = CreateHitBox({
					Owner = proxyHitboxData.Owner;
					Size = proxyHitboxData.Size;
					CFrame = rawFixedCoordinates;
					Duration = proxyHitboxData.Duration;
					FixedTo = proxyHitboxData.FixedToOwner and character.PrimaryPart or nil ;
					Velocity = mouseDirectedVelocity or proxyHitboxData.Velocity;
					VelocityRelativeToOwner = if mouseDirectedVelocity then false else proxyHitboxData.VelocityRelativeToOwner;
					ProjectileDelay = module.FrameData.StartUp/FRAME_RATE;
				})

				proxyHitboxData.HitboxOverlapParams = ProxyOverlapParams
				proxyHitboxData.CollisionBox = ProxyCollisionBox
				proxyHitboxData.HitboxModule = playerData.Repository.HitboxModuleMain
				proxyHitboxData.PreviousCollisions = {}
				
				if proxyHitboxData.CreationCallback then 
					proxyHitboxData.CreationCallback(proxyHitboxData)
				end
				
				local elapsedDelayTime = (tick() - playerData.ActiveMoves[module.Name].StartTime) - 1/60
								
				_G.EffectService:FireAllClients('AirJab','AirJabProjectileWithProxy', {
					Character = character;
					Duration = module.FrameData.Active/FRAME_RATE - elapsedDelayTime;
					ProxyObject = ProxyCollisionBox;
				})

				table.insert(playerData.ActiveMoves[module.Name].HitBoxes, proxyHitboxData)
			end

			local hitboxRepeatCount = selectedHitboxData.RepeatCount 
			local hitboxRepeatFrameDelay = selectedHitboxData.RepeatFrameDelay
			local hitboxRepeatIndex = 1
			
			local function RepeatHitboxGeneration()
				if hitboxRepeatCount and typeof(hitboxRepeatCount) == 'number' and hitboxRepeatCount > 0 and hitboxRepeatIndex <= hitboxRepeatCount then
										
					playerData.ActiveMoves[module.Name].ScheduledHitboxes = playerData.ActiveMoves[module.Name].ScheduledHitboxes or {}

					table.insert(playerData.ActiveMoves[module.Name].ScheduledHitboxes , task.delay(hitboxRepeatFrameDelay/FRAME_RATE or 0, function()
						hitboxRepeatIndex += 1
						GenerateProxyHitbox({
							proxyRepeatIndex = hitboxRepeatIndex
						})
						RepeatHitboxGeneration()
					end))

				end
			end
			
			GenerateProxyHitbox({
				proxyRepeatIndex = 1
			})
			
			RepeatHitboxGeneration()

		end
		
		task.delay(selectedHitboxData.DelayTime or 0, function()
			StartHitbox()
			if player then 
				playerData.Repository.NetworkManager:FireClient(player, 'ToolInputData' , {
					Ability = module.Name;
					Action = 'StartMovement';
					TargetDirection = mouseDirection;
					Direction = (mouseDirection-character.PrimaryPart.CFrame.Position).Unit;
					Speed =  module.PhysicsData.HorizontalThrust.Magnitude * -1;
				})
			end
			_G.EffectService:FireAllClients('CameraShake','Bump')
		end)
				
		------
		playerData.ActiveMoves[module.Name].StartTime = tick()
		playerData.ActiveMoves[module.Name].FrameDataSchedules.Startup = playerData.Repository.Timer.SetTimeout(Active, convertedStartupFrames)
	end

	local function InitializeAbility()

		playerData.ActiveMoves = playerData.ActiveMoves or {}
		playerData.ActiveMoves[module.Name] = playerData.ActiveMoves[module.Name] or {}

		playerData.ActiveMoves[module.Name].FrameDataSignals = playerData.ActiveMoves[module.Name].FrameDataSignals or {}
		playerData.ActiveMoves[module.Name].FrameDataSchedules = playerData.ActiveMoves[module.Name].FrameDataSchedules or {}

		playerData.ActiveMoves[module.Name].Connections = playerData.ActiveMoves[module.Name].Connections or {}

		playerData.ActiveMoves[module.Name].HitBoxes = playerData.ActiveMoves[module.Name].HitBoxes or {}

		playerData.ActiveMoves[module.Name].CurrentFrameDataStage = nil 
		playerData.ActiveMoves[module.Name].CanCancelMove = true 

		playerData.Cooldowns = playerData.Cooldowns or {}

		Startup()
	end

	local function SatisfiedAbilityRequirements()

		if playerData.ActiveMoves then 

			for ability, _  in pairs(playerData.ActiveMoves) do 

				if ability then
					return false
				end

			end

		end

		if not character:FindFirstChild('Humanoid') then 
			return false
		end

		return true 

	end

	if not SatisfiedAbilityRequirements() then
		return 
	end	
	-- Do preliminary checks here prior to intialization 

	InitializeAbility()

end

function module:ExecuteAbility_Client(options)

	local Default_BodyMover_TagName = 'AirJabBodyMover'
	
	local player = options.Player 
	local character = player  and player.Character 
	local humanoid = character and character.Humanoid 
	local Mouse = player and player:GetMouse()

	if not character or not Mouse or not humanoid or not options or typeof(options) ~= 'table' then 
		return 
	end

	local function UpdateClientCurrentAction(action)

		if not action or typeof(action) ~= 'string' then
			return 
		end

		module.PreviousAction = module.CurrentAction
		module.CurrentAction = action 

	end

	local function ResetClientActions()
		module.PreviousAction = nil
		module.CurrentAction = nil
	end

	local function ProvidedCurrentAction()
		return module.CurrentAction
	end

	local function ProvidedPreviousAction()
		return module.PreviousAction
	end

	local function ResetPreviousBodyMovers()
		for _, inst in pairs(CollectionService:GetTagged(Default_BodyMover_TagName)) do
			if inst and typeof(inst) == 'Instance' and inst:IsA('BodyMover') then
				inst:Destroy()
			end
		end

	end

	local function EstablishPrimaryBodyMovers(character)

		local previousBodyMovers = CollectionService:GetTagged(Default_BodyMover_TagName)

		if previousBodyMovers and typeof(previousBodyMovers) == 'table' and #previousBodyMovers > 0 then 
			ResetPreviousBodyMovers()
		end

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.Name = '';
		BodyVelocity.Velocity = Vector3.new();
		BodyVelocity.MaxForce = Vector3.new(1e9,1e9,1e9);
		BodyVelocity.Parent = character.PrimaryPart;

		CollectionService:AddTag(BodyVelocity, Default_BodyMover_TagName)

		local BodyGyro = Instance.new('BodyGyro')
		BodyGyro.Name = '';
		BodyGyro.CFrame = CFrame.new(Vector3.new(), Vector3.new());
		BodyGyro.MaxTorque = Vector3.new(1e9,1e9,1e9);
		BodyGyro.P = 1e9
		BodyGyro.D = 1e9*.00025
		BodyGyro.Parent = character.PrimaryPart;

		CollectionService:AddTag(BodyGyro, Default_BodyMover_TagName)

		return BodyVelocity, BodyGyro
	end

	local function characterThrust(options)


		local thrustDirection = module.PhysicsData.HorizontalThrust and typeof(module.PhysicsData.HorizontalThrust) == 'Vector3' 
		thrustDirection = thrustDirection and module.PhysicsData.HorizontalThrustRelativeToTarget and character.PrimaryPart.CFrame:VectorToWorldSpace(module.PhysicsData.HorizontalThrust)
			or thrustDirection and module.PhysicsData.HorizontalThrust

		local launchSpeed = options.Speed
		local launchDirection = options.Direction 
		local launchDuration = options.Duration 
		
		local LaunchVelocity, LaunchGyro = EstablishPrimaryBodyMovers(character) 
		
		for i = 0, launchDuration or .1, 1/60 do 

			character.Humanoid.WalkSpeed = 0
			LaunchVelocity.Velocity = (launchDirection * launchSpeed) or thrustDirection or character.PrimaryPart.CFrame.lookVector * -150
			character.PrimaryPart.CFrame = character.PrimaryPart.CFrame:Lerp(CFrame.lookAt(character.PrimaryPart.Position, options.TargetDirection), i/(launchDuration or .1))
			LaunchGyro.CFrame = CFrame.lookAt(character.PrimaryPart.Position, character.PrimaryPart.CFrame.lookVector * 100)
			
			if not LaunchVelocity.Parent or not LaunchGyro.Parent then
				return 
			end

			RunService.RenderStepped:Wait()
		end

		LaunchVelocity:Destroy()
		LaunchGyro:Destroy()
	end

	if options.Action == 'StartMovement' then 
		if ProvidedPreviousAction() ~=  nil or ProvidedCurrentAction() ~= nil then 
			return 
		end

		UpdateClientCurrentAction(options.Action)

		module.previousHumanoidWalkSpeed = humanoid.WalkSpeed

		characterThrust(options)

	end

	if options.Action == 'CancelMovement' then

		UpdateClientCurrentAction(options.Action)

		if module.Connections and typeof(module.Connections) == 'table' then 

			for _, connection in pairs(module.Connections) do 
				if connection and typeof(connection) == 'RBXScriptConnection' then
					connection:Disconnect()
				end
			end

		end

		ResetPreviousBodyMovers()

		humanoid.WalkSpeed = module.previousHumanoidWalkSpeed or humanoid.WalkSpeed 

		ResetClientActions()

	end

end

return module