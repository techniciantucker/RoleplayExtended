local spawning = false
local appearanceCallback = nil
local creation = {
    ["ped"] = {["x"] = -1756.998046875, ["y"] = 427.05032348633, ["z"] = 127.68492126465, ["heading"] = 52.582653045654},
    ["endpoint"] = {["x"] = 217.25634765625, ["y"] = -937.39483642578, ["z"] = 24.141571044922, ["heading"] = 317.93896484375}
}

RPX.Character = {}
RPX.Character.UpdateAppearance = function(config, callback)
    TriggerServerEvent('rpx:appearanceUpdate', RPX.GetId(), config)

    appearanceCallback = callback
end

local OpenedAppearanceMenu = false
local CurrentAppearanceKey = nil
local Capacity = 5000
local InventoryWeight = 0
local Character = {}
local Characters = {}
local CharacterAppearance = {
    ["sex"] = 0,
    ["face"] = 0,
    ["skin"] = 0,
    ["age_1"] = 0,
    ["age_2"] = 0,
    ["beard_1"] = 0,
    ["beard_2"] = 0,
    ["beard_3"] = 0,
    ["beard_4"] = 0,
    ["hair_1"] = 0,
    ["hair_2"] = 0,
    ["hair_color_1"] = 0,
    ["hair_color_2"] = 0,
    ["eyebrows_1"] = 0,
    ["eyebrows_2"] = 0,
    ["eyebrows_3"] = 0,
    ["eyebrows_4"] = 0,
    ["makeup_1"] = 0,
    ["makeup_2"] = 0,
    ["makeup_3"] = 0,
    ["makeup_4"] = 0,
    ["lipstick_1"] = 0,
    ["lipstick_2"] = 0,
    ["lipstick_3"] = 0,
    ["lipstick_4"] = 0,
    ["ears_1"] = -1,
    ["ears_2"] = 0,
    ["tshirt_1"] = 0,
    ["tshirt_2"] = 0,
    ["torso_1"] = 0,
    ["torso_2"] = 0,
    ["decals_1"] = 0,
    ["decals_2"] = 0,
    ["arms"] = 0,
    ["pants_1"] = 0,
    ["pants_2"] = 0,
    ["shoes_1"] = 0,
    ["shoes_2"] = 0,
    ["mask_1"] = 0,
    ["mask_2"] = 0,
    ["bproof_1"] = 0,
    ["bproof_2"] = 0,
    ["chain_1"] = 0,
    ["chain_2"] = 0,
    ["bag_1"] = 0,
    ["bag_2"] = 0,
    ["helmet_1"] = -1,
    ["helmet_2"] = 0,
    ["glasses_1"] = 0,
    ["glasses_2"] = 0
}

RegisterNetEvent('rpx:updateAppearance')
AddEventHandler('rpx:updateAppearance', function(id, config)
    UpdateAppearance(GetPlayerFromServerId(id), config)
end)


RPX.Character.GetAppearance = function()
    return CharacterAppearance
end

RPX.Character.GetCharacter = function()
    return Character
end

RPX.Character.GetCapacity = function()
    return Capacity
end

RPX.Character.GetInventoryWeight = function()
    return InventoryWeight
end

RPX.Character.SetInventoryWeight = function(weight)
    InventoryWeight = weight
end

RPX.Character.GetCharacters = function()
    return Characters
end

RPX.Character.UpdateData = function(key, value)
    Character[key] = value
    
    for i=1, #Characters, 1 do
        if Characters[i]["id"] == Character["id"] then
            Characters[i][key] = value
        end
    end
end

RPX.Character.GetComponents = function()
    local ped = GetPlayerPed(-1)

    return {
        [1] = {"sex", 1, 0},
        [2] = {"face", 45, 0},
        [3] = {"skin", 45, 0},
        [4] = {"age_1", GetNumHeadOverlayValues(3) - 1, 0},
        [5] = {"age_2", 10, 0},
        [6] = {"beard_1", GetNumHeadOverlayValues(1) - 1, 0},
        [7] = {"beard_2", 10, 0},
        [8] = {"beard_3", GetNumHairColors() - 1, 0},
        [9] = {"beard_4", GetNumHairColors() - 1, 0},
        [10] = {"hair_1", GetNumberOfPedDrawableVariations(ped, 2) - 1, 0, "CC_F_HS"},
        [11] = {"hair_2", GetNumberOfPedTextureVariations(ped, 2, CharacterAppearance["hair_1"]) - 1, 0},
        [12] = {"hair_color_1", GetNumHairColors() - 1, 0},
        [13] = {"hair_color_2", GetNumHairColors() - 1, 0},
        [14] = {"eyebrows_1", GetNumHeadOverlayValues(2) - 1, 0},
        [15] = {"eyebrows_2", 10, 0},
        [16] = {"eyebrows_3", GetNumHairColors() - 1, 0},
        [17] = {"eyebrows_4", GetNumHairColors() - 1, 0},
        [18] = {"makeup_1", GetNumHeadOverlayValues(4) - 1, 0},
        [19] = {"makeup_2", 10, 0},
        [20] = {"makeup_3", GetNumHairColors() - 1, 0},
        [21] = {"makeup_4", GetNumHairColors() - 1, 0},
        [22] = {"lipstick_1", GetNumHeadOverlayValues(8) - 1, 0},
        [23] = {"lipstick_2", 10, 0},
        [24] = {"lipstick_3", GetNumHairColors() - 1, 0},
        [25] = {"lipstick_4", GetNumHairColors() - 1, 0},
        [26] = {"ears_1", GetNumberOfPedPropDrawableVariations(ped, 1) - 1, -1},
        [27] = {"ears_2", GetNumberOfPedPropTextureVariations(ped, 1, CharacterAppearance["ears_1"] - 1) , 0},
        [28] = {"tshirt_1", GetNumberOfPedDrawableVariations(ped, 8) - 1, 0},
        [29] = {"tshirt_2", GetNumberOfPedTextureVariations(ped, 8, CharacterAppearance["tshirt_1"]) - 1, 0},
        [30] = {"torso_1", GetNumberOfPedDrawableVariations(ped, 11) - 1, 0},
        [31] = {"torso_2", GetNumberOfPedTextureVariations(ped, 11, CharacterAppearance["torso_1"]) - 1, 0},
        [32] = {"decals_1", GetNumberOfPedDrawableVariations (ped, 10) - 1, 0},
        [33] = {"decals_2", GetNumberOfPedTextureVariations(ped, 10, CharacterAppearance["decals_1"]) - 1, 0},
        [34] = {"arms", GetNumberOfPedDrawableVariations(ped, 3) - 1, 0},
        [35] = {"pants_1", GetNumberOfPedDrawableVariations(ped, 4) - 1, 0},
        [36] = {"pants_2", GetNumberOfPedTextureVariations(ped, 4, CharacterAppearance["pants_1"]) - 1, 0},
        [37] = {"shoes_1", GetNumberOfPedDrawableVariations(ped, 6) - 1, 0},
        [38] = {"shoes_2", GetNumberOfPedTextureVariations(ped, 6, CharacterAppearance["shoes_1"]) - 1, 0},
        [39] = {"mask_1", GetNumberOfPedDrawableVariations(ped, 1) - 1, 0},
        [40] = {"mask_2", GetNumberOfPedTextureVariations(ped, 1, CharacterAppearance["mask_1"]) - 1, 0},
        [41] = {"bproof_1", GetNumberOfPedDrawableVariations(ped, 9) - 1, 0},
        [42] = {"bproof_2", GetNumberOfPedTextureVariations(ped, 9, CharacterAppearance["bproof_1"]) - 1, 0},
        [43] = {"chain_1", GetNumberOfPedDrawableVariations(ped, 7) - 1, 0},
        [44] = {"chain_2", GetNumberOfPedTextureVariations(ped, 7, CharacterAppearance["chain_1"]) - 1, 0},
        [45] = {"bag_1", GetNumberOfPedDrawableVariations(ped, 5) - 1, 0},
        [46] = {"bag_2", GetNumberOfPedTextureVariations(ped, 5, CharacterAppearance["bag_1"]) - 1, 0},
        [47] = {"helmet_1", GetNumberOfPedPropDrawableVariations(ped, 0) - 1, -1},
        [48] = {"helmet_2", GetNumberOfPedPropTextureVariations(ped, 0, CharacterAppearance["helmet_1"]) - 1, 0},
        [49] = {"glasses_1", GetNumberOfPedPropDrawableVariations(ped, 1) - 1, 0},
        [50] = {"glasses_2", GetNumberOfPedPropTextureVariations(ped, 1, CharacterAppearance["glasses_1"] - 1), 0}
    }
end

RPX.Character.OpenAppearanceMenu = function(callback, blacklist, cancellable, closeCallback, updateCallback)
    local ped = GetPlayerPed(-1)
    local components = RPX.Character.GetComponents()
    local elements = {}
    local currentIndex = 1

    for index,value in ipairs(components) do
        if not blacklist[value[1]] then
            local key = value[1]
            local max = value[2]
            local min = value[3]
            local translation = value[4]

            elements[currentIndex] = {["translation"] = translation, ["identifier"] = currentIndex, ["index"] = index, ["label"] = GetComponentLabel(key), ["value"] = key, ["max"] = max, ["min"] = min, ["currentIndex"] = CharacterAppearance[key], ["option"] = tostring(CharacterAppearance[key])}
            
            currentIndex = currentIndex + 1
        end
    end

    OpenedAppearanceMenu = true
    CurrentAppearanceKey = elements[1]

    local returnedMenu = {}

    Citizen.CreateThread(function()
        local timestamp = 0

        while OpenedAppearanceMenu do
            Citizen.Wait(0)

            local updated = false

            if IsControlPressed(0, RPX.Keys["LEFT"]) and (timestamp + 100) < GetGameTimer() then
                if updateCallback ~= nil then
                    updateCallback(CurrentAppearanceKey["value"])
                end

                local value = CurrentAppearanceKey["currentIndex"] - 1

                if value < CurrentAppearanceKey["min"] then
                    value = CurrentAppearanceKey["min"]
                end

                CurrentAppearanceKey["option"] = GetComponentTranslation(tostring(value), CurrentAppearanceKey)
                CurrentAppearanceKey["currentIndex"] = value

                elements[CurrentAppearanceKey["identifier"]] = CurrentAppearanceKey

                if RPX.String.EndsWith(CurrentAppearanceKey["value"], "_1") then
                    local comp = CurrentAppearanceKey["value"]:gsub("_1", "")
                    
                    for k,v in ipairs(elements) do
                        if RPX.String.StartsWith(v["value"], comp) and not RPX.String.EndsWith(v["value"], "_1") and v["value"] ~= "beard_2" and v["value"] ~= "hair_2" and v["value"] ~= "eyebrows_2" and v["value"] ~= "makeup_2" and v["value"] ~= "lipstick_2" then
                            v["currentIndex"] = v["min"]
                            v["option"] = GetComponentTranslation(tostring(v["min"]), v)
                        end
                    end
                end

                updated = true
                timestamp = GetGameTimer()
            elseif IsControlPressed(0, RPX.Keys["RIGHT"]) and (timestamp + 100) < GetGameTimer() then
                if updateCallback ~= nil then
                    updateCallback(CurrentAppearanceKey["value"])
                end
                
                local value = CurrentAppearanceKey["currentIndex"] + 1
            
                if value > CurrentAppearanceKey["max"] then
                    value = CurrentAppearanceKey["max"]
                end

                CurrentAppearanceKey["option"] = GetComponentTranslation(tostring(value), CurrentAppearanceKey)
                CurrentAppearanceKey["currentIndex"] = value

                elements[CurrentAppearanceKey["identifier"]] = CurrentAppearanceKey

                if RPX.String.EndsWith(CurrentAppearanceKey["value"], "_1") then
                    local comp = CurrentAppearanceKey["value"]:gsub("_1", "")
                    
                    for k,v in ipairs(elements) do
                        if RPX.String.StartsWith(v["value"], comp) and not RPX.String.EndsWith(v["value"], "_1") and v["value"] ~= "beard_2" and v["value"] ~= "hair_2" and v["value"] ~= "eyebrows_2" and v["value"] ~= "makeup_2" and v["value"] ~= "lipstick_2" then
                            v["currentIndex"] = v["min"]
                            v["option"] = GetComponentTranslation(tostring(v["min"]), v)
                        end
                    end
                end

                updated = true
                timestamp = GetGameTimer()
            end

            if updated then
                local appearance = {}

                for k,v in pairs(elements) do
                    appearance[v["value"]] = v["currentIndex"]
                end

                RPX.Character.UpdateAppearance(appearance)

                components = RPX.Character.GetComponents()

                for k,v in ipairs(elements) do
                    v["max"] = components[v["index"]][2]
                    v["min"] = components[v["index"]][3]
                end

                returnedMenu.update(elements)

                updated = false
            end
        end
    end)

    RPX.Menu.Open(
        {
            ["title"] = "Karaktär",
            ["category"] = "Utseende",
            ["elements"] = elements
        },
        function(current, menu)
            if callback ~= nil then
                callback()
            end
        end,
        function(current, menu)
            if cancellable then
                menu.close()

                OpenedAppearanceMenu = false

                if closeCallback ~= nil then
                    closeCallback()
                end
            end
        end,
        function(current, menu)
            CurrentAppearanceKey = current
        end,
        function(response)
            returnedMenu = response
        end
    )
end

function GetComponentTranslation(key, value)
    if key["translation"] ~= nil then
        return GetLabelText(key["translation"] .. "_" .. value)
    else
        return value
    end
end

function UpdateAppearance(handle, appearance)
    local character = CharacterAppearance
    local updateModel = false

    for k,v in pairs(appearance) do
        character[k] = v
    end

    local model = GetHashKey("mp_m_freemode_01")

    if character["sex"] == 1 then
        model = GetHashKey("mp_f_freemode_01")
    end

    if GetEntityModel(GetPlayerPed(handle)) ~= model then
        RequestModel(model)
        
        while not HasModelLoaded(model) do
            RequestModel(model)

            Citizen.Wait(0)
        end

        SetPlayerModel(handle, model)
        SetModelAsNoLongerNeeded(model)
    end
    
    local ped = GetPlayerPed(handle)

    SetPedDefaultComponentVariation(ped)
    SetPedHeadBlendData(ped, character["face"], character["face"], character["face"], character["skin"], character["skin"], character["skin"], 1.0, 1.0, 1.0, true)
    SetPedHairColor(ped, character["hair_color_1"], character["hair_color_2"])
    SetPedHeadOverlay(ped, 3, character["age_1"], (character["age_2"] / 10) + 0.0)
    SetPedHeadOverlay(ped, 1, character["beard_1"], (character["beard_2"] / 10) + 0.0)
    SetPedHeadOverlay(ped, 2, character["eyebrows_1"], (character["eyebrows_2"] / 10) + 0.0)
    SetPedHeadOverlay(ped, 4, character["makeup_1"], (character["makeup_2"] / 10) + 0.0)
    SetPedHeadOverlay(ped, 8, character["lipstick_1"], (character["lipstick_2"] / 10) + 0.0)
    SetPedComponentVariation(ped, 2, character["hair_1"], character["hair_2"], 2)
    SetPedHeadOverlayColor(ped, 1, 1, character["beard_3"], character["beard_4"])
    SetPedHeadOverlayColor(ped, 2, 1, character["eyebrows_3"], character["eyebrows_4"])
    SetPedHeadOverlayColor(ped, 4, 1, character["makeup_3"], character["makeup_4"])
    SetPedHeadOverlayColor(ped, 8, 1, character["lipstick_3"], character["lipstick_4"])

    if character["ears_1"] == -1 then
        ClearPedProp(ped, 2)
    else
        SetPedPropIndex(ped, 2, character["ears_1"], character["ears_2"], 2)
    end

    SetPedComponentVariation(ped, 8, character["tshirt_1"], character["tshirt_2"], 2)
    SetPedComponentVariation(ped, 11, character["torso_1"], character["torso_2"], 2)
    SetPedComponentVariation(ped, 3, character["arms"], 0, 2)
    SetPedComponentVariation(ped, 10, character["decals_1"], character["decals_2"], 2)
    SetPedComponentVariation(ped, 4, character["pants_1"], character["pants_2"], 2)
    SetPedComponentVariation(ped, 6, character["shoes_1"], character["shoes_2"], 2)
    SetPedComponentVariation(ped, 1, character["mask_1"], character["mask_2"], 2)
    SetPedComponentVariation(ped, 9, character["bproof_1"], character["bproof_2"], 2)
    SetPedComponentVariation(ped, 7, character["chain_1"], character["chain_2"], 2)
    SetPedComponentVariation(ped, 5, character["bag_1"], character["bag_2"], 2)

    if character["helmet_1"] == -1 then
        ClearPedProp(ped, 0)
    else
        SetPedPropIndex(ped, 0, character["helmet_1"], character["helmet_2"], 2)
    end

    SetPedPropIndex(ped, 1, character["glasses_1"], character["glasses_2"], 2)

    if handle == PlayerId() then
        CharacterAppearance = character
    end

    if appearanceCallback ~= nil then
        appearanceCallback()
        appearanceCallback = nil
    end
end

function GetComponentLabel(key)
    local labels = {
        ["sex"] = "Kön",
        ["face"] = "Ansikte",
        ["skin"] = "Hudfärg",
        ["age_1"] = "Rynkor",
        ["age_2"] = "Rynkor Tjockhet",
        ["beard_1"] = "Skägg Typ",
        ["beard_2"] = "Skägg Storlek",
        ["beard_3"] = "Skägg Färg 1",
        ["beard_4"] = "Skägg Färg 2",
        ["hair_1"] = "Hår",
        ["hair_2"] = "Hår Tjocket",
        ["hair_color_1"] = "Hår Färg 1",
        ["hair_color_2"] = "Hår Färg 2",
        ["eyebrows_1"] = "Ögonbryn Typ",
        ["eyebrows_2"] = "Ögonbryn Storlek",
        ["eyebrows_3"] = "Ögonbryn Färg 1",
        ["eyebrows_4"] = "Ögonbryn Färg 2",
        ["makeup_1"] = "Makeup Typ",
        ["makeup_2"] = "Makeup Tjockhet",
        ["makeup_3"] = "Makeup Färg 1",
        ["makeup_4"] = "Makeup Färg 2",
        ["lipstick_1"] = "Läppstift Typ",
        ["lipstick_2"] = "Läppstift Tjockhet",
        ["lipstick_3"] = "Läppstift Färg 1",
        ["lipstick_4"] = "Läppstift Färg 2",
        ["ears_1"] = "Öron Accessoarer",
        ["ears_2"] = "Öron Accessoarer Färg",
        ["tshirt_1"] = "T-Shirt",
        ["tshirt_2"] = "T-Shirt Färg",
        ["torso_1"] = "Jacka",
        ["torso_2"] = "Jacka Färg",
        ["decals_1"] = "Dekal Kategori",
        ["decals_2"] = "Dekal Typ",
        ["arms"] = "Handskar",
        ["pants_1"] = "Byxor",
        ["pants_2"] = "Byxor Färg",
        ["shoes_1"] = "Skor",
        ["shoes_2"] = "Skor Färg",
        ["mask_1"] = "Mask",
        ["mask_2"] = "Mask Färg",
        ["bproof_1"] = "Skottsäker Väst",
        ["bproof_2"] = "Skottsäker Väst Färg",
        ["chain_1"] = "Kedja",
        ["chain_2"] = "Kedja Färg",
        ["helmet_1"] = "Hjälm",
        ["helmet_2"] = "Hjälm Färg",
        ["glasses_1"] = "Glasögon",
        ["glasses_2"] = "Glasögon Färg",
        ["bag_1"] = "Väska",
        ["bag_2"] = "Väska Färg"
    }

    return labels[key]
end

function SetupLoop()
    SetAudioFlag("LoadMPData", true)

    DoScreenFadeOut(0)

    Citizen.CreateThread(function()
        Citizen.Wait(1000)

        SetEntityCoords(GetPlayerPed(-1), creation["ped"]["x"], creation["ped"]["y"], creation["ped"]["z"])
        SetEntityHeading(GetPlayerPed(-1), creation["ped"]["heading"])

        spawning = true
        
        Citizen.Wait(1000)

        RPX.TriggerServerCallback("rpx:fetchCharacters", function(characters)
            SetNuiFocus(true, true)

            if characters ~= nil and #characters > 0 then
                Characters = characters

                SendNUIMessage({
                    ["event"] = "character_selection",
                    ["characters"] = json.encode(characters)
                })
            else
                SendNUIMessage({
                    ["event"] = "character_creation"
                })
            end
        end)
    end)
end

function EnterWorld()
    Citizen.CreateThread(function()
        DoScreenFadeOut(0)

        spawning = false

        local ped = GetPlayerPed(-1)

        Citizen.Wait(1000)

        RPX.DetachCam()
        SetNuiFocus(false, false)

        DoScreenFadeIn(5000)

        TriggerEvent('rpx:playerLoaded')
        RPX.PlayAnimation(ped, "move_p_m_one_idles@generic", "fidget_look_around")

        Citizen.Wait(300)

        PlaySoundFrontend(-1, "CHECKPOINT_NORMAL", "HUD_MINI_GAME_SOUNDSET", true)
    end)
end

RegisterNetEvent('rpx:playerLoad')
AddEventHandler('rpx:playerLoad', function(identifier)
    RPX.Character.UpdateAppearance({})
    RPX.SetIdentifier(identifier)
    
    DisplayRadar(false)
    SetupLoop()
end)

RegisterNetEvent('Framework:nui:characterCreated')
AddEventHandler('Framework:nui:characterCreated', function(character)
    --[[character["id"] = #Characters + 1

    local continue = false
    
    while not continue do
        local found = false

        for i=1, #Characters, 1 do
            if Characters[i]["id"] == character["id"] then
                found = true
            end    
        end

        if found then
            character["id"] = character["id"] + 1
        else
            continue = true
        end
    end]]

    character["lastdigits"] = math.random(1000, 9999)
    character["job"] = "none"
    character["job_grade"] = 0
    character["bank"] = 0
    character["cash"] = 0

    --Character = character

    --table.insert(Characters, character)

    Citizen.CreateThread(function()
        DoScreenFadeOut(500)
    
        Citizen.Wait(500)

        SetNuiFocus(false, false)

        RPX.Character.OpenAppearanceMenu(function()
            RPX.Menu.Close()
            
            character["appearance"] = json.encode(CharacterAppearance)

            RPX.Server.Invoke({"SQL", "Async", "Execute"}, function() end, "INSERT INTO characters (identifier, firstname, lastname, dateofbirth, lastdigits, appearance, loadout, position) VALUES (@identifier, @firstname, @lastname, @dateofbirth, @lastdigits, @appearance, @loadout, @position)", 
                {
                    ["@identifier"] = RPX.GetIdentifier(),
                    ["@firstname"] = character["firstname"],
                    ["@lastname"] = character["lastname"],
                    ["@dateofbirth"] = character["dateofbirth"],
                    ["@lastdigits"] = math.random(1000, 9999),
                    ["@appearance"] = json.encode(CharacterAppearance),
                    ["@loadout"] = '{"weapons":[],"items":[]}',
                    ["@position"] = '{"x": 0.0, "y": 0.0, "z": 0.0}'
                }
            )

            local ped = GetPlayerPed(-1)
            local x, y, z = creation["endpoint"]["x"], creation["endpoint"]["y"], creation["endpoint"]["z"] - 0.5

            SetEntityCoords(ped, x, y, z)
            SetEntityHeading(ped, creation["endpoint"]["heading"])

            SetupLoop()
            --EnterWorld()
        end, {
            ["torso_1"] = true,
            ["torso_2"] = true,
            ["decals_1"] = true,
            ["decals_2"] = true,
            ["arms"] = true,
            ["pants_1"] = true,
            ["pants_2"] = true,
            ["shoes_1"] = true,
            ["shoes_2"] = true,
            ["bproof_1"] = true,
            ["bproof_2"] = true,
            ["chain_1"] = true,
            ["chain_2"] = true,
            ["bag_1"] = true,
            ["bag_2"] = true,
            ["helmet_1"] = true,
            ["helmet_2"] = true,
            ["glasses_1"] = true,
            ["glasses_2"] = true,
            ["mask_1"] = true,
            ["mask_2"] = true
        }, false)

        DoScreenFadeIn(1500)
    end)
end)

RegisterNetEvent('Framework:nui:characterSelected')
AddEventHandler('Framework:nui:characterSelected', function(table)
    for i=1, #Characters, 1 do
        local character = Characters[i]

        if character["id"] == table["id"] then
            Character = character

            RPX.Character.UpdateAppearance(json.decode(character["appearance"]), function()
                local ped = GetPlayerPed(-1)
                local coords = json.decode(character["position"])

                if character["health"] + 0.0 > GetEntityMaxHealth(ped) then
                    character["health"] = GetEntityMaxHealth(ped)
                end

                SetEntityHealth(ped, character["health"] + 0.0)
                SetPedArmour(ped, character["armor"] + 0.0)

                if coords["x"] == 0 and coords["y"] == 0 and coords["z"] == 0 then
                    local x, y, z = creation["endpoint"]["x"], creation["endpoint"]["y"], creation["endpoint"]["z"] - 0.5

                    SetEntityCoords(ped, x, y, z)
                    SetEntityHeading(ped, creation["endpoint"]["heading"])
                else
                    SetEntityCoords(ped, coords["x"], coords["y"], coords["z"])
                end

                RPX.LoadLoadout(json.decode(character["loadout"]))
                RPX.LoadInventory()
                
                EnterWorld()
            end)
        end
    end
end)

RegisterNetEvent('Framework:nui:characterDeleted')
AddEventHandler('Framework:nui:characterDeleted', function(character)
    RPX.TriggerServerCallback("rpx:deleteCharacter", function()
        for i=1, #Characters, 1 do
            if Characters[i] ~= nil and Characters[i]["id"] then
                if Characters[i]["id"] == character["id"] then
                    table.remove(Characters, i)
                end
            end
        end

        if #Characters > 0 then
            SendNUIMessage({
                ["event"] = "character_selection",
                ["characters"] = json.encode(Characters)
            })
        else
            SendNUIMessage({
                ["event"] = "character_creation"
            })
        end
    end, character["id"])
end)