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

RegisterNetEvent('rpx:playerLoaded')
AddEventHandler('rpx:playerLoaded', function()
    PlayerLoaded()
end)

function PlayerLoaded()
    local appearance = RPX.Table.Copy(RPX.Character.GetAppearance())
    local ped = GetPlayerPed(-1)
    local blip = AddBlipForCoord(-1338.1944580078, -1278.0551757813, 4.8750419616699)

    SetBlipSprite(blip, 102)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 2)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Maskaffär")
    EndTextCommandSetBlipName(blip)

    RPX.Markers.Add("mask_shop", {["x"] = -1338.1944580078, ["y"] = -1278.0551757813, ["z"] = 4.8750419616699}, "Tryck ~INPUT_CONTEXT~ för att köpa en mask", function()
        RPX.Character.OpenAppearanceMenu(function()
            local character = RPX.Character.GetCharacter()
            
            if character["cash"] >= 100 then
                appearance = RPX.Table.Copy(RPX.Character.GetAppearance())

                RPX.Menu.Close()
                RPX.Character.UpdateData("cash", character["cash"] - 100)
            else
                RPX.ShowNotification("Du har inte råd att köpa denna mask. ~g~(100 SEK)")
            end
        end, {
            ["sex"] = true,
            ["face"] = true,
            ["skin"] = true,
            ["age_1"] = true,
            ["age_2"] = true,
            ["beard_1"] = true,
            ["beard_2"] = true,
            ["beard_3"] = true,
            ["beard_4"] = true,
            ["hair_1"] = true,
            ["hair_2"] = true,
            ["hair_color_1"] = true,
            ["hair_color_2"] = true,
            ["eyebrows_1"] = true,
            ["eyebrows_2"] = true,
            ["eyebrows_3"] = true,
            ["eyebrows_4"] = true,
            ["makeup_1"] = true,
            ["makeup_2"] = true,
            ["makeup_3"] = true,
            ["makeup_4"] = true,
            ["lipstick_1"] = true,
            ["lipstick_2"] = true,
            ["lipstick_3"] = true,
            ["lipstick_4"] = true,
            ["tshirt_1"] = true,
            ["tshirt_2"] = true,
            ["ears_1"] = true,
            ["ears_2"] = true,
            ["torso_1"] = true,
            ["torso_2"] = true,
            ["decals_1"] = true,
            ["decals_2"] = true,
            ["arms"] = true,
            ["pants_1"] = true,
            ["pants_2"] = true,
            ["shoes_1"] = true,
            ["shoes_2"] = true,
            ["mask_1"] = false,
            ["mask_2"] = false,
            ["bproof_1"] = true,
            ["bproof_2"] = true,
            ["chain_1"] = true,
            ["chain_2"] = true,
            ["bag_1"] = true,
            ["bag_2"] = true,
            ["helmet_1"] = true,
            ["helmet_2"] = true,
            ["glasses_1"] = true,
            ["glasses_2"] = true
        }, true, function()
            RPX.Character.UpdateAppearance(appearance)
        end)
    end)
end