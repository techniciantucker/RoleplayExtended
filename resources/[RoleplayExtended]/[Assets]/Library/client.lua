local hooks = {}

function AddHook(resource, callback)
    if hooks[resource] ~= nil then
        print("[RPX] Overwriting RPX hook for " .. resource)
    end

    hooks[resource] = callback

    Citizen.CreateThread(function()
        local library = nil

        while library == nil do
            Citizen.Wait(10)
            
            TriggerEvent('rpx:getLibrary', function(response)
                library = response
            end)
        end

        callback(library)
    end)
end

function PushUpdate()
    Citizen.CreateThread(function()
        local library = nil

        while library == nil do
            Citizen.Wait(10)
            
            TriggerEvent('rpx:getLibrary', function(response)
                library = response
            end)
        end
        
        for resource,callback in pairs(hooks) do
            if not pcall(callback, library) then
				print("[RPX-Library] " .. resource .. " library callback could not be called.")
			end
        end
    end)
end

RegisterNetEvent('rpx:resourceStarted')
AddEventHandler('rpx:resourceStarted', function()
    PushUpdate()
end)