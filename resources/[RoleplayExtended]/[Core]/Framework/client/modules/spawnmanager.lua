local tryingToSpawn = false

function FreezeCharacter(state)
    SetPlayerControl(PlayerId(), not state, false)

    local ped = GetPlayerPed(-1)

    if not state then
        if not IsEntityVisible(ped) then
            SetEntityVisible(ped, true)
        end

        if not IsPedInAnyVehicle(ped) then
            SetEntityCollision(ped, true)
        end

        FreezeEntityPosition(ped, false)
        SetPlayerInvincible(PlayerId(), false)
    else
        if IsEntityVisible(ped) then
            SetEntityVisible(ped, false)
        end

        SetEntityCollision(ped, false)
        FreezeEntityPosition(ped, true)
        SetPlayerInvincible(PlayerId(), true)

        if not IsPedFatallyInjured(ped) then
            ClearPedTasksImmediately(ped)
        end
    end
end

function SpawnCharacter()
    Citizen.CreateThread(function()
        local success = false
        local config = {["model"] = GetHashKey('mp_m_freemode_01'), ["x"] = -1037.7535400391, ["y"] = -2737.9216308594, ["z"] = 20.16926574707, ["heading"] = 327.38748168945}
    
        while not success do
            Citizen.Wait(50)
    
            local playerPed = GetPlayerPed(-1)
        
            if playerPed and playerPed ~= -1 then
                if NetworkIsPlayerActive(PlayerId()) then
                    DoScreenFadeOut(500)
    
                    while IsScreenFadingOut() do
                        Citizen.Wait(0)
                    end

                    FreezeCharacter(true)
    
                    RequestModel(config["model"])
    
                    while not HasModelLoaded(config["model"]) do
                        RequestModel(config["model"])
    
                        Citizen.Wait(0)
                    end
    
                    SetPlayerModel(PlayerId(), config["model"])
                    SetModelAsNoLongerNeeded(config["model"])
                    
                    RequestCollisionAtCoord(config["x"], config["y"], config["z"])

                    local ped = GetPlayerPed(-1)
    
                    SetPedDefaultComponentVariation(ped)
                    SetEntityCoordsNoOffset(ped, config["x"], config["y"], config["z"], false, false, false, true)

                    NetworkResurrectLocalPlayer(config["x"], config["y"], config["z"], config["heading"], true, true, false)
    
                    ClearPedTasksImmediately(ped)
                    ClearPlayerWantedLevel(PlayerId())
					RemoveAllPedWeapons(ped)

                    while not HasCollisionLoadedAroundEntity(ped) do
                        Citizen.Wait(0)
                    end
            
                    ShutdownLoadingScreen()
                    DoScreenFadeIn(500)
    
                    while IsScreenFadingIn() do
                        Citizen.Wait(0)
                    end
        
                    FreezeCharacter(false)
            
                    TriggerEvent('playerSpawned', spawn)
    
                    success = true
                end
            end
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)

        local ped = GetPlayerPed(-1)

        if GetEntityHealth(ped) < 1.0 then
            local coords = GetEntityCoords(ped)

            DoScreenFadeOut(500)

            Citizen.Wait(500)

            NetworkResurrectLocalPlayer(table.unpack(coords), GetEntityHeading(ped), true, true, false)
            
            SetEntityCoords(ped, table.unpack(coords))
            SetEntityHealth(ped, GetEntityMaxHealth(ped))
            SetPlayerInvincible(ped, false)
            ClearPedBloodDamage(ped)
            ClearPedTasksImmediately(ped)
            ClearPlayerWantedLevel(PlayerId())
            RemoveAllPedWeapons(ped)

            DoScreenFadeIn(500)
        end
    end
end)