local RPX = nil
local LoadedPlayer = false

Citizen.CreateThread(function()
    Citizen.Wait(1)

    exports["Library"]:AddHook(GetCurrentResourceName(), function(library)
        RPX = library

        if RPX.IsLoaded then
            LoadedPlayer = true
        end
    end)
end)

RegisterNetEvent("rpx:playerLoaded")
AddEventHandler("rpx:playerLoaded", function()
    LoadedPlayer = true
end)

local Locations = {
    ["modshop"] = {["x"] = -212.02442932129, ["y"] = -1323.3016357422, ["z"] = 30.89038848877, ["heading"] = 171.81135559082}
}

Citizen.CreateThread(function()
    while not LoadedPlayer do
        Citizen.Wait(100)
    end

    local hintDisplayed = false

    while true do
        local ped = GetPlayerPed(-1)
        local coords = GetEntityCoords(ped)
        local distance = GetDistanceBetweenCoords(coords["x"], coords["y"], coords["z"], Locations["modshop"]["x"], Locations["modshop"]["y"], Locations["modshop"]["z"], true)
        local sleep = 0

        if distance <= 3.0 and IsPedInAnyVehicle(ped, -1) then
            SetTextComponentFormat("STRING")
            AddTextComponentString("Tryck ~INPUT_CONTEXT~ för att modifiera fordonet")
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)

            if IsControlJustPressed(0, RPX.Keys["E"]) then
                OpenVehicleGeneralModMenu()
            end

            hintDisplayed = true
        else
            if hintDisplayed then
                SetTextComponentFormat("STRING")
                AddTextComponentString("")
                DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                hintDisplayed = false
            end

            sleep = math.floor(distance * 5)
        end

        Citizen.Wait(sleep)
    end
end)

local ModificationData = {}
local Categories = {
    [1] = "0|Spoiler|Trunk",
    [2] = {
        ["name"] = "Bumpers",
        ["content"] = {
            [1] = "1|Front Bumper",
            [2] = "2|Rear Bumper"
        }
    },
    [3] = "3|Skirt",
    [4] = "4|Exhaust",
    [5] = "5|Chassis",
    [6] = "6|Grill",
    [7] = "7|Hood",
    [8] = {
        ["name"] = "Fenders",
        ["content"] = {
            [1] = "8|Fender",
            [2] = "9|Right Fender"
        }
    },
    [9] = "10|Roof",
    [10] = "11|EMS Engine Upgrade",
    [11] = "12|Brakes",
    [12] = "13|Transmission",
    [13] = "14|Horns",
    [14] = "15|Unknown 0",
    [15] = "16|Armor",
    [16] = "17|Suspension",
    [17] = "18|Unknown 1",
    [18] = "19|Unknown 2",
    [19] = "20|Unknown 3",
    [20] = "21|Unknown 4",
    [22] = "22|Head Lights",
    [23] = "23|Unknown 5",
    [24] = "24|Unknown 6",
    [25] = "25|Plateholder",
    [26] = "26|Vanity Plate",
    [27] = "27|Trim Design",
    [28] = "28|Ornaments",
    [29] = "29|Dashboard",
    [30] = "30|Dial",
    [31] = "31|Door Speakers",
    [32] = "32|Leather Seats",
    [33] = "33|Steering Wheel",
    [34] = "34|Column Shifter Levers",
    [35] = "35|Plaques",
    [36] = "36|ICE",
    [37] = "37|Speakers",
    [38] = "38|Hydraulics",
    [39] = "39|Engine Block",
    [40] = "40|Air Filters",
    [41] = "41|Struts",
    [42] = "42|Arch Covers",
    [43] = "43|Aerials",
    [44] = "44|Trim",
    [45] = "45|Tank",
    [46] = "46|Window Decorations",
    [47] = "47|Unknown 7",
    [48] = "48|Livery",
}

function OpenVehicleGeneralModMenu()
    local ped = GetPlayerPed(-1)
    local vehicle = GetVehiclePedIsIn(ped, false)
    local components = GetVehicleComponents(vehicle)

    SetVehicleModKit(vehicle, 0)
    OpenVehicleModCategory(Categories)

    ModificationData["vehicle"] = vehicle
    ModificationData["components"] = components
    ModificationData["shoppingcart"] = {}
end

function OpenVehicleModCategory(category)
    local elements = {}

    for key, values in ipairs(category) do
        if type(values) == "string" then
            local value = RPX.String.Split(values, "|")

            table.insert(elements, {["value"] = tonumber(value[1]), ["label"] = value[2], ["icon"] = "settings"})
        else

        end
    end 

    RPX.Menu.Open(
        {
            ["title"] = "Benny's Original",
            ["category"] = "Kategorier",
            ["elements"] = elements
        },
        function(current, menu)
            OpenVehicleModLevels(current["label"], current["value"])
        end,
        function(current, menu)
            menu.close()
        end
    )
end

function OpenVehicleModLevels(title, modIndex)
    local vehicle = ModificationData["vehicle"]
    local mods = GetNumVehicleMods(vehicle, tonumber(modIndex))
    local elements = {}

    for level = -1, mods - 1, 1 do
        local identifier = GetModTextLabel(vehicle, modIndex, level)
        local label = "Level " .. level

        if level == - 1 then
            label = "Stock"
        elseif identifier ~= nil then
            label = GetLabelText(identifier)
        end

        table.insert(elements, {["value"] = level, ["modIndex"] = modIndex, ["label"] = label, ["icon"] = "settings"})
    end

    RPX.Menu.Open(
        {
            ["title"] = "Benny's Original",
            ["category"] = title,
            ["elements"] = elements,
        },
        function(current, menu)
            
        end,
        function(current, menu)
            OpenVehicleModCategory(Categories)
        end,
        function(current, menu)
        end,
        function(current, menu)
            local component = {
                [current["modIndex"]] = current["value"]
            }

            SetVehicleComponents(ModificationData["vehicle"], component)
        end
    )
end

function GetVehicleComponents(vehicle)
    SetVehicleModKit(vehicle, 0)
    
    local components = {}

    for modIndex = 1, 48, 1 do
        if modIndex ~= 17 and modIndex ~= 19 and modIndex ~= 21 and modIndex ~= 47 then
            if modIndex == 18 or modIndex == 20 or modIndex == 22 then
                components[modIndex] = IsToggleModOn(vehicle, modIndex)
            else
                components[modIndex] = GetVehicleMod(vehicle, modIndex)
            end
        end
    end

    local primaryColour, secondaryColour = GetVehicleColours(vehicle)
    local pearlescentColour, wheelColour = GetVehicleExtraColours(vehicle)

    components[49] = IsVehicleNeonLightEnabled(vehicle, 0)
    components[50] = IsVehicleNeonLightEnabled(vehicle, 1)
    components[51] = IsVehicleNeonLightEnabled(vehicle, 2)
    components[52] = IsVehicleNeonLightEnabled(vehicle, 3)
    components[53] = primaryColour
    components[54] = secondaryColour
    components[55] = pearlescentColour
    components[56] = wheelColour
    components[57] = GetVehicleWheelType(vehicle)
    components[58] = GetVehicleWindowTint(vehicle)
    components[59] = table.pack(GetVehicleNeonLightsColour(vehicle))
    components[60] = table.pack(GetVehicleTyreSmokeColor(vehicle))

    return components
end

function SetVehicleComponents(vehicle, components)
    SetVehicleModKit(vehicle, 0)

    for modIndex,value in pairs(components) do
        if modIndex == 18 or modIndex == 20 or modIndex == 22 then
            ToggleVehicleMod(vehicle, modIndex, value)
        elseif modIndex == 49 then
            SetVehicleNeonLightEnabled(vehicle, 0, value)
        elseif modIndex == 50 then
            SetVehicleNeonLightEnabled(vehicle, 1, value)
        elseif modIndex == 51 then
            SetVehicleNeonLightEnabled(vehicle, 2, value)
        elseif modIndex == 52 then
            SetVehicleNeonLightEnabled(vehicle, 3, value)
        elseif modIndex == 53 then
            local primaryColour, secondaryColour = GetVehicleColours(vehicle)

            SetVehicleColours(vehicle, value, primaryColour)
        elseif modIndex == 54 then
            local primaryColour, secondaryColour = GetVehicleColours(vehicle)

            SetVehicleColours(vehicle, value, primaryColour)
        elseif modIndex == 55 then
            local pearlescentColour, wheelColour = GetVehicleExtraColours(vehicle)

            SetVehicleExtraColours(vehicle, value, wheelColour)
        elseif modIndex == 56 then
            local pearlescentColour, wheelColour = GetVehicleExtraColours(vehicle)

            SetVehicleExtraColours(vehicle, pearlescentColour, value)
        elseif modIndex == 57 then
            SetVehicleWheelType(vehicle, value)
        elseif modIndex == 58 then
            SetVehicleWindowTint(vehicle, value)
        elseif modIndex == 59 then
            SetVehicleNeonLightsColour(vehicle, value[1], value[2], value[3])
        elseif modIndex == 60 then 
            SetVehicleTyreSmokeColor(vehicle, value[1], value[2], value[3])
        else 
            SetVehicleMod(vehicle, modIndex, value, false)
        end
    end
end