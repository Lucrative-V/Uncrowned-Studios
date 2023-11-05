local RunService = game:GetService('RunService')

local module = {}

if RunService:IsClient() then
	return module
end

function GetPlayerDataCache(player)
		
	if not player or module[player] then 
		return player and module[player]
	end
	
	module[player] = {
		
		User = player;
		Connections = {};
		RawActionInputs = {};
		ActiveMoves = {};
		Cooldowns = {};
		Repository = module.Repository;
		
	}
		
	table.sort(module.ToolData.Abilities, function(a, b)
		return #a.ActionInputs or 0 > #b.ActionInputs or 0
	end)
	
	module[player]['Connections']['ActionInputValidation'] = RunService.Heartbeat:Connect(function(dt)
				
		if module.ToolData then 
			
			for ability, data in pairs(module.ToolData.Abilities) do 
								
				if not data.ActionInputs then
					continue
				end
				
				local validActionInputs = 0
				local totalActionInputs = data.ActionInputs and #data.ActionInputs > 0 and #data.ActionInputs or 0
				
				for _, input in pairs(data.ActionInputs) do 
					
					if module[player].RawActionInputs[input] then 
						validActionInputs += 1
					end
					
				end
				
				if totalActionInputs == validActionInputs and totalActionInputs ~= 0 then 
					
					if data and data.ExecuteAbility_Server and not module[player].ActiveMoves[ability] and not module[player].Cooldowns[ability] then 
						data:ExecuteAbility_Server(module[player])
						return
					end
										
				end
				
			end
			
		end
		
		
	end)
	
	return module[player]
	
end

function DataHandler(player, action, state, ...)
		
	local playerDataCache = GetPlayerDataCache(player)
	
	if not playerDataCache or not module.ToolData  then
		return
	end
	
	if action == 'Reset' then 
		playerDataCache.RawActionInputs = {}
		return
	end
	
	playerDataCache.RawActionInputs = playerDataCache.RawActionInputs or {}
	playerDataCache.RawActionInputs[action] = state
	
end

function Start()
	
	if not module.NetworkManager then
		return
	end
	
	module.NetworkManager:BindEvents({
		ToolInputData = DataHandler;
	})
		
end

function module.Initialize(modules)

	if not modules or typeof(modules) ~= 'table' then
		return 
	end

	module.NetworkManager = modules.NetworkManager
	module.ToolData = modules.ToolData
	module.Repository = modules
	
	Start()
	
end

return module
