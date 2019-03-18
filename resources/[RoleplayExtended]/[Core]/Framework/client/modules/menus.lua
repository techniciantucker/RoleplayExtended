--[[RPX.Data.OpenedMenu = nil
RPX.Menu = {}
RPX.Menu.Open = function(settings, callback, returnCallback, closeCallback, updateCallback)
    if settings == nil then
        settings = {}
    end

    RPX.Menu.Close()
    RPX.Data.OpendMenu = nil
    
    SendNUIMessage({
        ["event"] = 'menu',
        ["action"] = 'open',
        ["menuId"] = id,
        ["menuSettings"] = settings
    })

    RPX.Data.OpenedMenu = {
        ["id"] = id,
        ["settings"] = settings,
        ["callback"] = callback,
        ["returnCallback"] = returnCallback,
        ["updateCallback"] = updateCallback,
        ["closeCallback"] = closeCallback,
        ["current"] = {["label"] = "", ["value"] = ""},
        ["close"] = function()
            RPX.Menu.Close()
        end,
        ["update"] = function(settings)
            SendNUIMessage({
                ["event"] = 'menu',
                ["action"] = 'update',
                ["menuSettings"] = settings
            })
        end
    }

    if settings["elements"] ~= nil and #settings["elements"] > 0 then
        RPX.Data.OpenedMenu["current"] = settings["elements"][1]
    end

    return RPX.Data.OpenedMenu
end

RPX.Menu.Close = function()
    if RPX.Data.OpenedMenu ~= nil then
        SendNUIMessage({
            ["event"] = 'menu',
            ["action"] = 'close',
        })

        if RPX.Data.OpenedMenu["closeCallback"] ~= nil then
            RPX.Data.OpenedMenu["closeCallback"](RPX.Data.OpenedMenu["current"], RPX.Data.OpenedMenu)
        end

        RPX.Data.OpenedMenu = nil
    end
end

RegisterNetEvent('Framework:nui:updateMenuItem')
AddEventHandler('Framework:nui:updateMenuItem', function(data)
	if RPX.Data.OpenedMenu ~= nil then
		RPX.Data.OpenedMenu["current"] = data

		if RPX.Data.OpenedMenu["updateCallback"] ~= nil then
			RPX.Data.OpenedMenu["updateCallback"](RPX.Data.OpenedMenu["current"], RPX.Data.OpenedMenu)
		end 
	else
		print("Got NUI menu message but no menu opened?")
	end
end)

RegisterNetEvent('Framework:nui:clickMenuItem')
AddEventHandler('Framework:nui:clickMenuItem', function()
	if RPX.Data.OpenedMenu ~= nil then
		if RPX.Data.OpenedMenu["callback"] ~= nil then
			RPX.Data.OpenedMenu["callback"](RPX.Data.OpenedMenu["current"], RPX.Data.OpenedMenu)
		end
	else
		print("Got NUI menu message but no menu opened?")
	end
end)

RegisterNetEvent('Framework:nui:returnMenu')
AddEventHandler('Framework:nui:returnMenu', function()
	if RPX.Data.OpenedMenu ~= nil then
        if RPX.Data.OpenedMenu["returnCallback"] ~= nil then
            if not pcall(RPX.Data.OpenedMenu["returnCallback"], RPX.Data.OpenedMenu["current"], RPX.Data.OpenedMenu) then
                print("Error while calling return callback.")

                RPX.Data.OpenedMenu.close()
            end
		end
	else
		print("Got NUI menu message but no menu opened?")
	end
end)

local LastMenuInput = 0

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        if RPX.Data.OpenedMenu ~= nil then
            if IsControlPressed(0, RPX.Keys["TOP"]) and (GetGameTimer() - LastMenuInput) > 150 then
                SendNUIMessage({
                    ["event"] = 'menu',
                    ["action"] = 'keyinput',
                    ["key"] = 'UP'
                })

                LastMenuInput = GetGameTimer()
            end

            if IsControlPressed(0, RPX.Keys["DOWN"]) and (GetGameTimer() - LastMenuInput) > 150 then
                SendNUIMessage({
                    ["event"] = 'menu',
                    ["action"] = 'keyinput',
                    ["key"] = 'DOWN'
                })

                LastMenuInput = GetGameTimer()
            end

            if IsControlPressed(0, RPX.Keys["ENTER"]) and (GetGameTimer() - LastMenuInput) > 150 then
                TriggerEvent(GetCurrentResourceName() .. ':nui:clickMenuItem')

                LastMenuInput = GetGameTimer()
            end

            if (IsControlPressed(0, RPX.Keys["ESC"]) or IsControlJustPressed(0, RPX.Keys["BACKSPACE"])) and (GetGameTimer() - LastMenuInput) > 150 then
                TriggerEvent(GetCurrentResourceName() .. ':nui:returnMenu')

                LastMenuInput = GetGameTimer()
            end
        end
    end
end)]]

RPX.Menu = {}
RPX.Menu.Open = function(settings, callback, close, update, response)
    exports["NativeMenus"]:OpenMenu(settings, callback, close, update, function(menu)
        if response ~= nil then
            response(menu)
        end
    end)
end

RPX.Menu.Close = function()
    exports["NativeMenus"]:CloseMenu()
end