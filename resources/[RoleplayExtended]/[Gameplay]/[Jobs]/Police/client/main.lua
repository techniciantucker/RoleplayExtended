local RPX = nil
local Outfits = {
    [1] = {
        ["mask_1"] = 121,
        ["shoes_1"] = 25,
        ["tshirt_1"] = 122,
        ["tshirt_2"] = 0,
        ["torso_1"] = 55,
        ["torso_2"] = 0,
        ["pants_1"] = 31,
        ["arms"] = 30
    }
}
local Vehicles = {
    {
        ["label"] = "Police 1",
        ["value"] = "police",
        ["icon"] = "taxi"
    }
}

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
    local blip = AddBlipForCoord(449.10537719727, -981.18139648438, 43.691402435303)

    SetBlipSprite(blip, 60)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 63)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Polisstation")
    EndTextCommandSetBlipName(blip)
        
    RPX.Markers.Add("police_armory", {["x"] = 460.13800048828, ["y"] = -981.10424804688, ["z"] = 30.689599990845}, "Tryck ~INPUT_CONTEXT~ för att öppna förrådet", function()
        OpenArmory()
    end, 
        {
            ["requiredJob"] = "police"
        }
    )

    RPX.Markers.Add("police_lockerroom", {["x"] = 451.64428710938, ["y"] = -992.66564941406, ["z"] = 30.689613342285}, "Tryck ~INPUT_CONTEXT~ för att byta om", function()
        OpenLockerrom()
    end, 
        {
            ["requiredJob"] = "police"
        }
    )

    RPX.Markers.Add("police_garage", {["x"] = 427.7131652832, ["y"] = -1012.7272338867, ["z"] = 28.952350158691}, "Tryck ~INPUT_CONTEXT~ för att köra ut ett fordon", function()
        OpenGarage()
    end, 
        {
            ["requiredJob"] = "police"
        }
    )

    RPX.Markers.Add("police_put_garage", {["x"] = 452.526, ["y"] = -997.231, ["z"] = 25.767}, "Tryck ~INPUT_CONTEXT~ för att parkera ditt fordon", function()
        PutInCar()
    end, 
        {
            ["requiredJob"] = "police"
        }
    )

    RPX.Markers.Add("police_put_garage2", {["x"] = 447.264, ["y"] = -997.231, ["z"] = 25.767}, "Tryck ~INPUT_CONTEXT~ för att parkera ditt fordon", function()
        PutInCar()
    end, 
        {
            ["requiredJob"] = "police"
        }
    )
end

function OpenArmory()
    RPX.Menu.Open(
        {
            ["title"] = "Polisen",
            ["category"] = "Förråd",
            ["elements"] = {
                {["label"] = "Utrustning", ["value"] = "weapons", ["icon"] = "gun-filled"},
                {["label"] = "Bevismaterial", ["value"] = "proof", ["icon"] = "check-filled"}
            }
        },
        function(current, menu) 
            if current["value"] == "weapons" then
                OpenWeaponStorage()
            elseif current["value"] == "proof" then
                OpenEvidenceStorage()
            end
        end,
        function(current, menu)
            menu.close()
        end
    )
end

function OpenWeaponStorage()
    exports["Storage"]:OpenStorage("police", "evidence", function(items)
        local elements = {}

        for i = 1, #items do
            table.insert(elements, {["label"] = items[i].label .. " - [" .. items[i].amount .. "]", ["value"] = "withdraw"})
        end

        RPX.Menu.Close()
        RPX.Menu.Open(
            {
                ["title"] = "Polisen",
                ["category"] = "Vapenförråd",
                ["elements"] = elements
            },
            function(current, menu)
                
            end,
            function(current, menu)
                menu.close()
            end
        )
    end)
end

function OpenEvidenceStorage()
    exports["Storage"]:OpenStorage("police", "evidence", function(items)
        local elements = {}

        for i = 1, #items do
            table.insert(elements, {["label"] = items[i].label .. " - [" .. items[i].amount .. "]", ["value"] = "withdraw"})
        end

        RPX.Menu.Close()
        RPX.Menu.Open(
            {
                ["title"] = "Polisen",
                ["category"] = "Bevismaterial",
                ["elements"] = elements
            },
            function(current, menu)
                
            end,
            function(current, menu)
                menu.close()
            end
        )
    end)
end

function OpenLockerrom()
    RPX.Menu.Open(
        {
            ["title"] = "Polisen",
            ["category"] = "Omklädningsrum",
            ["elements"] = {
                {["label"] = "Personliga", ["value"] = "owned", ["icon"] = "jacket"},
                {["label"] = "Polisuniform", ["value"] = "uniform", ["icon"] = "policeman-male-filled"},
                {["label"] = "Skottsäker Väst", ["value"] = "bulletproof", ["icon"] = "bulletproof-vest"}
            }
        },
        function(current, menu)
            Citizen.CreateThread(function()
                local ped = GetPlayerPed(-1)

                RPX.PlayAnimation(ped, "oddjobs@basejump@ig_15", "puton_parachute", 
                    {
                        ["speed"] = 1.0
                    }
                )

                Citizen.Wait(3000)
                
                if current["value"] == "uniform" then
                    RPX.Character.UpdateAppearance(Outfits[1])
                elseif current["value"] == "bulletproof" then
                    if RPX.Character.GetAppearance()["bproof_1"] ~= 10 then
                        SetPedArmour(ped, 100)

                        RPX.Character.UpdateAppearance({
                            ["bproof_1"] = 10,
                            ["bproof_2"] = 1
                        })
                    else
                        SetPedArmour(ped, 0)

                        RPX.Character.UpdateAppearance({
                            ["bproof_1"] = 0,
                            ["bproof_2"] = 0
                        })
                    end
                elseif current["value"] == "owned" then
                    SetPedArmour(ped, 0)

                    RPX.Character.UpdateAppearance({
                        ["bproof_1"] = 0,
                        ["bproof_2"] = 0
                    })

                    exports["ClothesShop"]:OpenWardrobe()
                end
            end)
        end,
        function(current, menu)
            menu.close()
        end
    )
end

function OpenGarage()
    RPX.Menu.Open(
        {
            ["title"] = "Polisen",
            ["Category"] = "Garage",
            ["elements"] = Vehicles
        },
        function(current, menu)
            menu.close()

            RPX.SpawnVehicle(current["value"], {["x"] = 431.35272216797, ["y"] = -996.82000732422, ["z"] = 25.767404556274}, 182.01856994629, function(vehicle)
                TaskWarpPedIntoVehicle(GetPlayerPed(-1), vehicle, -1)
            end)
        end,
        function(current, menu)
            menu.close()
        end
    )
end

function PutInCar()
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
    
    DeleteVehicle(vehicle)
end