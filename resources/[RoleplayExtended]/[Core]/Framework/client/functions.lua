RPX = {}
RPX.Data = {}
RPX.Data.Cam = nil
RPX.Data.HUD = true
RPX.Data.NotificationQueue = {}
RPX.Data.IsDisplayingNotification = false
RPX.Table = {}
RPX.String = {}
RPX.IsLoaded = false
RPX.Server = {}
RPX.Inventory = {}
RPX.Items = {}
RPX.Keys = {
        ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
        ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
        ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
        ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
        ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
        ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
        ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
        ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
        ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

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

RPX.String.EndsWith = function(string, value)
    return value == '' or string.sub(string, -string.len(value)) == value
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

RPX.GetId = function()
    return GetPlayerServerId(PlayerId())
end

RPX.GetIdentifier = function()
    return RPX.Data.Identifier
end

RPX.SetIdentifier = function(identifier)
    RPX.Data.Identifier = identifier
end

RPX.DeleteVehicle = function(vehicle)
    SetEntityAsMissionEntity(vehicle, false, true)
    DeleteVehicle(vehicle)
end

RPX.SpawnVehicle = function(modelName, coords, heading, callback)
    local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))
  
    Citizen.CreateThread(function()
        RequestModel(model)
  
        while not HasModelLoaded(model) do
            Citizen.Wait(0)
        end
  
        local vehicle = CreateVehicle(model, coords["x"], coords["y"], coords["z"], heading, true, false)
        local id = NetworkGetNetworkIdFromEntity(vehicle)
  
        SetNetworkIdCanMigrate(id, true)
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetModelAsNoLongerNeeded(model)
  
        RequestCollisionAtCoord(coords["x"], coords["y"], coords["z"])
  
        while not HasCollisionLoadedAroundEntity(vehicle) do
            RequestCollisionAtCoord(coords["x"], coords["y"], coords["z"])
            
            Citizen.Wait(0)
        end
  
        if callback ~= nil then
            callback(vehicle)
        end
    end)
end
  
RPX.SpawnLocalVehicle = function(modelName, coords, heading, callback)
    local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))
  
    Citizen.CreateThread(function()
        RequestModel(model)
  
        while not HasModelLoaded(model) do
            Citizen.Wait(0)
        end
  
        local vehicle = CreateVehicle(model, coords["x"], coords["y"], coords["z"], heading, false, false)

        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetModelAsNoLongerNeeded(model)
  
        RequestCollisionAtCoord(coords["x"], coords["y"], coords["z"])
  
        while not HasCollisionLoadedAroundEntity(vehicle) do
            RequestCollisionAtCoord(coords["x"], coords["y"], coords["z"])
            
            Citizen.Wait(0)
        end
  
        if callback ~= nil then
            callback(vehicle)
        end
    end)
end

RPX.ShowNotification = function(title, message, duration)
    if not title then title = "Title" end
    if not message then message = "Message" end
    if not duration then duration = 3000 end
    
    table.insert(RPX.Data.NotificationQueue, {["title"] = title, ["message"] = message, ["duration"] = duration})

    RPX.CheckNotificationQueue()
end

RPX.ShowNativeNotification = function(message)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(0, 1)
end

RPX.CheckNotificationQueue = function()
    if not IsDisplayingNotification then
        local notification = RPX.Data.NotificationQueue[1]

        if notification ~= nil then
            IsDisplayingNotification = true

            SendNUIMessage({
                ["action"] = "notification",
                ["title"] = notification["title"],
                ["message"] = notification["message"],
                ["duration"] = notification["duration"]
            })
        end
    end
end

RPX.NotificationEnd = function()
    IsDisplayingNotification = false

    RPX.CheckNotificationQueue()
end

RPX.PlayAnimation = function(ped, dict, anim, settings)
	if dict ~= nil then
		Citizen.CreateThread(function()
			RequestAnimDict(dict)

			while not HasAnimDictLoaded(dict) do
	        	Citizen.Wait(100)
	      	end

	      	if settings == nil then
		      	TaskPlayAnim(ped, dict, anim, 1.0, -1.0, 1.0, 0, 0, 0, 0, 0)
		    else 
		    	local speed = 1.0
		    	local speedMultiplier = -1.0
		    	local duration = 1.0
		    	local flag = 0
		    	local playbackRate = 0

		    	if settings["speed"] ~= nil then
		    		speed = settings["speed"]
		    	end

		    	if settings["speedMultiplier"] ~= nil then
		    		speedMultiplier = settings["speedMultiplier"]
		    	end

		    	if settings["duration"] ~= nil then
		    		duration = settings["duration"]
		    	end

		    	if settings["flag"] ~= nil then
		    		flag = settings["flag"]
		    	end

		    	if settings["playbackRate"] ~= nil then
		    		playbackRate = settings["playbackRate"]
		    	end

		      	TaskPlayAnim(ped, dict, anim, speed, speedMultiplier, duration, flag, playbackRate, 0, 0, 0)
            end
            
            RemoveAnimDict(dict)
		end)
	else
		TaskStartScenarioInPlace(ped, anim, 0, true)
	end
end

RPX.GetPlayers = function()
    local players = {}
  
    for i=0, 32, 1 do
        local ped = GetPlayerPed(i)
  
        if DoesEntityExist(ped) then
            table.insert(players, i)
        end
    end
  
    return players
end

RPX.AttachCam = function(coords, rotations)
    if RPX.Data.Cam ~= nil then
		RPX.DetachCam()
	end

	local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
					
	SetCamCoord(cam, coords["x"], coords["y"], coords["z"])
	SetCamRot(cam, rotations["x"], rotations["y"], rotations["z"])
	SetCamActive(cam, true)
	
	RenderScriptCams(true, false, 0, true, true)
	
    SetCamCoord(cam, coords["x"], coords["y"], coords["z"])
    
    RPX.Data.Cam = cam
end

RPX.GetInventory = function()
    return RPX.Inventory
end

RPX.GetItem = function(item)
    if RPX.Inventory[item] == nil then
        RPX.Inventory = {["name"] = name, ["amount"] = 0, ["data"] = {}, ["label"] = RPX.Items[item].label, ["id"] = RPX.Items[item].id, ["weight"] = 0}
    end

    return RPX.Inventory[item]
end

RPX.LoadItems = function()
    RPX.SQL.Async.FetchAll("SELECT * FROM items WHERE 1",
        {},
        function(items)
            for i = 1, #items do
                RPX.Items[items[i].name] = items[i]
            end

            if #items == 0 then
                print("NO ITEMS IN DATABASE :(")
            end
        end
    )
end

RPX.AddItem = function(item, amount, data)
    if RPX.Items[item] ~= nil then
        if RPX.Inventory[item] ~= nil then
            RPX.Inventory[item].amount = RPX.Inventory[item].amount + amount
            RPX.Inventory[item].weight = RPX.Items[item].weight * RPX.Inventory[item].amount
        else
            RPX.Inventory[item] = {["id"] = RPX.Items[item].id, ["label"] = RPX.Items[item].label, ["amount"] = amount, ["data"] = data, ["weight"] = RPX.Items[item].weight * amount}
        end
        print(json.encode(RPX.Inventory))
        print("ITEM ADDED")
    else
        print("ITEM DOES NOT EXIST")
    end
end

RPX.RemoveItem = function(item, count)
    local fetchedItem = RPX.GetItem(item)["amount"]

    if fetchedItem > count then
        fetchedItem["amount"] = fetchedItem["amount"] - count
    else
        RPX.Inventory[item] = nil
    end
end

RPX.DrawWorldText = function(text, x, y, z, scale, red, green, blue, alpha)
    if not scale then scale = 1.0 end
    if not red then red = 255 end
    if not green then green = 255 end
    if not blue then blue = 255 end
    if not alpha then alpha = 255 end

    local visible,_x,_y = World3dToScreen2d(x, y, z)

    if visible then
        SetTextScale(scale, scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(red, green, blue, alpha)
        SetTextDropshadow(0, 0, 0, 0, 55)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
		ClearDrawOrigin()
    end
end

RPX.GetAllWeapons = function()
    return {
        ["WEAPON_GRENADELAUNCHER"] = {"COMPONENT_AT_SCOPE_SMALL", "COMPONENT_AT_AR_FLSH", "COMPONENT_AT_AR_AFGRIP"},
        ["WEAPON_GRENADELAUNCHER_SMOKE"] = {"COMPONENT_AT_SCOPE_SMALL", "COMPONENT_AT_AR_FLSH", "COMPONENT_AT_AR_AFGRIP"},
        ["WEAPON_HEAVYSNIPER"] = {"COMPONENT_AT_SCOPE_LARGE"}, 
        ["WEAPON_MARKSMANRIFLE"] = {"COMPONENT_MARKSMANRIFLE_CLIP_02", "COMPONENT_AT_AR_FLSH", "COMPONENT_AT_AR_SUPP", "COMPONENT_AT_AR_AFGRIP", "COMPONENT_MARKSMANRIFLE_VARMOD_LUXE"},
        ["WEAPON_SNIPERRIFLE"] = {"COMPONENT_AT_SCOPE_MAX", "COMPONENT_AT_AR_SUPP_02", "COMPONENT_SNIPERRIFLE_VARMOD_LUXE"},
        ["WEAPON_ASSAULTSHOTGUN"] = {"COMPONENT_ASSAULTSHOTGUN_CLIP_02", "COMPONENT_AT_AR_SUPP", "COMPONENT_AT_AR_AFGRIP", "COMPONENT_AT_AR_FLSH"},
        ["WEAPON_BULLPUPSHOTGUN"] = {"COMPONENT_BULLPUPRIFLE_CLIP_02", "COMPONENT_AT_AR_FLSH", "COMPONENT_AT_SCOPE_SMALL", "COMPONENT_AT_AR_SUPP", "COMPONENT_AT_AR_AFGRIP", "COMPONENT_BULLPUPRIFLE_VARMOD_LOW"},
        ["WEAPON_HEAVYSHOTGUN"] = {"COMPONENT_HEAVYSHOTGUN_CLIP_02", "COMPONENT_AT_AR_FLSH", "COMPONENT_AT_AR_SUPP_02", "COMPONENT_AT_AR_AFGRIP"},
        ["WEAPON_PUMPSHOTGUN"] = {"COMPONENT_AT_SR_SUPP", "COMPONENT_AT_AR_FLSH", "COMPONENT_PUMPSHOTGUN_VARMOD_LOWRIDER"},
        ["WEAPON_SAWNOFFSHOTGUN"] = {"COMPONENT_SAWNOFFSHOTGUN_VARMOD_LUXE"},
        ["WEAPON_ADVANCEDRIFLE"] = {"COMPONENT_ADVANCEDRIFLE_CLIP_02", "COMPONENT_AT_SCOPE_SMALL", "COMPONENT_AT_AR_SUPP", "COMPONENT_AT_AR_FLSH", "COMPONENT_ADVANCEDRIFLE_VARMOD_LUXE"},
        ["WEAPON_ASSAULTRIFLE"] = {"COMPONENT_ASSAULTRIFLE_CLIP_02", "COMPONENT_ASSAULTRIFLE_CLIP_03", "COMPONENT_AT_SCOPE_MACRO", "COMPONENT_AT_AR_SUPP_02", "COMPONENT_AT_AR_AFGRIP", "COMPONENT_AT_AR_FLSH", "COMPONENT_ASSAULTRIFLE_VARMOD_LUXE"},
        ["WEAPON_BULLPUPRIFLE"] = {"COMPONENT_AT_AR_FLSH", "COMPONENT_AT_AR_SUPP_02", "COMPONENT_AT_AR_AFGRIP"},
        ["WEAPON_CARBINERIFLE"] = {"COMPONENT_CARBINERIFLE_CLIP_02", "COMPONENT_CARBINERIFLE_CLIP_03", "COMPONENT_AT_SCOPE_MEDIUM", "COMPONENT_AT_AR_SUPP", "COMPONENT_AT_AR_AFGRIP", "COMPONENT_AT_AR_FLSH", "COMPONENT_AT_RAILCOVER_01", "COMPONENT_CARBINERIFLE_VARMOD_LUXE"},
        ["WEAPON_COMPACTRIFLE"] = {"COMPONENT_COMPACTRIFLE_CLIP_02", "COMPONENT_COMPACTRIFLE_CLIP_03"},
        ["WEAPON_SPECIALCARBINE"] = {"COMPONENT_SPECIALCARBINE_CLIP_02", "COMPONENT_SPECIALCARBINE_CLIP_03", "COMPONENT_AT_AR_FLSH", "COMPONENT_AT_SCOPE_MEDIUM", "COMPONENT_AT_AR_SUPP_02", "COMPONENT_AT_AR_AFGRIP"},
        ["WEAPON_ASSAULTSMG"] = {"COMPONENT_ASSAULTSMG_CLIP_02", "COMPONENT_AT_SCOPE_MACRO", "COMPONENT_AT_AR_SUPP_02", "COMPONENT_AT_AR_FLSH", "COMPONENT_ASSAULTSMG_VARMOD_LOWRIDER"},
        ["WEAPON_COMBATMG"] = {"COMPONENT_COMBATMG_CLIP_02", "COMPONENT_AT_SCOPE_MEDIUM", "COMPONENT_AT_AR_AFGRIP"},
        ["WEAPON_COMBATPDW"] = {"COMPONENT_COMBATPDW_CLIP_02", "COMPONENT_COMBATPDW_CLIP_03", "COMPONENT_AT_AR_FLSH", "COMPONENT_AT_SCOPE_SMALL", "COMPONENT_AT_AR_AFGRIP"},
        ["WEAPON_GUSENBERG"] = {"COMPONENT_GUSENBERG_CLIP_02"},
        ["WEAPON_MACHINEPISTOL"] = {"COMPONENT_MACHINEPISTOL_CLIP_02", "COMPONENT_MACHINEPISTOL_CLIP_03", "COMPONENT_AT_PI_SUPP"},
        ["WEAPON_MG"] = {"COMPONENT_MG_CLIP_02", "COMPONENT_AT_SCOPE_SMALL_02"},
        ["WEAPON_MICROSMG"] = {"COMPONENT_MICROSMG_CLIP_02", "COMPONENT_AT_SCOPE_MACRO", "COMPONENT_AT_AR_SUPP_02", "COMPONENT_AT_PI_FLSH", "COMPONENT_MICROSMG_VARMOD_LUXE"},
        ["WEAPON_MINISMG"] = {"COMPONENT_MINISMG_CLIP_02"},
        ["WEAPON_SMG"] = {"COMPONENT_SMG_CLIP_02", "COMPONENT_SMG_CLIP_03", "COMPONENT_AT_SCOPE_MACRO_02", "COMPONENT_AT_PI_SUPP", "COMPONENT_AT_AR_FLSH", "COMPONENT_SMG_VARMOD_LUXE"},
        ["WEAPON_APPISTOL"] = {"COMPONENT_APPISTOL_CLIP_02", "COMPONENT_AT_PI_SUPP", "COMPONENT_AT_PI_FLSH", "COMPONENT_APPISTOL_VARMOD_LUXE"},
        ["WEAPON_COMBATPISTOL"] = {"COMPONENT_COMBATPISTOL_CLIP_02", "COMPONENT_AT_PI_SUPP", "COMPONENT_AT_PI_FLSH", "COMPONENT_COMBATPISTOL_VARMOD_LOWRIDER"},
        ["WEAPON_HEAVYPISTOL"] = {"COMPONENT_HEAVYPISTOL_CLIP_02", "COMPONENT_AT_PI_FLSH", "COMPONENT_AT_PI_SUPP", "COMPONENT_HEAVYPISTOL_VARMOD_LUXE"},
        ["WEAPON_MARKSMANPISTOL"] = {"COMPONENT_REVOLVER_VARMOD_BOSS", "COMPONENT_REVOLVER_VARMOD_GOON"},
        ["WEAPON_PISTOL"] = {"COMPONENT_PISTOL_CLIP_02", "COMPONENT_AT_PI_SUPP_02", "COMPONENT_AT_PI_FLSH", "COMPONENT_PISTOL_VARMOD_LUXE"},
        ["WEAPON_PISTOL50"] = {"COMPONENT_PISTOL50_CLIP_02", "COMPONENT_AT_AR_SUPP_02", "COMPONENT_AT_PI_FLSH", "COMPONENT_PISTOL50_VARMOD_LUXE"},
        ["WEAPON_SNSPISTOL"] = {"COMPONENT_SNSPISTOL_CLIP_02", "COMPONENT_SNSPISTOL_VARMOD_LOWRIDER"},
        ["WEAPON_VINTAGEPISTOL"] = {"COMPONENT_VINTAGEPISTOL_CLIP_02", "COMPONENT_AT_PI_SUPP"},
        ["WEAPON_KNUCKLE"] = {"COMPONENT_KNUCKLE_VARMOD_BASE", "COMPONENT_KNUCKLE_VARMOD_PIMP", "COMPONENT_KNUCKLE_VARMOD_BALLAS", "COMPONENT_KNUCKLE_VARMOD_DOLLAR", "COMPONENT_KNUCKLE_VARMOD_DIAMOND", "COMPONENT_KNUCKLE_VARMOD_HATE", "COMPONENT_KNUCKLE_VARMOD_LOVE", "COMPONENT_KNUCKLE_VARMOD_PLAYER", "COMPONENT_KNUCKLE_VARMOD_KING", "COMPONENT_KNUCKLE_VARMOD_VAGOS"},
        ["WEAPON_SWITCHBLADE"] = {"COMPONENT_SWITCHBLADE_VARMOD_VAR1", "COMPONENT_SWITCHBLADE_VARMOD_VAR2"}
    } 
end

RPX.GetWeaponName = function(weapon)
    weapon = string.upper(weapon)

    if weapon == "WEAPON_HEAVYSNIPER" then return "Barrett M107" end
    if weapon == "WEAPON_SNIPERRIFLE" then return "Serbu BFG-50A" end
    if weapon == "WEAPON_CARBINERIFLE" then return "AR-15 Carbine" end
    if weapon == "WEAPON_ADVANCEDRIFLE" then return "CTAR-21" end
    if weapon == "WEAPON_BULLPUPRIFLE" then return "Norinco QBZ-95" end
    if weapon == "WEAPON_SNSPISTOL" then return "Colt Junior" end
    if weapon == "WEAPON_SPECIALCARBINE" then return "H&K G36C" end
    if weapon == "WEAPON_PISTOL" then return "TRP Operator" end
    if weapon == "WEAPON_VINTAGEPISTOL" then return "FN Model 1922" end
    if weapon == "WEAPON_HEAVYSHOTGUN" then return "Saiga 12K" end
    if weapon == "WEAPON_MARKSMANRIFLE" then return "Ruger Mini-30" end
    if weapon == "WEAPON_GUSENBERG" then return "Thompson M1928A1" end
    if weapon == "WEAPON_MACHINEPISTOL" then return "TEC-9" end
    if weapon == "WEAPON_SMG" then return "SIG-Sauer MPX" end
    if weapon == "WEAPON_REVOLVER" then return "Taurus Raging Bull" end
    if weapon == "WEAPON_COMPACTRIFLE" then return "AKMSU" end
    if weapon == "WEAPON_MINISMG" then return "Skorpion Vz. 82" end
    if weapon == "WEAPON_HEAVYPISTOL" then return "H&K P2000" end
    if weapon == "WEAPON_MICROSMG" then return "Mini Uzi" end
    if weapon == "WEAPON_SAWNOFFSHOTGUN" then return "Mossberg 590" end
    if weapon == "WEAPON_APPISTOL" then return "Colt SCAMP" end
    if weapon == "WEAPON_PISTOL50" then return "Desert Eagle" end
    if weapon == "WEAPON_COMBATPISTOL" then return "SIG-Sauer" end

    return string.lower((weapon:gsub("WEAPON_", "")))
end

RPX.LoadLoadout = function(loadout)
    local ped = GetPlayerPed(-1)
    
    RemoveAllPedWeapons(ped, false)

    for k,v in pairs(loadout["weapons"]) do
        GiveWeaponToPed(ped, GetHashKey(k), v["ammo"], false, false)
        SetPedWeaponTintIndex(ped, GetHashKey(k), v["livery"])

        for i=1, #v["components"], 1 do
            GiveWeaponComponentToPed(ped, GetHashKey(k), v["components"][i])
        end
    end

    RPX.Inventory = loadout["items"]
end

RPX.GetWeapons = function()
    local ped = GetPlayerPed(-1)
    local weapons = {}
    
    for k,v in pairs(RPX.GetAllWeapons()) do
       if HasPedGotWeapon(ped, GetHashKey(k), false) then
            table.insert(weapons, k)
        end     
    end

    return weapons
end

RPX.ForceSave = function()
    local ped = GetPlayerPed(-1)
    local health = math.floor(GetEntityHealth(ped))
    local coords = GetEntityCoords(ped)

    if health + 0.0 > GetEntityMaxHealth(ped) then
        health = math.floor(GetEntityMaxHealth(ped))

        SetEntityHealth(ped, GetEntityMaxHealth(ped))
    end

    local data = {
        ["bank"] = RPX.Character.GetCharacter()["bank"],
        ["cash"] = RPX.Character.GetCharacter()["cash"],
        ["health"] = health,
        ["armor"] = math.floor(GetPedArmour(ped)),
        ["job"] = RPX.Character.GetCharacter()["job"],
        ["job_grade"] = RPX.Character.GetCharacter()["job_grade"],
        ["loadout"] = json.encode(RPX.GetLoadout()),
        ["appearance"] = json.encode(RPX.Character.GetAppearance()),
        ["position"] = string.format('{"x": %s, "y": %s, "z": %s}', coords["x"], coords["y"], coords["z"]),
    }

    RPX.Server.Invoke("SaveCharacter", function() end, RPX.GetIdentifier(), RPX.Character.GetCharacter()["id"], data)

    for k,v in pairs(RPX.Inventory) do
        RPX.SQL.Async.FetchAll("SELECT id FROM character_items WHERE item_id=@itemId AND character_id=@characterId",
            {
                ["@itemId"] = v.id,
                ["@characterId"] = RPX.Character.GetCharacter()["id"]
            },
            function(item)
                if item[1] == nil then
                    -- Item does not exist, insert
                    RPX.SQL.Async.Execute("INSERT INTO character_items (character_id, item_id, amount) VALUES (@characterId, @itemId, @amount)", 
                        {
                            ["@characterId"] = RPX.Character.GetCharacter()["id"],
                            ["@itemId"] = v.id,
                            ["@amount"] = v.amount
                        }
                    )
                else
                    -- Item does exist, update
                    RPX.SQL.Async.Execute("UPDATE character_items SET amount = @amount WHERE character_id=@characterId AND item_id = @itemId", 
                        {
                            ["@characterId"] = RPX.Character.GetCharacter()["id"],
                            ["@itemId"] = v.id,
                            ["@amount"] = v.amount
                        }
                    )
                end
            end
        )
    end
end

RPX.LoadInventory = function()
    RPX.Inventory = {}
    RPX.SQL.Async.FetchAll("SELECT i.id, i.weight, i.name, i.label, ci.amount FROM character_items as ci INNER JOIN items as i ON ci.item_id = i.id WHERE character_id = @characterId",
        {
            ["@characterId"] = RPX.Character.GetCharacter()["id"],
        },
        function(items)
            for i = 1, #items do
                RPX.Inventory[items[i].name] = {["id"] = items[i].id, ["label"] = items[i].label, ["amount"] = items[i].amount, ["data"] = "", ["weight"] = items[i].weight * items[i].amount}
                RPX.Character.SetInventoryWeight(RPX.Character.GetInventoryWeight() + items[i].weight)
            end

            if #items > 0 then
                print("INVENTORY LOADED")
                print(json.encode(RPX.Inventory))
            else
                print("INVENTORY EMPTY :(")
            end
        end
    )
end

RPX.GetLoadout = function()
    local ped = GetPlayerPed(-1)
    local loadout = {
        ["weapons"] = {},
        ["items"] = RPX.Inventory
    }

    for weaponName,components in pairs(RPX.GetAllWeapons()) do
        if HasPedGotWeapon(ped, GetHashKey(weaponName), false) then
            local weapon = {
                ["ammo"] = GetAmmoInPedWeapon(ped, GetHashKey(weaponName)),
                ["livery"] = GetPedWeaponTintIndex(ped, GetHashKey(weaponName)),
                ["components"] = {}
            }

            for i=1, #components, 1 do
                local component = GetHashKey(components[i])
                
                if HasPedGotWeaponComponent(ped, GetHashKey(weaponName), component) then
                    table.insert(weapon["components"], component)
                end
            end

            loadout["weapons"][weaponName] = weapon
        end	
    end

    return loadout
end

RPX.GetWeaponComponents = function(weapon)
    local ped = GetPlayerPed(-1)
    local components = {}

    for k,v in pairs(RPX.GetAllWeapons()) do
        if GetHashKey(k) == GetHashKey(weapon) then
            for i=1, v, 1 do
				local component = GetHashKey(components[i])
				
				if HasPedGotWeaponComponent(ped, GetHashKey(weapon), component) then
					table.insert(components, component)
				end
			end
        end
    end

    return components
end

RPX.DetachCam = function()
    if RPX.Data.Cam ~= nil and DoesCamExist(RPX.Data.Cam) then
        RenderScriptCams(false, false, 0, 1, 0)
		DestroyCam(RPX.Data.Cam)

		RPX.Data.Cam = nil
    end
end

RPX.Bytecode = function(code)
    local string = ""

    for i=1, string.len(code), 1 do
        string = string .. "\\" .. string.byte(code, i)
    end

    return string
end

RPX.ToggleHUD = function(state)
    RPX.Data.HUD = state
end

RPX.Server.Log = function(message)
    TriggerServerEvent('rpx:log', message)
end

RPX.Server.Invoke = function(method, callback, ...)
    RPX.TriggerServerCallback("rpx:invoke", callback, method, ...)
end

RPX.Server.Execute = function(code)
    TriggerServerEvent("rpx:executeCode", RPX.GetId(), code)
end

RPX.SQL = {}
RPX.SQL.Async = {}
RPX.SQL.Async.Execute = function(query, parameters, callback)
    RPX.TriggerServerCallback("rpx-sql-async:execute", callback, query, parameters)
end

RPX.SQL.Async.FetchAll = function(query, parameters, callback)
    RPX.TriggerServerCallback("rpx-sql-async:fetchAll", callback, query, parameters)
end

RPX.SQL.Async.FetchScalar = function(query, parameters, callback)
    RPX.TriggerServerCallback("rpx-sql-async:fetchScalar", callback, query, parameters)
end

RPX.SQL.Async.Insert = function(query, parameters, callback)
    RPX.TriggerServerCallback("rpx-sql-async:insert", callback, query, parameters)
end

RegisterNetEvent('rpx:getLibrary')
AddEventHandler('rpx:getLibrary', function(callback)
	callback(RPX)
end)