Data.Markers = {}

Markers = {}
Markers.Add = function(id, position, hint, callback, settings)
    local threadId = GetGameTimer()

    if settings == nil then
        settings = {}
    end

    Data.Markers[id] = {
        ["position"] = position,
        ["hint"] = hint, 
        ["callback"] = callback,
        ["markerType"] = settings["markerType"], 
        ["markerColor"] = settings["markerColor"], 
        ["markerSize"] = settings["markerSize"], 
        ["keyboardKey"] = settings["key"],
        ["hidden"] = false,
        ["threadId"] = threadId,
        ["requiredJob"] = settings["requiredJob"]
    }

    local defaultValues = {
        ["position"] = {["x"] = 0.0, ["y"] = 0.0, ["z"] = 0.0},
        ["hint"] = 'Press ~INPUT_CONTEXT~ ...',
        ["markerType"] = 27,
        ["markerColor"] = {0, 0, 255, 100},
        ["markerSize"] = {1.5, 0.5},
        ["keyboardKey"] = "E",
        ["requiredJob"] = "none"
    }

    for k, _ in pairs(defaultValues) do
        if Data.Markers[id][k] == nil then
            Data.Markers[id][k] = defaultValues[k]
        end
    end

    Citizen.CreateThread(function()
        local ped = GetPlayerPed(-1)
        local hintDisplayed = false

        Data.Markers[id]["position"]["z"] = Data.Markers[id]["position"]["z"] - 0.975

        while Data.Markers[id] ~= nil do
            local marker = Data.Markers[id]

            if marker["threadId"] == threadId then
                if Character.GetCharacter()["job"] == marker["requiredJob"] or marker["requiredJob"] == "none" then
                    local coords = GetEntityCoords(ped)
                    local distance = GetDistanceBetweenCoords(coords["x"], coords["y"], coords["z"], marker["position"]["x"], marker["position"]["y"], marker["position"]["z"], true)

                    if distance < marker["markerSize"][1] * 7.5 then
                        DrawMarker(marker["markerType"], marker["position"]["x"], marker["position"]["y"], marker["position"]["z"], 0.0, 0.0, 0.0, 0, 0.0, 0.0, marker["markerSize"][1], marker["markerSize"][1], marker["markerSize"][2], marker["markerColor"][1], marker["markerColor"][2], marker["markerColor"][3], marker["markerColor"][4], false, false, 2, false, false, false, false)
                    end

                    if distance < marker["markerSize"][1] then
                        SetTextComponentFormat('STRING')
                        AddTextComponentString(marker["hint"])
                        DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                        hintDisplayed = true

                        if IsControlJustPressed(0, Keys[marker["keyboardKey"]]) then
                            if marker["callback"] ~= nil then
                                marker["callback"]()
                            end
                        end
                    else
                        if hintDisplayed then
                            SetTextComponentFormat('STRING')
                            AddTextComponentString("")
                            DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                            hintDisplayed = false
                        end

                        if distance > marker["markerSize"][1] * 7.5 then
                            sleep = math.floor(distance * 5)
                        end
                    end

                    Citizen.Wait(sleep)
                else 
                    Citizen.Wait(3000)
                end
            else
                break
            end
        end
    end)
end

Markers.Remove = function(id)
    Data.Markers[id] = nil
end

Markers.Hide = function(id)
    if Data.Markers[id] ~= nil then
        Data.Markers[id]["hidden"] = true
    end
end

Markers.Show = function(id)
    if Data.Markers[id] ~= nil then
        Data.Markers[id]["hidden"] = false
    end
end