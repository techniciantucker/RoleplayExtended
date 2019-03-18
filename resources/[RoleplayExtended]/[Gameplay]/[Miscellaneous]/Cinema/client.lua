local CinemaActive = false

function IsCinema()
    return CinemaActive
end

function EnterCinema(time)
    if not CinemaActive then
        CinemaActive = true

        Citizen.CreateThread(function()
            local timestamp = GetGameTimer()
            local animation = true
            
            while CinemaActive do
                Citizen.Wait(0)

                if animation then
                    DrawRect(0.0, 0.0, 2.0, (0.2 / time) * (timestamp - GetGameTimer()), 0, 0, 0, math.floor((255 / (time / 2)) * (GetGameTimer() - timestamp)))
                    DrawRect(0.0, 1.0, 2.0, (0.2 / time) * (timestamp - GetGameTimer()), 0, 0, 0, math.floor((255 / (time / 2)) * (GetGameTimer() - timestamp)))

                    if timestamp + time < GetGameTimer() then
                        animation = false
                    end
                else
                    DrawRect(0.0, 0.0, 2.0, 0.2 , 0, 0, 0, 255)
                    DrawRect(0.0, 1.0, 2.0, 0.2, 0, 0, 0, 255)
                end
            end
        end)
    end
end

function ExitCinema(time)
    if CinemaActive then
        CinemaActive = false

        Citizen.CreateThread(function()
            local timestamp = GetGameTimer()
            
            while timestamp + time > GetGameTimer() do
                Citizen.Wait(0)

                DrawRect(0.0, 0.0, 2.0, (0.2 / time) * ((timestamp + time) - GetGameTimer()), 0, 0, 0, math.floor((255 / (time / 2)) * ((timestamp + time) - GetGameTimer())))
                DrawRect(0.0, 1.0, 2.0, (0.2 / time) * ((timestamp + time) - GetGameTimer()), 0, 0, 0, math.floor((255 / (time / 2)) * ((timestamp + time) - GetGameTimer())))
            end
        end)
    end
end