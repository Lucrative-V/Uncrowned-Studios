local RunService = game:GetService('RunService')

local MAX_HIGHLIGHT_GROUPS = 31 -- Limited number of rendering highlight instances within a given game imposed by ROBLOX as of May 2022

local module = {}
module.__index = module

function module.new()

	local self = setmetatable({}, module)
	self._Running = false
	self.HighlightGroups = {}
	self.HightlightObjects = {}

	self:Start()

	return self 
end

function module:CreateHighlightGroup(options)

	local function hasProperty(object, prop)
		local data 

		local success = pcall(function() 
			data = object[prop] 
		end)

		return success and data
	end

	if not options or typeof(options) ~= 'table' then 
		return 
	end

	local previousID =  #self.HighlightGroups

    if previousID > MAX_HIGHLIGHT_GROUPS then 
        warn('MAX LIMIT FOR HIGHLIGHTGROUPS EXCEEDED; NEED TO DELETE A GROUP BEFORE PROCEEDING')
    end 

	local currentID = previousID + 1

	if self.HighlightGroups[currentID] then
		return 
	end

	self.HighlightGroups[currentID] = {}

	local hightlightGroup = Instance.new('Model')
	hightlightGroup.Name = 'HighlightGroup'

	local hightlightObject = Instance.new('Highlight')

	self.HighlightGroups[currentID].HighlightModel = hightlightGroup
	self.HighlightGroups[currentID].HighlightObject = hightlightObject
	self.HighlightGroups[currentID].Properties = {}

	for property, value in pairs (options) do 
		if hasProperty(hightlightObject, property) then 
			hightlightObject[property] = value
			self.HighlightGroups[currentID].Properties[currentID][property] = value
		end
	end

	hightlightObject.Parent = hightlightGroup
	hightlightGroup.Parent = workspace

	return currentID
end

function module:DestroyHighlightGroup(ID)

	local highlightGroup = ID and self.HighlightGroups and self.HighlightGroups[ID]

	if not highlightGroup then 
		return
	end

	for index, highlightGroupData in pairs (highlightGroup) do 

		for _, instance in pairs(highlightGroupData) do

			if instance and typeof(instance) == 'Instance' then 

				instance:Destroy()

			end

		end

	end

    table.remove(self.HighlightGroups, ID)

end

function module:FindHightlightGroup(options)

	if not options or typeof(options) ~= 'table' then 
		return 
	end

	for ID, highlightGroupData in pairs(self.HighlightGroups) do 

		if highlightGroupData and typeof(highlightGroupData) == 'table' and highlightGroupData.Properties and highlightGroupData.ID then 

			for _, property in pairs(highlightGroupData.Properties) do 

				if not options[property] then 
					return false 
				end

			end

			return ID

		end

	end

	return false

end

function module:AssignHighlightGroupID(object, ID)

	if not object or typeof(object) ~= 'Instance' then
		return
	end

	local highlightGroup = ID and self.HighlightGroups and self.HighlightGroups[ID]

	if not highlightGroup or not highlightGroup.HighlightModel or typeof(highlightGroup.HighlightModel) ~= 'Instance' or not highlightGroup.HighlightModel:IsA('Model') then 
		return
	end

	object.Parent = highlightGroup.HighlightModel

end

function module:Start()

	if self._Running then 
		return 
	end

	self._Running = true

	local function InitializeHightlightObjects(object)
		if object and typeof(object) == 'Instance' and object:IsA('Highlight') then 

			local function NewHighlightObjectSettings()
                object.Enabled = false
                object.Parent = nil
            end 

			self.HightlightObjects = self.HightlightObjects or {}
			self.HightlightObjects[object] = {}
            self.HightlightObjects[object].DefaultParent = object.Parent
            self.HightlightObjects[object].DefaultEnabledSetting = object.Enabled 
			self.HightlightObjects[object].ChangedEvent = object.Changed:Connect(function()
				NewHighlightObjectSettings()
			end)

            NewHighlightObjectSettings()

		end
	end

	for _, object in pairs (game:GetDescendants()) do 
		InitializeHightlightObjects(object)
	end

	self.MainConnection = game.DescendantAdded:Connect(function(object)
		InitializeHightlightObjects(object)
	end)

end

function module:Stop()

	if not self._Running then 
		return 
	end

	self._Running = false 

	if self.MainConnection and typeof(self.MainConnection) == 'RBXScriptConnection' then 
		self.MainConnection:Disconnect()
	end

	if self.HightlightObjects then 

		for hightlightObject, data in pairs(self.HightlightObjects) do 

			for _, connection in pairs(data) do 
				if connection and typeof(connection) == 'RBXScriptConnection' then 
					connection:Disconnect()
				end
			end

            if data.DefaultParent then 
                hightlightObject.Parent = data.DefaultParent
            end 

            if data.DefaultEnabledSetting then 
                hightlightObject.Enabled = data.DefaultEnabledSetting
            end 

			self.HightlightObjects[hightlightObject] = nil
		end

	end

end

return module.new()