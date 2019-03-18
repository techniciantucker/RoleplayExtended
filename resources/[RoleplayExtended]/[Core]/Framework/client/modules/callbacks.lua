RPX.Data.CallbackResponse = {}
RPX.TriggerServerCallback = function(id, response, ...)
    local trackId = GetGameTimer()

    while RPX.Data.CallbackResponse[trackId] ~= nil do
        trackId = trackId + 1
    end

    TriggerServerEvent('rpx:serverCallback', id, trackId, RPX.GetId(), ...)

    if response == nil then
        response = function()
            print("Successfull server callback (" .. id .. " - " .. trackId .. ")")
        end
    end

    RPX.Data.CallbackResponse[trackId] = response
end

RegisterNetEvent('rpx:callbackResponse')
AddEventHandler('rpx:callbackResponse', function(trackId, ...)
    if RPX.Data.CallbackResponse[trackId] ~= nil then
        RPX.Data.CallbackResponse[trackId](...)
        RPX.Data.CallbackResponse[trackId] = nil
    else
        print("Got client callback response, but trackId somehow got lost? (" .. trackId .. ")")
    end
end)