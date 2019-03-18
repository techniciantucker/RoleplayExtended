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

local Office = {
    [1] = {["x"] = -139.53143310547, ["y"] = -631.86102294922, ["z"] = 168.82040405273, ["heading"] = 191.21754455566}
}

function PlayerLoaded()
    RPX.Markers.Add("corporations_create", Office[1], "Tryck ~INPUT_CONTEXT~ för att starta ett företag", function()
        CreateCorporation()
    end)
end

function CreateCorporation()
    
end