local RPX = nil

Citizen.CreateThread(function()
    Citizen.Wait(1)

    exports["Library"]:AddHook(GetCurrentResourceName(), function(library)
        RPX = library

        if RPX.IsLoaded then
            PlayerLoaded()
        end
    end)
end)

RegisterNetEvent("rpx:playerLoaded")
AddEventHandler("rpx:playerLoaded", function()
    PlayerLoaded()
end)

local CurrentCameraIdentifier = -1

function PlayerLoaded()
    RPX.Markers.Add("police_securitycameras", {["x"] = 439.34512329102, ["y"] = -995.18176269531, ["z"] = 30.689615249634}, "Tryck ~INPUT_CONTEXT~ för att kolla på övervakningskamerorna", function()
        CurrentCameraIdentifier = -1

        OpenSecurityCamerasMenu()
    end, 
        {
            ["requiredJob"] = "police"
        }
    )
end

local SecurityCameras = {
    [1] = {
        ["name"] = "Fleeca_Bank_Outside.cam",
        ["destroyed"] = false,
        ["object"] = {
            ["x"] = -2967.0,
            ["y"] = 485.0,
            ["z"] = 18.0,
            ["model"] = 168901740
        },
        ["view"] = {
            ["x"] = -2966.9799804688,
            ["y"] = 485.49438476563, 
            ["z"] = 17.908039093018, 
            ["rotationX"] = -16.031496062875, 
            ["rotationY"] = 0.0, 
            ["rotationZ"] = 128.06299164891
        }
    },
    [2] = {
        ["name"] = "Fleeca_Bank_Outside_Back.cam",
        ["destroyed"] = false,
        ["object"] = {
            ["x"] = -2957.0,
            ["y"] = 487.0,
            ["z"] = 18.0,
            ["model"] = 168901740
        },
        ["view"] = {
            ["x"] = -2956.2297363281, 
            ["y"] = 487.68551635742, 
            ["z"] = 17.863878250122, 
            ["rotationX"] = -9.2283466309309, 
            ["rotationY"] = 0.0, 
            ["rotationZ"] = -318.26771599054
        }
    },
    [3] = {
        ["name"] = "Fleeca_Bank_Inside_01.cam",
        ["destroyed"] = false,
        ["object"] = {
            ["x"] = -2963.0,
            ["y"] = 486.0,
            ["z"] = 17.0,
            ["model"] = -1007354661
        },
        ["view"] = {
            ["x"] = -2962.2458496094, 
            ["y"] = 486.12777709961, 
            ["z"] = 17.196931838989, 
            ["rotationX"] = -8.7559050023556, 
            ["rotationY"] = 0.0, 
            ["rotationZ"] = -208.9448825866
        }
    },
    [4] = {
        ["name"] = "Fleeca_Bank_Inside_02.cam",
        ["destroyed"] = true,
        ["object"] = {
            ["x"] = -2959.2543945313,
            ["y"] = 476.54400634766,
            ["z"] = 17.783708572388,
            ["model"] = -1007354661
        },
        ["view"] = {
            ["x"] = -2961.212890625,
            ["y"] = 476.43661499023, 
            ["z"] = 17.691980361938, 
            ["rotationX"] = -15.055117681623, 
            ["rotationY"] = 0.0, 
            ["rotationZ"] = -303.49606262147
        }
    },
    [5] = {
        ["name"] = "Fleeca_Bank_Inside_03.cam",
        ["destroyed"] = false,
        ["object"] = {
            ["x"] = -2961.1840820313, 
            ["y"] = 476.48550415039, 
            ["z"] = 17.646097183228,
            ["model"] = -1007354661
        },
        ["view"] = {
            ["x"] = -2959.5166015625, 
            ["y"] = 476.6106262207, 
            ["z"] = 17.691980361938, 
            ["rotationX"] = -5.6062990576029, 
            ["rotationY"] = 0.0, 
            ["rotationZ"] = -23.307087048888
        }
    }
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local ped = GetPlayerPed(-1)

        if IsPedShooting(ped) then
            local entity = PerformRaycast()

            if entity ~= nil and entity ~= 0 and DoesEntityExist(entity) then
                for id,values in ipairs(SecurityCameras) do
                    local model = values["object"]["model"]
                    local object = GetClosestObjectOfType(values["object"]["x"], values["object"]["y"], values["object"]["z"], 1.0, model, false)

                    if GetEntityModel(entity) == model and object == entity then
                        print("Shot the camera: " .. values["name"])
                    end
                end
            end
        end
    end
end)

function OpenSecurityCamerasMenu()
    RPX.Menu.Open(
        {
            ["title"] = "Polisen",
            ["category"] = "Kameror",
            ["elements"] = {
                {["label"] = "Fleeca Bank", ["value"] = "fleeca_bank", ["icon"] = "museum"},
            }
        },
        function(current, menu)
            menu.close()

            if current["value"] == "fleeca_bank" then
                OpenFleecabankSecurityCameraMenu()
            end
        end,
        function(current, menu)
            menu.close()
            
            Citizen.CreateThread(function()
                local ped = GetPlayerPed(-1)

                if CurrentCameraIdentifier ~= -1 then
                    DoScreenFadeOut(1000)

                    Citizen.Wait(1000)

                    DetachCam()

                    Citizen.Wait(500)

                    DoScreenFadeIn(3000)
                end

                ClearTimecycleModifier("scanline_cam_cheap")
                SetFocusEntity(GetPlayerPed(-1))
            
                RPX.ToggleHUD(true)

                CurrentCameraIdentifier = -1
            end)
        end
    )
end

function OpenFleecabankSecurityCameraMenu()
    local elements = {}

    for k,v in ipairs(SecurityCameras) do
        if RPX.String.StartsWith(v["name"], "Fleeca_Bank") then
            table.insert(elements, {["label"] = v["name"], ["value"] = k, ["icon"] = "wallmount-camera-filled"})
        end
    end

    RPX.Menu.Open(
        {
            ["title"] = "Polisen",
            ["category"] = "Fleeca Bank",
            ["elements"] = elements
        },
        function(current, menu)
            CurrentCameraIdentifier = current["value"]

            ConnectToCamera()
        end,
        function(current, menu)
            menu.close()

            OpenSecurityCamerasMenu()
        end
    )
end

function ConnectToCamera()
    local camera = SecurityCameras[CurrentCameraIdentifier]

    CameraConnection(camera, function()
        ViewCamera(camera)  
    end)
end

function ViewCamera(camera)
    Citizen.CreateThread(function()
        DoScreenFadeOut(1000)

        Citizen.Wait(1000)

        local ped = GetPlayerPed(-1)

        DetachCam()
        AttachCam(camera["view"])
    
        SetTimecycleModifier("scanline_cam_cheap")
        SetTimecycleModifierStrength(2.0)
        StopScreenEffect("DeathFailOut")
        SetFocusArea(camera["view"]["x"], camera["view"]["y"], camera["view"]["z"], camera["view"]["x"], camera["view"]["y"], camera["view"]["z"])

        RPX.ToggleHUD(false)
    
        Citizen.Wait(500)
    
        DoScreenFadeIn(1000)
    end)
end

function ViewBrokenCamera()
    Citizen.CreateThread(function()
        DoScreenFadeOut(1000)

        Citizen.Wait(1000)

        local ped = GetPlayerPed(-1)

        DetachCam()
        AttachCam({["x"] = 442.50833129883, ["y"] = -989.98675537109, ["z"] = 32.539577484131, ["rotationX"] = -10.92913377285, ["rotationY"] = 0.0, ["rotationZ"] = -226.64566931129})
    
        Citizen.Wait(500)
    
        DoScreenFadeIn(1000)
    end)
end

function CameraConnection(camera, callback)
    local ScaleformMovie = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")
    local EstablishingDots = 0
    local Timestamp = GetGameTimer()
    local State = "Connecting"

    Citizen.CreateThread(function()
        while SecurityCameras[CurrentCameraIdentifier] ~= nil and SecurityCameras[CurrentCameraIdentifier]["name"] == camera["name"] do
            Citizen.Wait(0)

            if EstablishingDots == 4 and State == "Connecting" then
                if not camera["destroyed"] then
                    callback()

                    Citizen.CreateThread(function()
                        Citizen.Wait(1000)
                        
                        State = "Success"
                    end)
                else
                    Citizen.CreateThread(function()
                        Citizen.Wait(1000)
                        
                        State = "Failure"
                    end)

                    ViewBrokenCamera()
                end
            else
                if HasScaleformMovieLoaded(ScaleformMovie) then
                    PushScaleformMovieFunction(ScaleformMovie, "SHOW_SHARD_WASTED_MP_MESSAGE")

                    if State == "Failure" then
                        StartScreenEffect("DeathFailOut", 0, 0)

                        PushScaleformMovieFunctionParameterString("~r~Anslutningsfel")
                        PushScaleformMovieFunctionParameterString("Kunde inte etablera en anslutning till ~r~" .. camera["name"])
                    elseif State == "Success" then
                        StopScreenEffect("DeathFailOut")

                        PushScaleformMovieFunctionParameterString("~r~Ansluten")
                        PushScaleformMovieFunctionParameterString("Ansluten till ~r~" .. camera["name"])
                    elseif State == "Connecting" then
                        local extra = ""

                        if Timestamp + 1000 <= GetGameTimer() then
                            EstablishingDots = EstablishingDots + 1
            
                            Timestamp = GetGameTimer()
                        end

                        if EstablishingDots == 1 then
                            extra = "."
                        elseif EstablishingDots == 2 then
                            extra = ".."
                        elseif EstablishingDots == 3 then
                            extra = "..."
                        end

                        PushScaleformMovieFunctionParameterString("~r~Ansluter" .. extra)
                        PushScaleformMovieFunctionParameterString("Etablerar en anslutning till ~r~" .. camera["name"])
                    end

                    PopScaleformMovieFunctionVoid()
                end

                DrawScaleformMovie(ScaleformMovie, 0.5, 0.93, 1.0, 1.0, 255, 255, 255, 100, 0)
            end
        end
    end)
end

local AttachedCamera = nil

function AttachCam(coords)
    if AttachedCamera ~= nil then
		RPX.DetachCam()
	end

	local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
					
	SetCamCoord(cam, coords["x"], coords["y"], coords["z"])
	SetCamRot(cam, coords["rotationX"], coords["rotationY"], coords["rotationZ"])
	SetCamActive(cam, true)
	
	RenderScriptCams(true, false, 0, true, true)
    
    AttachedCamera = cam
end

function DetachCam()
    if AttachedCamera ~= nil and DoesCamExist(AttachedCamera) then
        RenderScriptCams(false, false, 0, 1, 0)
		DestroyCam(AttachedCamera)

		AttachedCamera = nil
    end
end

function PerformRaycast()
    local ped = GetPlayerPed(-1)
    local rayhandle = CastRayPointToPoint(GetGameplayCamCoord(), GetGameplayCamCoord() + RotationAnglesToVector(GetGameplayCamRot(2)) * 200.0, 16, ped, 0)
    local statusint, hit, endcoords, surfacenormal, entityhandle = GetRaycastResult(rayhandle)
    
    return entityhandle
end

function RotationAnglesToVector(rotations)
	local z = math.rad(rotations["z"])
	local x = math.rad(rotations["x"])
    local num = math.abs(math.cos(x))

    return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end