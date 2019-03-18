local RPX = nil

Citizen.CreateThread(function()
    Citizen.Wait(1)

    exports["Library"]:AddHook(GetCurrentResourceName(), function(library)
        RPX = library

        if RPX.IsLoaded then
            PlayerLoaded()
        end
    end)
end)

RegisterNetEvent("rpx:playerLoaded")
AddEventHandler("rpx:playerLoaded", function()
    PlayerLoaded()
end)

function PlayerLoaded()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
        
            if IsControlJustPressed(0, RPX.Keys["F2"]) then
                OpenInventory()
            end
        end
    end)
end

function OpenInventory()
    RPX.Menu.Open(
        {
            ["title"] = "Ryggsäck",
            ["category"] = "Kategorier",
            ["color"] = {43, 229, 108},
            ["elements"] = {
                {["label"] = "Vapen", ["value"] = "weapon"},
                {["label"] = "Föremål", ["value"] = "inventory"}
            }
        },
        function(current, menu)
            menu.close()

            if current["value"] == "weapon" then
                OpenWeaponMenu()
            elseif current["value"] == "inventory" then
                OpenItemMenu()
            end
        end,
        function(current, menu)
            menu.close()
        end
    )
end

function OpenWeaponMenu()
    local elements = {}

    for k,v in pairs(RPX.GetLoadout()["weapons"]) do
        local label = RPX.GetWeaponName(k)
        local description = label .. " with " .. v["ammo"] .. " bullets."
    
        table.insert(elements, {["label"] = label, ["value"] = k, ["description"] = description})
    end

    RPX.Menu.Open(
        {
            ["title"] = "Ryggsäck",
            ["category"] = "Vapen",
            ["color"] = {43, 229, 108},
            ["elements"] = elements
        },
        function(current, menu)
            menu.close()
        end,
        function(current, menu)
            menu.close()

            OpenInventory()
        end
    )
end

function OpenItemMenu()
    local elements = {}

    for k,v in pairs(RPX.GetInventory()) do
        table.insert(elements, {["label"] = v["label"], ["value"] = k, ["option"] = v["amount"]})
    end

    RPX.Menu.Open(
        {
            ["title"] = "Ryggsäck",
            ["category"] = "Föremål",
            ["color"] = {62, 249, 121},
            ["elements"] = elements
        },
        function(current, menu)
            menu.close()

        end,
        function(current, menu)
            menu.close()

            OpenInventory()
        end
    )
end

function GetWeaponComponentLabels(weapon)
    local ped = GetPlayerPed(-1)
    local components = {}

    for k,v in pairs(RPX.GetAllWeapons()) do
        if GetHashKey(k) == GetHashKey(weapon) then
            for i=1, #v, 1 do
				local component = GetHashKey(v[i])
            
				if HasPedGotWeaponComponent(ped, GetHashKey(weapon), component) then
					table.insert(components, v[i])
				end
			end
        end
    end

    return components
end