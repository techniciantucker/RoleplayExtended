local RPX = nil

Citizen.CreateThread(function()
    Citizen.Wait(1)

    exports["Library"]:AddHook(GetCurrentResourceName(), function(library)
        RPX = library
    end)
end)