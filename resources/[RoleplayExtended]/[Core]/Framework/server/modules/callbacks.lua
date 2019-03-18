RPX.Data.Callbacks = {}
RPX.RegisterCallback = function(id, callback)
    table.insert(RPX.Data.Callbacks, {["id"] = id, ["callback"] = callback})
end

RegisterServerEvent('rpx:serverCallback')
AddEventHandler('rpx:serverCallback', function(id, trackId, source, ...)
    for i=1, #RPX.Data.Callbacks, 1 do
        local callback = RPX.Data.Callbacks[i]

        if callback["id"] == id then
            callback["callback"](source, function(...)
                TriggerClientEvent('rpx:callbackResponse', source, trackId, ...)
            end, ...)
        end
    end
end)