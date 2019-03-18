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

local Shops = {
    [1] = {["x"] = 72.253, ["y"] = -1399.102, ["z"] = 28.375},
    [2] = {["x"] = -703.776, ["y"] = -152.258, ["z"] = 36.415},
    [3] = {["x"] = -167.863, ["y"] = -298.969, ["z"] = 38.733},
    [4] = {["x"] = 428.694, ["y"] = -800.106, ["z"] = 28.491},
    [5] = {["x"] = -829.413, ["y"] = -1073.710, ["z"] = 10.328},
    [6] = {["x"] = -1447.797, ["y"] = -242.461, ["z"] = 48.820},
    [7] = {["x"] = 11.632, ["y"] = 6514.224, ["z"] = 30.877},
    [8] = {["x"] = 123.646, ["y"] = -219.440, ["z"] = 53.557},
    [9] = {["x"] = 1696.291, ["y"] = 4829.312, ["z"] = 41.063},
    [10] = {["x"] = 618.093, ["y"] = 2759.441, ["z"] = 41.088},
    [11] = {["x"] = 1190.550, ["y"] = 2713.441, ["z"] = 37.222},
    [12] = {["x"] = -1193.429, ["y"] = -772.252, ["z"] = 16.324},
    [13] = {["x"] = -3172.496, ["y"] = 1048.133, ["z"] = 19.863},
    [14] = {["x"] = -1108.441, ["y"] = 2708.923, ["z"] = 18.107}
}

RegisterNetEvent('rpx:playerLoaded')
AddEventHandler('rpx:playerLoaded', function()
    PlayerLoaded()
end)

function PlayerLoaded()
    for id,coords in ipairs(Shops) do
        RPX.Markers.Add('clothes_shop_' .. id, {["x"] = coords["x"], ["y"] = coords["y"], ["z"] = coords["z"] + 1.05}, 'Tryck ~INPUT_CONTEXT~ för ändra ditt utseende', function()
            OpenClothesShop()
        end)

        local blip = AddBlipForCoord(coords["x"], coords["y"], coords["z"])

        SetBlipSprite(blip, 73)
        SetBlipDisplay(blip, 4)
		SetBlipScale(blip, 1.0)
        SetBlipColour(blip, 2)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Klädesbutik")
		EndTextCommandSetBlipName(blip)
    end
end

function OpenClothesShop()
    RPX.Menu.Open(
        {
            ["title"] = "Klädbutik",
            ["category"] = "Välj",
            ["elements"] = {
                {["label"] = "Nytt klädesplagg", ["value"] = "new", ["icon"] = "add"},
                {["label"] = "Dina klädesplagg", ["value"] = "owned", ["icon"] = "closet"},
                {["label"] = "Ta bort klädesplagg", ["value"] = "remove", ["icon"] = "cloakroom"},
            }
        },
        function(current, menu)
            menu.close()

            if current["value"] == "new" then
                RPX.Character.OpenAppearanceMenu(function()
                    RPX.Menu.Close()
                    RPX.Dialog.Open(
                        {
                            ["title"] = "Namnge ditt klädesplagg",
                            ["placeholder"] = "Namn på klädesplagg",
                            ["submit"] = "Namnge",
                            ["cancel"] = "Avbryt"
                        },
                        function(name, dialog)
                            dialog.close()
                            
                            local character = RPX.Character.GetCharacter()

                            if character["cash"] >= 250 then
                                local outfit = RPX.Character.GetAppearance()

                                outfit["name"] = name

                                RPX.Server.Invoke({"SQL", "Async", "Execute"}, function()end, "INSERT INTO character_outfits (character_id, outfit) VALUES (@id, @outfit)",
                                    {
                                        ["@id"] = character["id"],
                                        ["@outfit"] = json.encode(outfit)
                                    }
                                )

                                RPX.Character.UpdateData("cash", character["cash"] - 250)
                            else
                                RPX.ShowNotification("Du har inte råd att köpa detta klädesplagg. ~g~(250 SEK)")
                            end
                        end,
                        function(dialog)   
                            dialog.close()
                        end
                    )
                end, {
                    ["sex"] = true,
                    ["face"] = true,
                    ["skin"] = true,
                    ["age_1"] = true,
                    ["age_2"] = true,
                    ["beard_1"] = true,
                    ["beard_2"] = true,
                    ["beard_3"] = true,
                    ["beard_4"] = true,
                    ["hair_1"] = true,
                    ["hair_2"] = true,
                    ["hair_color_1"] = true,
                    ["hair_color_2"] = true,
                    ["eyebrows_1"] = true,
                    ["eyebrows_2"] = true,
                    ["eyebrows_3"] = true,
                    ["eyebrows_4"] = true,
                    ["makeup_1"] = true,
                    ["makeup_2"] = true,
                    ["makeup_3"] = true,
                    ["makeup_4"] = true,
                    ["lipstick_1"] = true,
                    ["lipstick_2"] = true,
                    ["lipstick_3"] = true,
                    ["lipstick_4"] = true
                }, true)
            elseif current["value"] == "owned" then
                OpenWardrobe()
            elseif current["value"] == "remove" then
                OpenRemoveFromWardrobe()
            end
        end,
        function(current, menu)
            menu.close()
        end
    )
end

function OpenWardrobe()
    local character = RPX.Character.GetCharacter()

    RPX.TriggerServerCallback("rpx:fetchOutfits", function(outfits)
        local elements = {}

        for k,v in ipairs(outfits) do
            local outfit = json.decode(v["outfit"])

            table.insert(elements, {["value"] = i, ["label"] = outfit["name"], ["icon"] = "cloakroom", ["outfit"] = outfit, ["outfitIdentifier"] = v["outfit"]})
        end

        RPX.Menu.Open(
            {
                ["title"] = "Klädbutik",
                ["category"] = "Klädesplagg",
                ["elements"] = elements
            },
            function(current, menu)
                Citizen.CreateThread(function()
                    local ped = GetPlayerPed(-1)

                    RPX.PlayAnimation(ped, "oddjobs@basejump@ig_15", "puton_parachute", 
                        {
                            ["speed"] = 1.0
                        }
                    )

                    Citizen.Wait(3000)

                    RPX.Character.UpdateAppearance(current["outfit"])
                end)
            end,
            function(current, menu)
                menu.close()

                OpenClothesShop()
            end
        )
    end, character["id"])
end

function OpenRemoveFromWardrobe()
    local character = RPX.Character.GetCharacter()

    RPX.TriggerServerCallback("rpx:fetchOutfits", function(outfits)
        local elements = {}

        for k,v in ipairs(outfits) do
            local outfit = json.decode(v["outfit"])

            table.insert(elements, {["value"] = i, ["label"] = outfit["name"], ["icon"] = "cloakroom", ["outfitIdentifier"] = v["outfit"], ["outfit_id"] = v["id"]})
        end

        RPX.Menu.Open(
            {
                ["title"] = "Klädbutik",
                ["category"] = "Dina klädesplagg",
                ["elements"] = elements
            },
            function(current, menu)
                OpenConfirmationMenu("Vill du ta bort " .. current["label"] .. "?", function(input)
                    if input then
                        RPX.Server.Invoke({"SQL", "Sync", "Execute"}, function()end, "DELETE FROM character_outfits WHERE id = @id",
                            {
                                ["@id"] = current["outfit_id"],
                            }
                        )
                    end

                    OpenRemoveFromWardrobe()
                end)
            end,
            function(current, menu)
                menu.close()

                OpenClothesShop(id)
            end
        )
    end, character["id"])
end

function OpenConfirmationMenu(title, callback)
    RPX.Menu.Open(
        {
            ["title"] = "Klädbutik",
            ["category"] = title,
            ["elements"] = {
                {["value"] = "yes", ["label"] = "Ja", ["icon"] = "checked"},
                {["value"] = "no", ["label"] = "Nej", ["icon"] = "delete-sign"}
            }
        },
        function(current, menu)
            callback(current["value"] == "yes")
        end,
        function(current, menu)
            menu.close()

            OpenRemoveFromWardrobe()
        end
    )
end