RPX.Data.OpenedDialog = nil
RPX.Dialog = {}
RPX.Dialog.Open = function(settings, callback, returnCallback, closeCallback)
    if settings == nil then
        settings = {}
    end

    RPX.Dialog.Close()
    RPX.Data.OpenedDialog = nil
    
    SendNUIMessage({
        ["event"] = 'dialog',
        ["action"] = 'open',
        ["dialogSettings"] = settings
    })

    RPX.Data.OpenedDialog = {
        ["settings"] = settings,
        ["callback"] = callback,
        ["returnCallback"] = returnCallback,
        ["closeCallback"] = closeCallback,
        ["close"] = function()
            RPX.Dialog.Close()
        end,
    }

    SetNuiFocus(true, true)

    return RPX.Data.OpenedDialog
end

RPX.Dialog.Close = function()
    if RPX.Data.OpenedDialog ~= nil then
        SetNuiFocus(false, false)
        SendNUIMessage({
            ["event"] = 'dialog',
            ["action"] = 'close',
        })

        if RPX.Data.OpenedDialog["closeCallback"] ~= nil then
            RPX.Data.OpenedDialog["closeCallback"](RPX.Data.OpenedDialog)
        end

        RPX.Data.OpenedDialog = nil
    end
end

RegisterNetEvent('Framework:nui:dialogSubmit')
AddEventHandler('Framework:nui:dialogSubmit', function(data)
    if RPX.Data.OpenedDialog ~= nil and RPX.Data.OpenedDialog["callback"] ~= nil then
		RPX.Data.OpenedDialog["callback"](data["input"], RPX.Data.OpenedDialog)
	else
		print("Got NUI menu message but no menu opened?")
	end
end)

RegisterNetEvent('Framework:nui:dialogCancel')
AddEventHandler('Framework:nui:dialogCancel', function(data)
	if RPX.Data.OpenedDialog ~= nil and RPX.Data.OpenedDialog["callback"] ~= nil then
		RPX.Data.OpenedDialog["returnCallback"](RPX.Data.OpenedDialog)
	else
		print("Got NUI menu message but no menu opened?")
	end
end)

local LastMenuInput = 0

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        if RPX.Data.OpenedDialog ~= nil then
            if (IsControlPressed(0, RPX.Keys["ESC"]) or IsControlJustPressed(0, RPX.Keys["BACKSPACE"])) and (GetGameTimer() - LastMenuInput) > 150 then
                TriggerEvent(GetCurrentResourceName() .. ':nui:dialogCancel')

                LastMenuInput = GetGameTimer()
            end
        end
    end
end)