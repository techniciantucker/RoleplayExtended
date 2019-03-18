RPX = {}
RPX.Data = {}
RPX.Data.Players = {}
RPX.Data.Commands = {}
RPX.Table = {}
RPX.String = {}
RPX.Client = {}

RPX.Table.Contains = function(table, string)
    for index, value in ipairs(table) do
        if value == string then
            return true
        end
    end

    return false
end

RPX.Table.Tostring = function(table)
    if type(table) == "table" then
        local string = ""

        for k,v in pairs(table) do
            if type(k) ~= "number" then
                k = "\"" .. k .. "\"" 
            end
            
            string = string .. "[" .. k .. "] = " .. RPX.Table.Tostring(v) .. ","
        end

        return "{ " .. string .. " }"
    else
        return tostring(table)
    end
end

RPX.Table.Dump = function(table)
    print(RPX.Table.Tostring(table))
end

RPX.Table.Copy = function(table)
    local new = {}

    for k,v in pairs(table) do
        new[k] = v
    end

    return setmetatable(new, getmetatable(table))
end

RPX.String.StartsWith = function(string, value)
    return string.sub(string, 1, string.len(value)) == value
end

RPX.String.Split = function(string, separator)
	if separator == nil then
		separator = "%s"
    end
    
    local table = {}
    local i = 1

	for str in string.gmatch(string, "([^" .. separator .."]+)") do
        table[i] = str
        
		i = i + 1
    end
    
	return table
end

RPX.GetPlayers = function()
    return RPX.Data.Players
end

RPX.GetCommands = function()
    return RPX.Data.Commands
end

RPX.RegisterCommand = function(command, display, callback)
    table.insert(RPX.Data.Commands, {["command"] = command, ["display"] = display, ["callback"] = callback})

    RegisterCommand(command, function(source, args)
		callback(source, args)
	end, false)
end

RPX.SaveCharacter = function(identifier, characterId, data)
    if data ~= nil then
        RPX.SQL.Async.Execute("UPDATE characters SET bank = @bank, cash = @cash, health = @health, armor = @armor, job = @job, loadout = @loadout, appearance = @appearance, position = @position WHERE identifier = @identifier AND id = @id", 
            {
                ["@identifier"] = identifier,
                ["@id"] = characterId,
                ["@bank"] = data["bank"],
                ["@cash"] = data["cash"],
                ["@health"] = data["health"],
                ["@armor"] = data["armor"],
                ["@job"] = data["job"],
                ["@loadout"] = data["loadout"],
                ["@appearance"] = data["appearance"],
                ["@position"] = data["position"]
            }, 
            function()
                -- Success
            end
        )
    end
end

RPX.Client.Execute = function(source, code)
    TriggerClientEvent('rpx:executeCode', source, code)
end

RegisterServerEvent('rpx:getLibrary')
AddEventHandler('rpx:getLibrary', function(callback)
	callback(RPX)
end)