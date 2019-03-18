RegisterNUICallback('__piperesponse', function(response, callback)
    TriggerEvent(response["__event"], response["__data"])

    callback("")
end)