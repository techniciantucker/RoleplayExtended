local radar = false
local talkerProximities = {
	["default"] = 5.0,
	["shout"] = 25.0,
	["whisper"] = 1.0,
	["current"] = "default"
}

RegisterNetEvent('rpx:playerLoaded')
AddEventHandler('rpx:playerLoaded', function()
	Citizen.CreateThread(function()
		while RPX == nil do
			Citizen.Wait(0)
		end

		RPX.IsLoaded = true
		RPX.Server.Invoke("GetCommands", function(commands)
			for i=1, #commands, 1 do
				local command = commands[i]
		
				TriggerEvent('chat:addSuggestion', "/" .. command["command"], command["display"], {})
			end
		end)

		local ped = GetPlayerPed(-1)
	
		DisplayRadar(false)
	
		while true do
			Citizen.Wait(0)
			
			HideHudComponentThisFrame(14)
	
			local inVehicle = IsPedInAnyVehicle(GetPlayerPed(-1), -1)
	
			if inVehicle and not radar then
				DisplayRadar(true)
	
				radar = true
			elseif not inVehicle and radar then
				radar = false
	
				DisplayRadar(false)
			end
	
			if not cinema and RPX.Data.HUD then
				DrawOutline()
				DrawHealth()
				DrawArmor()
				DrawTalkerProximity()
	
				if inVehicle then
					DrawVehicleHud()
				end
			end
	
			if IsControlJustPressed(1, RPX.Keys["H"]) and IsControlPressed(1, RPX.Keys["LEFTSHIFT"]) then
				if talkerProximities["current"] == "default" then
					NetworkSetTalkerProximity(talkerProximities["shout"])

					talkerProximities["current"] = "shout"
				elseif talkerProximities["current"] == "shout" then
					NetworkSetTalkerProximity(talkerProximities["whisper"])

					talkerProximities["current"] = "whisper"
				elseif talkerProximities["current"] == "whisper" then
					NetworkSetTalkerProximity(talkerProximities["default"])

					talkerProximities["current"] = "default"
				end
			end
	
			local coords = GetEntityCoords(GetPlayerPed(-1))
			
			ClearAreaOfCops(coords["x"], coords["y"], coords["z"], 100.0, 0)
	
			if GetPlayerWantedLevel(PlayerId()) ~= 0 then
				SetPlayerWantedLevel(PlayerId(), 0, false)
				SetPlayerWantedLevelNow(PlayerId(), false)
				SetPlayerWantedLevelNoDrop(PlayerId(), 0, false)
			end

			for i=1, 12, 1 do
				EnableDispatchService(i, false)
			end
			
			DisablePlayerVehicleRewards(PlayerId())
		end
	end)
end)

function PlayerSpawnHandler()
	local ped = GetPlayerPed(-1)
	
	if GetEntityHealth(ped) > GetEntityMaxHealth(ped) then
		SetEntityHealth(ped, GetEntityMaxHealth(ped))
	end

	if not RPX.IsLoaded then
		TriggerServerEvent('rpx:playerSpawned', RPX.GetId())
	end
end

AddEventHandler('playerSpawned', function()
	PlayerSpawnHandler()
end)

AddEventHandler('onClientMapStart', function()
	NetworkSetTalkerProximity(talkerProximities[talkerProximities["current"]])
end)

function DrawOutline()
	local padding = 0.005

	DrawObject(0.015 - (padding / 4.25), 0.971 - (padding / 2), 0.141 + (padding / 2), 0.02 + padding, 30, 30, 30)
end

function DrawHealth()
    local ped = GetPlayerPed(-1)
	
	DrawObject(0.015, 0.971, 0.07, 0.0085, 150, 150, 150)
	DrawObject(0.015, 0.971, (0.07 / GetEntityMaxHealth(ped)) * GetEntityHealth(ped), 0.0085, 115, 229, 73)
end

function DrawArmor()
	local ped = GetPlayerPed(-1)

	DrawObject(0.086, 0.971, 0.07, 0.0085, 150, 150, 150)
	DrawObject(0.086, 0.971, (0.07 / 100.0) * GetPedArmour(ped), 0.0085, 24, 110, 249)
end

function DrawTalkerProximity()
	local currentLevel = 0

	if talkerProximities["current"] == "default" then
		currentLevel = 2
	elseif talkerProximities["current"] == "shout" then
		currentLevel = 3
	elseif talkerProximities["current"] == "whisper" then
		currentLevel = 1
	end

	DrawObject(0.015, 0.982, 0.141, 0.0085, 150, 150, 150)

	if NetworkIsPlayerTalking(PlayerId()) then
		DrawObject(0.015, 0.982, (0.141 / 3) * currentLevel, 0.0085, 188, 64, 186)
	else
		DrawObject(0.015, 0.982, (0.141 / 3) * currentLevel, 0.0085, 41, 67, 102)
	end
end

function DrawVehicleHud()
	local speed = math.floor(GetEntitySpeed(GetVehiclePedIsIn(GetPlayerPed(-1), false)) * 3.6)

	DrawObject(0.015, 0.775, 0.141, 0.03, 30, 30, 30)
	DrawTextWithFont("" .. speed, 0.02, 0.7725, 0.5, 255, 255, 255)
	DrawTextWithFont("KM/H", 0.0375, 0.78, 0.35, 255, 255, 255)
end

function DrawObject(x, y, width, height, red, green, blue)
	DrawRect(x + (width / 2.0), y + (height / 2.0), width, height, red, green, blue, 150)
end

function DrawTextWithFont(text, x, y, scale, red, green, blue)
	SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(red, green, blue, 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")

    AddTextComponentString(text)
    DrawText(x, y)
end

RegisterNetEvent('rpx:deleteVehicle')
AddEventHandler('rpx:deleteVehicle', function()
	local ped = GetPlayerPed(-1)
	local coords = GetEntityCoords(ped)

	if IsPedInAnyVehicle(ped, false) then
		local vehicle = GetVehiclePedIsIn(ped, false)

		RPX.DeleteVehicle(vehicle)
	elseif IsAnyVehicleNearPoint(coords["x"], coords["y"], coords["z"], 5.0) then
		local vehicle = GetClosestVehicle(coords["x"], coords["y"], coords["z"],  5.0,  0,  71)
		
		RPX.DeleteVehicle(vehicle)
 	end
end)

RegisterNetEvent('rpx:spawnVehicle')
AddEventHandler('rpx:spawnVehicle', function(arguments)
	if arguments[1] ~= nil then
		local ped = GetPlayerPed(-1)

		RPX.SpawnVehicle(arguments[1], GetEntityCoords(ped), GetEntityHeading(ped), function(vehicle)
			TaskWarpPedIntoVehicle(ped, vehicle, -1)
		end)
	else
		RPX.ShowNotification("Please specify a vehicle model.")
	end
end)

RegisterNetEvent('rpx:cinema')
AddEventHandler('rpx:cinema', function(arguments)
	if not exports["Cinema"]:IsCinema() then
		exports["Cinema"]:EnterCinema(2500)
	else
		exports["Cinema"]:ExitCinema(2500)
	end
end)

RegisterNetEvent('rpx:addItem')
AddEventHandler('rpx:addItem', function(item, amount)
	if item ~= nil and amount ~= nil then
		RPX.AddItem(item, amount, nil)
	else
		RPX.ShowNotification("Please specify an item and an amount.")
	end
end)

RegisterNetEvent('rpx:updateItems')
AddEventHandler('rpx:updateItems', function()
	RPX.LoadItems()
end)

RegisterNetEvent('rpx:nuiStuck')
AddEventHandler('rpx:nuiStuck', function(arguments)
	SetNuiFocus(false, false)

	SendNUIMessage({
		["action"] = "closeAllInstances"
	})
end)

local dev = false

RegisterNetEvent('rpx:devMode')
AddEventHandler('rpx:devMode', function(arguments)
	dev = not dev
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if dev then
			local ped = GetPlayerPed(-1)
			local coords = GetEntityCoords(ped)
			local handle, object = FindFirstObject()
			local success = false
			local closestDistance = 3.1
			local closestPosition = nil
			local closestRotation = nil
			local closestObject = nil

			repeat
				if object ~= nil and GetPlayerPed(-1) ~= object and DoesEntityExist(object) then
					local position = GetEntityCoords(object)
					local rotation = GetEntityRotation(object)
					local distance = GetDistanceBetweenCoords(coords, position, true)

					if distance < 3.0 then
						RPX.DrawWorldText("Object: " .. object .. " Model: " .. GetEntityModel(object) .. " Coords: " .. math.floor(position["x"]) .. ".0, " .. math.floor(position["y"]) .. ".0, " .. math.floor(position["z"]) .. ".0 (" .. rotation["x"] .. ".0,  " .. rotation["y"] .. ".0, "  .. rotation["z"] .. ".0)", position["x"], position["y"], position["z"] + 0.5, 0.2)
						
						if closestDistance > distance then
							closestDistance = distance
							closestPosition = position
							closestRotation = rotation
							closestObject = object
						end
					end
				end

				success, object = FindNextObject(handle)
			until not success do
				EndFindObject(handle)
			
				if closestObject ~= nil and closestPosition ~= nil and closestRotation ~= nil then
					if IsControlJustPressed(0, RPX.Keys["NENTER"]) then
						RPX.Server.Log('{["x"] = ' .. round(closestPosition["x"]) .. ', ["y"] = ' .. round(closestPosition["y"]) .. ', ["z"] = ' .. round(closestPosition["z"]) .. ', ["rotationX"] = ' .. round(closestRotation["x"]) .. ', ["rotationY"] = ' .. round(closestRotation["y"]) .. ', ["rotationZ"] = ' .. round(closestRotation["z"]) .. ', ["model"] = ' .. GetEntityModel(closestObject) .. '}')
					end
				end
			end
		end
	end
end)

function round(number, decimals)
  local mult = 10 ^ (decimals or 0)

  return math.floor(number * mult + 0.5) / mult
end

RegisterNetEvent('rpx:logCoords')
AddEventHandler('rpx:logCoords', function()
	local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
	local heading = GetEntityHeading(GetPlayerPed(-1))

	RPX.Server.Log(string.format('{["x"] = %s, ["y"] = %s, ["z"] = %s, ["heading"] = %s}', x, y, z, heading))
	RPX.Server.Log(string.format('%s, %s, %s, %s', x, y, z, heading))
end)

RegisterNetEvent('rpx:playAnim')
AddEventHandler('rpx:playAnim', function(arguments)
	if arguments[1] ~= nil and arguments[2] ~= nil then
		RPX.PlayAnimation(GetPlayerPed(-1), arguments[1], arguments[2])
	else
		RPX.ShowNotification("Please specify an animation dict and anim.")
	end
end)

RegisterNetEvent('rpx:teleport')
AddEventHandler('rpx:teleport', function(arguments)
	if arguments[1] ~= nil and arguments[2] ~= nil  and arguments[3] ~= nil then
		if type(arguments[1]) == "string" then
			arguments[1] = arguments[1]:gsub(",", "")
		end

		if type(arguments[2]) == "string" then
			arguments[2] = arguments[2]:gsub(",", "")
		end

		if type(arguments[3]) == "string" then
			arguments[3] = arguments[3]:gsub(",", "")
		end

		SetEntityCoords(GetPlayerPed(-1), tonumber(arguments[1]), tonumber(arguments[2]), tonumber(arguments[3]))
	else
		RPX.ShowNotification("Please specify all coordinates.")
	end
end)

RegisterNetEvent('rpx:assignJob')
AddEventHandler('rpx:assignJob', function(arguments)
	local job = arguments[2]
	local grade = arguments[3]

	if job ~= nil and grade then
		RPX.Character.UpdateData("job", job)
		RPX.Character.UpdateData("job_grade", grade)
		RPX.Server.Invoke({"SQL", "Async", "Execute"}, function() end, "UPDATE characters SET job = @job, job_grade = @job_grade WHERE identifier = @identifier AND id = @id", 
			{
				["@identifier"] = RPX.GetIdentifier(),
				["@id"] = RPX.Character.GetCharacter()["id"],
				["@job"] = job,
				["@job_grade"] = grade
			}
		)
	else
		RPX.ShowNotification("~r~Please specify a job and a job grade!")
	end
end)

RegisterNetEvent('rpx:setCash')
AddEventHandler('rpx:setCash', function(amount)
	if amount ~= nil then
		RPX.Character.UpdateData("cash", tonumber(amount))
		RPX.Server.Invoke({"SQL", "Async", "Execute"}, function() end, "UPDATE characters SET cash = @cash WHERE identifier = @identifier AND id = @id", 
			{
				["@identifier"] = RPX.GetIdentifier(),
				["@id"] = RPX.Character.GetCharacter()["id"],
				["@cash"] = tonumber(amount)
			}
		)
	else
		RPX.ShowNotification("~r~Please specify a cash amount!")
	end
end)


RegisterNetEvent('rpx:setBank')
AddEventHandler('rpx:setBank', function(amount)
	if amount ~= nil then
		RPX.Character.UpdateData("bank", tonumber(amount))
		RPX.Server.Invoke({"SQL", "Async", "Execute"}, function() end, "UPDATE characters SET bank = @bank WHERE identifier = @identifier AND id = @id", 
			{
				["@identifier"] = RPX.GetIdentifier(),
				["@id"] = RPX.Character.GetCharacter()["id"],
				["@bank"] = tonumber(amount)
			}
		)
	else
		RPX.ShowNotification("~r~Please specify a bank amount!")
	end
end)


RegisterNetEvent('rpx:characterInfo')
AddEventHandler('rpx:characterInfo', function()
	local character = RPX.Character.GetCharacter()

	print("-------------------")
	print("Firstname | " .. character["firstname"])
	print("Lastname | " .. character["lastname"])
	print("DOB | " .. character["dateofbirth"])
	print("Lastdigits | " .. character["lastdigits"])
	print("Bank | " .. character["bank"])
	print("Cash | " .. character["cash"])
	print("Job | " .. character["job"])
	print("Job Grade | " .. character["job_grade"])
	print("Inventory Weight | " .. RPX.Character.GetInventoryWeight())
	print("Capacity | " .. RPX.Character.GetCapacity())
	print("-------------------")
end)


RegisterNetEvent('rpx:executeCode')
AddEventHandler('rpx:executeCode', function(code)
	load(code)()
end)

RegisterNetEvent('rpx:saveUser')
AddEventHandler('rpx:saveUser', function()
	RPX.ForceSave()
end)

RegisterNetEvent('Framework:nui:notificationDisplayed')
AddEventHandler('Framework:nui:notificationDisplayed', function()
	table.remove(RPX.Data.NotificationQueue, 1)

	RPX.NotificationEnd()
end)

RPX.LoadItems()