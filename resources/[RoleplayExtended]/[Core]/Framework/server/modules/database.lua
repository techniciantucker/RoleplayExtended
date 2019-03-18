RPX.SQL = {}
RPX.SQL.Sync = {}
RPX.SQL.Async = {}
RPX.SQL.SafeParameters = function(parameters)
    if parameters == nil then
        return {["_dummy"] = "1"}
    end

    assert(type(parameters) == "table", "A table is expected")
    assert(parameters[1] == nil, "Parameters should not be an array, but a map (key / value pair) instead")

    if next(parameters) == nil then
        return {["_dummy"] = "1"}
    end

    return parameters
end

RPX.SQL.SafeCallback = function(callback)
    if callback == nil then
        return function()
            --Successful SQL execution
        end
    end

    assert(type(callback) == "function", "A function is expected")

    return callback
end

RPX.SQL.Sync.Execute = function(query, parameters)
    assert(type(query) == "string", "SQL query must be a string")

    return exports["Framework"]:mysql_sync_execute(query, RPX.SQL.SafeParameters(parameters))
end

RPX.SQL.Sync.FetchAll = function(query, parameters)
    assert(type(query) == "string", "SQL query must be a string")

    return exports["Framework"]:mysql_sync_fetch_all(query, RPX.SQL.SafeParameters(parameters))
end

RPX.SQL.Sync.FetchScalar = function(query, parameters)
    assert(type(query) == "string", "SQL query must be a string")

    return exports["Framework"]:mysql_sync_fetch_scalar(query, RPX.SQL.SafeParameters(parameters))
end

RPX.SQL.Sync.Insert = function(query, parameters)
    assert(type(query) == "string", "SQL query must be a string")

    return exports["Framework"]:mysql_sync_insert(query, RPX.SQL.SafeParameters(parameters))
end

RPX.SQL.Async.Execute = function(query, parameters, callback)
    assert(type(query) == "string", "SQL query must be a string")

    return exports["Framework"]:mysql_execute(query, RPX.SQL.SafeParameters(parameters), RPX.SQL.SafeCallback(callback))
end

RPX.SQL.Async.FetchAll = function(query, parameters, callback)
    assert(type(query) == "string", "SQL query must be a string")

    return exports["Framework"]:mysql_fetch_all(query, RPX.SQL.SafeParameters(parameters), RPX.SQL.SafeCallback(callback))
end

RPX.SQL.Async.FetchScalar = function(query, parameters, callback)
    assert(type(query) == "string", "SQL query must be a string")

    return exports["Framework"]:mysql_fetch_scalar(query, RPX.SQL.SafeParameters(parameters), RPX.SQL.SafeCallback(callback))
end

RPX.SQL.Async.Insert = function(query, parameters, callback)
    assert(type(query) == "string", "SQL query must be a string")

    return exports["Framework"]:mysql_insert(query, RPX.SQL.SafeParameters(parameters), RPX.SQL.SafeCallback(callback))
end

RPX.RegisterCallback("rpx-sql-async:execute", function(source, callback, query, parameters)
    RPX.SQL.Async.Execute(query, parameters, callback)
end)

RPX.RegisterCallback("rpx-sql-async:fetchAll", function(source, callback, query, parameters)
    RPX.SQL.Async.FetchAll(query, parameters, callback)
end)


RPX.RegisterCallback("rpx-sql-async:fetchScalar", function(source, callback, query, parameters)
    RPX.SQL.Async.FetchScalar(query, parameters, callback)
end)


RPX.RegisterCallback("rpx-sql-async:insert", function(source, callback, query, parameters)
    RPX.SQL.Async.Insert(query, parameters, callback)
end)

AddEventHandler('onServerResourceStart', function(resource)
    if resource == "Framework" then
        TriggerEvent('rpx:resourceEnabled')
        
        exports["Framework"]:mysql_configure()

        Citizen.CreateThread(function()
            TriggerEvent('rpx:sqlReady')
        end)
    end
end)