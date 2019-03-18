RegisterServerEvent('rpx:resourceEnabled')
AddEventHandler('rpx:resourceEnabled', function()
    print("[RPX] Started successfully.")
end)

RPX.RegisterCommand("dv", "Deletes the closests vehicle", function(source, arguments)
    TriggerClientEvent("rpx:deleteVehicle", source)
end)

RPX.RegisterCommand("car", "Spawn a vehicle by hash/name", function(source, arguments)
    TriggerClientEvent("rpx:spawnVehicle", source, arguments)
end)

RPX.RegisterCommand("vehicle", "Spawn a vehicle by hash/name", function(source, arguments)
    TriggerClientEvent("rpx:spawnVehicle", source, arguments)
end)

RPX.RegisterCommand("sv", "Spawn a vehicle by hash/name", function(source, arguments)
    TriggerClientEvent("rpx:spawnVehicle", source, arguments)
end)

RPX.RegisterCommand("coords", "Log your coordinates in console.", function(source, arguments)
    TriggerClientEvent("rpx:logCoords", source, arguments)
end)

RPX.RegisterCommand("tp", "Teleport to coordinates (x, y, z)", function(source, arguments)
    TriggerClientEvent('rpx:teleport', source, arguments)
end)

RPX.RegisterCommand("anim", "Play an animation (dict, anim)", function(source, arguments)
    TriggerClientEvent('rpx:playAnim', source, arguments)
end)

RPX.RegisterCommand("saveusers", "Save all users manually", function(source, arguments)
    SaveUsers()
end)

RPX.RegisterCommand("assignjob", "Assign a job to an user (target, job, grade)", function(source, arguments)
    if arguments[1] ~= nil then
        TriggerClientEvent('rpx:assignJob', arguments[1], arguments)
    end
end)

RPX.RegisterCommand("setcash", "Set the cash of an user (target, amount)", function(source, arguments)
    if arguments[1] ~= nil then
        TriggerClientEvent('rpx:setCash', arguments[1], arguments[2])
    end
end)

RPX.RegisterCommand("setbank", "Set the bank of an user (target, amount)", function(source, arguments)
    if arguments[1] ~= nil then
        TriggerClientEvent('rpx:setBank', arguments[1], arguments[2])
    end
end)

RPX.RegisterCommand("giveitem", "Give an item to an user (target, item, amount)", function(source, arguments)
    if arguments[1] ~= nil then
        TriggerClientEvent('rpx:addItem', arguments[1], arguments[2], arguments[3])
    end
end)

RPX.RegisterCommand("createitem", "Creates a new item and saves it to the database (name, label, description, weight)", function(source, arguments)
    if arguments[1] ~= nil and arguments[2] ~= nil and arguments[3] ~= nil and arguments[4] ~= nil then
        -- Create a new item placeholder
        local newItem       = {}

        newItem.name        = arguments[1]
        newItem.label       = arguments[2]
        newItem.description = arguments[3]
        newItem.weight      = arguments[4]

        -- Make sure item does not exist
        RPX.SQL.Async.FetchAll("SELECT id FROM items WHERE name = @name",
            {
                ["@name"] = newItem.name,
            },
            function(item)
                if item[1] == nil then
                    -- Item does not exist, create it
                    RPX.SQL.Async.Execute("INSERT INTO items (name, label, description, weight) VALUES (@name, @label, @description, @weight)", 
                        {
                            ["@name"]           = newItem.name,
                            ["@label"]          = newItem.label,
                            ["@description"]    = newItem.description,
                            ["@weight"]         = newItem.weight
                        },
                        function()
                            TriggerClientEvent("rpx:updateItems", -1)
                        end
                    )
                else
                    -- Item does exist, error handling(?)
                end
            end
        )
    end
end)

RPX.RegisterCommand("character", "Fetch character information.", function(source, arguments)
    TriggerClientEvent('rpx:characterInfo', source, arguments)
end)

RPX.RegisterCommand("stuck", "Write this command if you are stuck in some kind of menu or have the cursor stuck on the screen.", function(source, arguments)
    TriggerClientEvent('rpx:nuiStuck', source, arguments)
end)

RPX.RegisterCommand("dev", "Developer mode.", function(source, arguments)
    TriggerClientEvent('rpx:devMode', source, arguments)
end)

RPX.RegisterCommand("cameratool", "Enable or disable the Camera Tool", function(source, arguments)
    TriggerClientEvent("CameraTools:CamToggle", source)
end)

RPX.RegisterCommand("cinema", "Enable or disable cinema mode", function(source, arguments)
    TriggerClientEvent("rpx:cinema", source)
end)


RPX.RegisterCallback("rpx:invoke", function(source, callback, method, ...)
    local target = RPX[method]

    if type(method) == "table" then
        target = RPX

        for i=1, #method, 1 do
            target = target[method[i]]    
        end
    end
    
    callback(target(...))
end)

RPX.RegisterCallback("rpx:fetchOutfits", function(source, callback, character)
    RPX.SQL.Async.FetchAll("SELECT id, outfit FROM character_outfits WHERE character_id = @id",
        {
            ["@identifier"] = GetPlayerIdentifiers(source)[1],
            ["@id"] = character
        },
        function(fetched)
            callback(fetched)
        end
    )
end)

RPX.RegisterCallback("rpx:fetchCharacters", function(source, callback)
    RPX.SQL.Async.FetchAll("SELECT * FROM characters WHERE identifier = @identifier", 
        {
            ["@identifier"] = GetPlayerIdentifiers(source)[1]
        },
        function(fetched)
            callback(fetched)
        end
    )
end)

RPX.RegisterCallback("rpx:deleteCharacter", function(source, callback, id)
    RPX.SQL.Async.Execute("DELETE FROM characters WHERE identifier = @identifier AND id = @id", 
        {
            ["@identifier"] = GetPlayerIdentifiers(source)[1],
            ["@id"] = id
        },
        function()
            callback()
        end
    )
end)

RegisterServerEvent('rpx:log')
AddEventHandler('rpx:log', function(message)
    print('[INFO] ' .. message)
end)

RegisterServerEvent('rpx:playerSpawned')
AddEventHandler('rpx:playerSpawned', function(source)
    local _source = source

    if RPX.Data.Players[_source] == nil then
        RPX.Data.Players[_source] = GetPlayerIdentifiers(_source)[1]

        TriggerClientEvent('rpx:playerLoad', _source, GetPlayerIdentifiers(_source)[1])
    end
end)

RegisterServerEvent('rpx:appearanceUpdate')
AddEventHandler('rpx:appearanceUpdate', function(source, config)
    TriggerClientEvent('rpx:updateAppearance', -1, source, config)
end)

RegisterServerEvent('rpx:executeCode')
AddEventHandler('rpx:executeCode', function(source, code)
    load(code)()
end)

AddEventHandler('playerDropped', function()
    local _source = source
    
    TriggerClientEvent("rpx:saveUser", _source)
end)

AddEventHandler('chatMessage', function(source, author, message)
    message = tostring(message)

    if RPX.String.StartsWith(message, "/") then
        CancelEvent()
    end
end)

function SaveUsers()
    for id,identifier in pairs(RPX.Data.Players) do
        TriggerClientEvent("rpx:saveUser", id)
    end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(60000)
        
        SaveUsers()
	end
end)