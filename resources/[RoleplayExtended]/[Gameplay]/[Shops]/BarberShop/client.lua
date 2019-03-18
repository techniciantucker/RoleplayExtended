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

local Shops = {
    [1] = {["x"] = 135.2943572998, ["y"] = -1710.7021484375, ["z"] = 29.29162979126, ["chairX"] = 138.3646, ["chairY"] = -1709.252, ["chairZ"] = 28.3182, ["chairHeading"] = 315.0},
    [2] = {["x"] = -816.44702148438, ["y"] = -185.02352905273, ["z"] = 37.568885803223, ["chairX"] = -816.22, ["chairY"] = -182.97, ["chairZ"] = 36.57, ["chairHeading"] = 120.0},
    [3] = {["x"] = -32.68338394165, ["y"] = -149.41386413574, ["z"] = 57.076541900635, ["chairX"] = -36.0, ["chairY"] = -151.0, ["chairZ"] = 57.0, ["chairModel"] = 1165195353, ["chairHeading"] = 160.0},
    [4] = {["x"] = 1209.6322021484, ["y"] = -472.2585144043, ["z"] = 66.208106994629, ["chairX"] = 1211.0, ["chairY"] = -476.0, ["chairZ"] = 66.0, ["chairModel"] = 1165195353, ["chairHeading"] = -100.0},
    [5] = {["x"] = 1933.5556640625, ["y"] = 3728.1442871094, ["z"] = 32.844486236572, ["chairX"] = 1934.0, ["chairY"] = 3731.0, ["chairZ"] = 32.0, ["chairModel"] = 1165195353, ["chairHeading"] = 30.0},
    [6] = {["x"] = -280.47146606445, ["y"] = 6230.0219726563, ["z"] = 31.695547103882, ["chairX"] = -281.0, ["chairY"] = 6225.0, ["chairZ"] = 31.0, ["chairModel"] = 1165195353, ["chairHeading"] = -130.0}
}

RegisterNetEvent('rpx:playerLoaded')
AddEventHandler('rpx:playerLoaded', function()
    PlayerLoaded()
end)

function PlayerLoaded()
    for id,coords in ipairs(Shops) do
        RPX.Markers.Add('barber_shop_' .. id, coords, 'Tryck ~INPUT_CONTEXT~ för att ändra ditt utseende', function()
            OpenBarber(coords)
        end)

        local blip = AddBlipForCoord(coords["x"], coords["y"], coords["z"])

        SetBlipSprite(blip, 71)
        SetBlipDisplay(blip, 4)
		SetBlipScale(blip, 1.0)
        SetBlipColour(blip, 2)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Frisör")
		EndTextCommandSetBlipName(blip)
    end
end

function OpenBarber(coords)
    Citizen.CreateThread(function()
        local ped = GetPlayerPed(-1)

        RequestAnimDict("misshair_shop@barbers")

        while not HasAnimDictLoaded("misshair_shop@barbers") do
            Citizen.Wait(0)
        end

        local x, y, z, heading = coords["chairX"], coords["chairY"], coords["chairZ"], coords["chairHeading"]

        if coords["chairModel"] ~= nil then
            local object = GetClosestObjectOfType(x, y, z, 1.0, coords["chairModel"], false, false, false)
            local offset = GetOffsetFromEntityInWorldCoords(object, -1.5, 0.1, -0.77)

            x = offset["x"]
            y = offset["y"]
            z = offset["z"]
        end

        coords["chairX"] = x
        coords["chairY"] = y
        coords["chairZ"] = z
        coords["chairHeading"] = heading

        TaskPlayAnimAdvanced(ped, "misshair_shop@barbers", "player_enterchair", x, y, z, 0.0, 0.0, heading, 1000.0, -1000.0, -1, 5642, 0.0, 2, 1)

        Citizen.Wait(3000)

        TaskPlayAnimAdvanced(ped, "misshair_shop@barbers", "player_base", x, y, z, 0.0, 0.0, heading, 1000.0, -1000.0, -1, 5642, 0.0, 2, 1)
        
        OpenBarberShopMenu(coords)
    end)
end

function OpenBarberShopMenu(coords)
    local ped = GetPlayerPed(-1)

    RPX.Character.OpenAppearanceMenu(function()
        local character = RPX.Character.GetCharacter()

        if character["cash"] >= 250 then
            RPX.Menu.Close()
            RPX.Character.UpdateData("cash", character["cash"] - 250)

            ExitBarberShop(coords)
        else
            RPX.ShowNotification("Du har inte råd att köpa detta utseende. ~g~(250 SEK)")
        end
    end, {
        ["sex"] = true,
        ["face"] = true,
        ["skin"] = true,
        ["age_1"] = true,
        ["age_2"] = true,
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
        ["mask_1"] = true,
        ["mask_2"] = true,
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
        ExitBarberShop(coords)
    end)
end

function ExitBarberShop(coords)
    local ped = GetPlayerPed(-1)

    Citizen.CreateThread(function()
        TaskPlayAnimAdvanced(ped, "misshair_shop@barbers", "player_exitchair", coords["chairX"], coords["chairY"], coords["chairZ"], 0.0, 0.0, coords["chairHeading"], 1000.0, -1000.0, 2800, 5642, 0.0, 2, 1)
    end)
end