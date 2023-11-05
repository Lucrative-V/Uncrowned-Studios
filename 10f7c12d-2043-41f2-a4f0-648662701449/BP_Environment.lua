local RunService = game:GetService('RunService')
local CollectionService = game:GetService('CollectionService')

local module = {}
module._index = module

local function HasTag(instance, tag)
    if instance and typeof(instance) == 'Instance' and tag and typeof(tag) == 'string' then
        return CollectionService:HasTag(instance, tag)
    end
end 

function module.new(properties)
    if not properties or type(properties) ~= 'table' then return end 

    assert(properties.Object and properties.Object:IsA('BasePart'), 'Require A BasePart.')

    local self = setmetatable({}, module)

    self._Connections = {}
    self._objectCFrameStorage = {}

    self._Running = false
    self._Object = properties.Object
    self._Offset = properties.Offset or CFrame.new()
    self._IgnoreList = properties.IgnoreContainer or {properties.Object}

    return self 
end 

function module:Start()

    table.insert(self._Connections, RunService.Heartbeat:Connect(function(_)
    
        if not self._Object or self._Running then
            return 
        end

        self._Running = true
    
        local rayOrigin =  self._Object.CFrame.Position
        local rayDirection =  self._Object.CFrame.Position +  self._Object.CFrame.UpVector * -100
    
        local ignoreList = {self._IgnoreList}
    
        local rayCastParameters = RaycastParams.new()
        rayCastParameters.FilterDescendantsInstances = ignoreList
        rayCastParameters.FilterType = Enum.RaycastFilterType.Exclude
    
        local rayCastResult = workspace:RayCast(rayOrigin, rayDirection, rayCastParameters)
    
        if rayCastResult then 
    
            local instance = rayCastResult.Instance
    
            if HasTag(instance, 'CharacterRelativeObject') then 
                self._objectCFrameStorage[instance] = if self._objectCFrameStorage[instance] == nil then instance.CFrame else self._objectCFrameStorage[instance]

                local relativeCFrame = self._objectCFrameStorage[instance] and (instance.CFrame * self._objectCFrameStorage[instance]:Inverse())
                self._objectCFrameStorage[instance] = instance.CFrame
                self._Object.CFrame = relativeCFrame * self._Object.CFrame
            end 
    
        end 
    
    end))

end 

function module:Stop()

    if not self._Running then
        return 
    end 

    self._Running = false 

    for _, connection in pairs (self._Connections) do
        connection:Disconnect()
    end

end 

return module 