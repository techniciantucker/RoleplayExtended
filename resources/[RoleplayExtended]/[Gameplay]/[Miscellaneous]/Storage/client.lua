local RPX = nil

Citizen.CreateThread(function()
    Citizen.Wait(1)

    exports["Library"]:AddHook(GetCurrentResourceName(), function(library)
        RPX = library
    end)
end)

function OpenStorage(storageOwner, storageName, callback)
    RPX.SQL.Async.FetchAll("SELECT i.label, si.amount FROM storage as s INNER JOIN storage_items as si ON si.storage_id = s.id INNER JOIN items as i ON i.id = si.item_id WHERE s.owner = @owner AND s.`name` = @storageName",
        {
            ["@owner"] = storageOwner,
            ["@storageName"] = storageName
        },
        function(items)
            callback(items)
        end
    )
end