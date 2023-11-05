local RunService = game:GetService('RunService')

local IsClient = RunService:IsClient()

if not IsClient then
	return {}
end

local UserInputService = game:GetService('UserInputService')
local Players = game:GetService('Players')

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local character 

local Tool
local toolEquipped = false
local Active = false

local module = {}

function module.Initialize(modules)

	if not modules or typeof(modules) ~= 'table' then
		return 
	end

	module.Repository = modules
	module.ToolData = modules.ToolData
	module.MouseModule = modules.MouseModule
	module.Network = modules.NetworkManager
	module.Utilize = module.Utilities
	module.RealMouse = module.MouseModule and module.MouseModule.new()

	Start()
end

function Activated()

	Active = true 

	local rayCastResult = module.RealMouse:CastRay()
	local mouseTarget = rayCastResult and rayCastResult.Instance or Mouse.Target
	local mouseHit = rayCastResult and rayCastResult.Position and CFrame.new(rayCastResult.Position.X, rayCastResult.Position.Y, rayCastResult.Position.Z) or Mouse.Hit

	module.Network:FireServer('ToolInputData','Activated', true)

end

function Deactivated()

	Active = false

	local rayCastResult = module.RealMouse:CastRay()
	local mouseTarget = rayCastResult and rayCastResult.Instance or Mouse.Target
	local mouseHit = rayCastResult and rayCastResult.Position and CFrame.new(rayCastResult.Position.X, rayCastResult.Position.Y, rayCastResult.Position.Z) or Mouse.Hit

	module.Network:FireServer('ToolInputData','Activated', false)

end

function Equipped()

	toolEquipped = true

	module.Network:FireServer('ToolInputData','Equipped', true)

end

function Unequipped() 

	toolEquipped = false
	
	Deactivated()
	
	module.Network:FireServer('ToolInputData', 'Reset')

	module.Network:FireServer('ToolInputData', 'Equipped', false)

end

function SendInputData(action, state)

	if not action or not module.Network or state == nil then 
		return 
	end

	module.Network:FireServer('ToolInputData', action, state)

end

function DataHandler(options)

	if module.Repository and options and typeof(options) == 'table' then 

		if options.Ability and module.Repository[options.Ability] and module.Repository[options.Ability].ExecuteAbility_Client then 

			options.Player = LocalPlayer
			module.Repository[options.Ability]:ExecuteAbility_Client(options)

		end

	end

end

function Start()

	if not module.ToolData or not module.RealMouse or not module.Network then 
		return 
	end

	module.Network:BindEvents({
		ToolInputData = DataHandler;
	})

	module.Connections = module.Connections or {}

	local function CharacterAdded(character)

		module.RealMouse:SetTargetFilter(character)

		Tool = script:FindFirstAncestorWhichIsA('Tool')

		if not Tool then
			return
		end

		module.Connections['ToolActivated'] = Tool.Activated:Connect(Activated)

		module.Connections['ToolDeactivated'] = Tool.Deactivated:Connect(Deactivated)

		module.Connections['ToolEquipped'] = Tool.Equipped:Connect(Equipped)

		module.Connections['ToolUnequipped'] = Tool.Unequipped:Connect(Unequipped)

	end

	local function CharacterRemoved(character)

		if not module.Connections then
			return 
		end

		for _, connection in pairs(module.Connections) do

			if typeof(connection) == 'RBXScriptConnection' then
				connection:Disconnect()
			end

		end

		character = nil
		Tool = nil
	end

	if LocalPlayer.Character then 
		CharacterAdded(LocalPlayer.Character)
	end

	LocalPlayer.CharacterAdded:Connect(CharacterAdded)

end

UserInputService.InputBegan:Connect(function(input, gameProcessed)

	if gameProcessed or not toolEquipped then
		return 
	end

	local inputObject = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType ~= Enum.UserInputType.None and input.UserInputType

	SendInputData(inputObject.Name, true)

end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)

	if gameProcessed or not toolEquipped then
		return 
	end

	local inputObject = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType ~= Enum.UserInputType.None and input.UserInputType

	SendInputData(inputObject.Name, false)

end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)

	if gameProcessed or not toolEquipped then
		return 
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement and module.RealMouse then

		local rayCastResult = module.RealMouse:CastRay()
		local mouseTarget = rayCastResult and rayCastResult.Instance or Mouse.Target
		local mouseHit = rayCastResult and rayCastResult.Position and CFrame.new(rayCastResult.Position.X, rayCastResult.Position.Y, rayCastResult.Position.Z) or Mouse.Hit

		SendInputData('MouseMovement', Mouse.Hit)

	end

end)


return module