local module = {}

local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')

local function hasProperty(object, prop)
	local data 

	local success = pcall(function() 
		data = object[prop] 
	end)

	return success and data
end

local function Destroyed(x)
	if x.Parent then return false end
	local _, result = pcall(function() x.Parent = x end)
	return result:match("locked") and true or false
end

local function resizeModel(model, a)
	local base = model.PrimaryPart and model.PrimaryPart.Position
	if not base then
		return
	end
	local size
	for _, part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Position = base:Lerp(part.Position, a)
			part.Size *= a
			size = part.Size
		end
	end
	return a,size
end

local function tweenModelSize(model, duration, increment, easingStyle, easingDirection)
	local s = increment - 1
	local i = 0
	local oldAlpha = 0
	while i < 1  and not Destroyed(model) do
		local dt = RunService.Heartbeat:Wait()
		i = math.min(i + dt/duration, 1)
		local alpha = TweenService:GetValue(i, easingStyle, easingDirection)
		resizeModel(model, (alpha*s + 1)/(oldAlpha*s + 1))
		oldAlpha = alpha
	end
end

local function setAllSurfaces(part, surfaceType)
	part.TopSurface = surfaceType
	part.BottomSurface = surfaceType
	part.LeftSurface = surfaceType
	part.RightSurface = surfaceType
	part.FrontSurface = surfaceType
	part.BackSurface = surfaceType
end

local function defaultProperties(object)
	object.Massless = true
	object.CastShadow = false
	object.Anchored = true
	object.CanCollide = false
	object.CanQuery = false
	object.CanTouch = false
	setAllSurfaces(object, Enum.SurfaceType.Smooth)
end

local function WeldConstraintObjects(x,y)
	if not x or not y then
		return 
	end
	local constraint = Instance.new('WeldConstraint')
	constraint.Part0 = x
	constraint.Part1 = y
	constraint.Parent = x
end

local function weldModel(model)
	local PrimaryPart = model.PrimaryPart
	local Parts = model:GetDescendants()

	for i = 1, #Parts do
		if Parts[i]:IsA("BasePart") then

			local Weld = Instance.new("WeldConstraint")
			Weld.Name = "ModelWeld"
			Weld.Part0 = PrimaryPart
			Weld.Part1 = Parts[i]
			Weld.Parent = PrimaryPart

		end
	end
end

local function quickPrep(object)

	if object:IsA('Model') then
		weldModel(object)
		for _, asset in pairs(object:GetDescendants()) do

			if not asset:IsA('BasePart') then
				continue
			end

			defaultProperties(asset)
		end
	else
		defaultProperties(object)
	end

end

local function UpdatePropertyDictionary(object, proxy, property)

	proxy = proxy or {}

	if not property or typeof(property) ~= 'string' then
		return 
	end

	if object:IsA('Model') then
		for _, basepart in pairs(object:GetDescendants()) do

			if not basepart:IsA('BasePart') then
				continue
			end

			UpdatePropertyDictionary(basepart, proxy, property)

		end
	elseif object:IsA('BasePart') and hasProperty(object, property) then

		proxy[object] = proxy[object] or {}
		proxy[object][property] = object[property]

	end

end

local function SetBasePartsToCollectionGroup(object, collisiongroup)
	local CollectionService = game:FindService('CollectionService') or game:GetService('CollectionService')

	if object:IsA('Model') then
		for _, asset in pairs(object:GetDescendants()) do

			if not asset:IsA('BasePart') then
				continue
			end

			CollectionService:AddTag(object, collisiongroup)
		end
	else
		CollectionService:AddTag(object, collisiongroup)
	end
end

function module.AirBlastWithProxy(options)
	
	if not options or typeof(options) ~= 'table' or not options.Character then
		return 
	end
	
	local character = options.Character
	local primaryPart = character and character.PrimaryPart
	local humanoid = character and character:FindFirstChild('Humanoid')

	local proxyObject = if options.ProxyObject and typeof(options.ProxyObject) == 'Instance' and options.ProxyObject:IsA('BasePart') then options.ProxyObject else nil 

	if not primaryPart or not humanoid or not proxyObject then
		return 
	end
	
	local Effects = workspace:FindFirstChild(character.Name..'s Effects') or Instance.new('Folder')
	Effects.Name = character.Name..'s Effects'
	Effects.Parent = workspace

	local Assets = script:FindFirstChild('Assets')
	
	local BlastReference = Assets:FindFirstChild('Blast')
	
	if not BlastReference then
		return 
	end
	
	local BlastClone = BlastReference:Clone()
	local Blast_CFrame_Offset = options.Offset or CFrame.new()
	local Blast_Duration = options.Duration or 1
	lcoal Blast_Initial_Properties = {}

	do -- Initialize 
		
		WeldConstraintObjects(BlastClone.PrimaryPart, proxyObject)
		BlastClone:PivotTo(proxyObject.CFrame * Blast_CFrame_Offset)
		BlastClone.Parent = Effects


		task.delay(Blast_Duration * 2, function()
			BlastClone:Destroy()
		end)

		UpdatePropertyDictionary(
			BlastClone,
			Blast_Initial_Properties,
			'Transparency'
		)

		UpdatePropertyDictionary(
			BlastClone,
			Blast_Initial_Properties,
			'Size'
		)
		
	end
	
	do -- Inside Blast
		
		local InsideBlast = BlastClone:FindFirstChild('Inverted')

		if not InsideBlast then
			return 
		end

		InsideBlast.Size = Vector3.zero
		InsideBlast.Transparency = 1 

		task.spawn(function()

			local begin = tick()
			local rate = 500

			for _ = 1, 1e99, 1/60 do 
				if  Destroyed(BlastClone) then
					break
				end

				local since = tick() - begin
				local degrees = since*rate
				local wrapped = degrees%360 
				local radians = math.rad(wrapped)
				local rotation = CFrame.Angles(0, radians, 0)

				local destination = InsideBlast.CFrame:Lerp(InsideBlast.CFrame * rotation, .5)

				AirSwirl:PivotTo(destination)
				RunService.RenderStepped:Wait()
			end
		end)
		
	end
	
	do -- Outside Blast Shell

		local OutsideBlast = BlastClone:FindFirstChild('Blast')

		if not OutsideBlast then
			return 
		end
		
	end
	
	do -- Shockwind 1 
		
		local Shockwind = BlastClone:FindFirstchild('Shock_1')

		if not Shockwind then 
			return
		end 

	end
	
	do -- Shockwind 2 

		local Shockwind = BlastClone:FindFirstchild('Shock_2')

		if not Shockwind then 
			return
		end 

	end
	
	do -- Shockwind 3 

		local Shockwind = BlastClone:FindFirstchild('Shock_4')

		if not Shockwind then 
			return
		end 

	end
	
	do -- Shockwind 4

		local Shockwind = BlastClone:FindFirstchild('Shock_4')

		if not Shockwind then 
			return
		end 

	end
	
	do -- Shockwind 5

		local Shockwind = BlastClone:FindFirstchild('Shock_5')

		if not Shockwind then 
			return
		end 

	end
	
	do -- Shockwave 1

		local Shockwave = BlastClone:FindFirstchild('Shockwave_1')

		if not Shockwave then 
			return
		end 

	end
	
	do -- Shockwave 2 

		local Shockwave = BlastClone:FindFirstchild('Shockwave_1')

		if not Shockwave then 
			return
		end 

	end
	
end

function module.AirBlastOnHit()
	
end

return module
