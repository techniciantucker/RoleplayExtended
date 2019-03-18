Keys = {
    ["ESC"] = 322,
    ["F1"] = 288,
    ["F2"] = 289,
    ["F3"] = 170,
    ["F5"] = 166,
    ["F6"] = 167,
    ["F7"] = 168,
    ["F8"] = 169,
    ["F9"] = 56,
    ["F10"] = 57,
    ["~"] = 243,
    ["1"] = 157,
    ["2"] = 158,
    ["3"] = 160,
    ["4"] = 164,
    ["5"] = 165,
    ["6"] = 159,
    ["7"] = 161,
    ["8"] = 162,
    ["9"] = 163,
    ["-"] = 84,
    ["="] = 83,
    ["BACKSPACE"] = 177,
    ["TAB"] = 37,
    ["Q"] = 44,
    ["W"] = 32,
    ["E"] = 38,
    ["R"] = 45,
    ["T"] = 245,
    ["Y"] = 246,
    ["U"] = 303,
    ["P"] = 199,
    ["["] = 39,
    ["]"] = 40,
    ["ENTER"] = 18,
    ["CAPS"] = 137,
    ["A"] = 34,
    ["S"] = 8,
    ["D"] = 9,
    ["F"] = 23,
    ["G"] = 47,
    ["H"] = 74,
    ["K"] = 311,
    ["L"] = 182,
    ["LEFTSHIFT"] = 21,
    ["Z"] = 20,
    ["X"] = 73,
    ["C"] = 26,
    ["V"] = 0,
    ["B"] = 29,
    ["N"] = 249,
    ["M"] = 244,
    [","] = 82,
    ["."] = 81,
    ["LEFTCTRL"] = 36,
    ["LEFTALT"] = 19,
    ["SPACE"] = 22,
    ["RIGHTCTRL"] = 70,
    ["HOME"] = 213,
    ["PAGEUP"] = 10,
    ["PAGEDOWN"] = 11,
    ["DELETE"] = 178,
    ["LEFT"] = 174,
    ["RIGHT"] = 175,
    ["TOP"] = 27,
    ["DOWN"] = 173,
    ["NENTER"] = 201,
    ["N4"] = 108,
    ["N5"] = 60,
    ["N6"] = 107,
    ["N+"] = 96,
    ["N-"] = 97,
    ["N7"] = 117,
    ["N8"] = 61,
    ["N9"] = 118
}

ESX = nil
Player = nil
Cost = 1000
VaultCache = {}
Locations = {
    Bank = {
        Purchase = { ["x"] = 253.11, ["y"] = 219.94, ["z"] = 106.29 },
        Vault = { ["x"] = 263.19, ["y"] = 221.03, ["z"] = 101.68 }
    }
}

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(100)

        TriggerEvent("esx:getSharedObject", function(library)
            ESX = library
        end)
    end

    if ESX.IsPlayerLoaded() then
        OnLoad()
    end
end)

AddEventHandler('skinchanger:modelLoaded', function(model)
    OnLoad()
end)

function OnLoad()
    Player = ESX.GetPlayerData()

    ESX.TriggerServerCallback("Bank.Deposit.FetchCache", function(cache)
        if cache == nil then
            ESX.UI.Menu.CloseAll()

            Markers.Add("Bank.Deposit.Purchase", Locations.Bank.Purchase, "Tryck ~INPUT_CONTEXT~ för att köpa ett bankfack.", function()
                ESX.UI.Menu.Open("default", GetCurrentResourceName(), "Bank_Deposit_Purchase",
                    {
                        title = "Köp bankfack (" .. Cost .. " SEK)",
                        align = "top-left",
                        elements = {
                            { label = "Köp för " .. Cost .. " SEK", value = "purchase" },
                            { label = "Avbryt", value = "cancel" }
                        }
                    },
                    function(data, menu)
                        menu.close()

                        if data.current.value == "purchase" then
                            ESX.TriggerServerCallback("Bank.Deposit.Purchase", function(response)
                                if response == 0 then
                                    ESX.ShowNotification("Du köpte ett bankfack för " .. Cost .. " SEK")

                                    UnlockVault()
                                elseif response == 1 then
                                    ESX.ShowNotification("Du har inte " .. Cost .. " SEK på ditt bankkonto!")
                                elseif response == 2 then
                                    ESX.ShowNotification("Du har redan ett bankfack!")
                                end
                            end, Cost)
                        end
                    end,
                    function(data, menu)
                        menu.close()
                    end)
            end)
        else
            VaultCache = cache
            UnlockVault()

            Markers.Remove("Bank.Deposit.Purchase")
        end
    end)
end

function UnlockVault()
    Markers.Add("Bank.Deposit.Vault", Locations.Bank.Vault, "Tryck ~INPUT_CONTEXT~ för att öppna ditt bankfack.", function()
        OpenVault()
    end)
end

function OpenVault()
    local elements = {}

    for k, v in pairs(VaultCache) do
        if v["amount"] > 0 then
            table.insert(elements, { value = k, amount = v["amount"], label = v["label"] .. " x" .. v["amount"] })
        end
    end

    table.insert(elements, { label = "Lägg in föremål", value = "__add" })

    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "Bank_Deposit_Vault",
        {
            title = "Ditt bankfack",
            align = "top-left",
            elements = elements
        },
        function(data, menu)
            menu.close()

            if data.current.value == "__add" then
                OpenInventory(function(item, label, amount)
                    ESX.TriggerServerCallback("Bank.Deposit.RemoveItem", function(response)
                        if response == 0 then
                            local existing = VaultCache[item]

                            if existing ~= nil and existing["amount"] ~= nil then
                                existing = tonumber(existing["amount"])
                            else
                                existing = 0
                            end

                            VaultCache[item] = { ["label"] = label, ["amount"] = existing + amount }

                            TriggerServerEvent("Bank.Deposit.UpdateCache", GetPlayerServerId(PlayerId()), json.encode(VaultCache))
                        else
                            ESX.ShowNotification("Ogiltig antal.")
                        end

                        OpenVault()
                    end, item, amount)
                end, function()
                    OpenVault()
                end)
            else
                RetrieveItem(data.current.value, data.current.amount)
            end
        end,
        function(data, menu)
            menu.close()
        end)
end

function RetrieveItem(item, itemAmount)
    if itemAmount > 1 then
        ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "Bank_Deposit_Inventory_Retrieve_Amount",
            {
                title = "Antal?"
            },
            function(data, menu)
                menu.close()

                local amount = tonumber(data.value)

                if amount == nil or amount > itemAmount then
                    ESX.ShowNotification("Ogiltigt antal.")

                    OpenVault()
                else
                    VaultCache[item]["amount"] = VaultCache[item]["amount"] - amount

                    TriggerServerEvent("Bank.Deposit.AddItem", GetPlayerServerId(PlayerId()), item, amount)
                    TriggerServerEvent("Bank.Deposit.UpdateCache", GetPlayerServerId(PlayerId()), json.encode(VaultCache))
                end
            end,
            function(data, menu)
                OpenVault()
            end)
    else
        VaultCache[item]["amount"] = VaultCache[item]["amount"] - 1

        TriggerServerEvent("Bank.Deposit.AddItem", GetPlayerServerId(PlayerId()), item, 1)
        TriggerServerEvent("Bank.Deposit.UpdateCache", GetPlayerServerId(PlayerId()), json.encode(VaultCache))
    end
end

function OpenInventory(submitFunc, cancelFunc)
    local elements = {}

    ESX.TriggerServerCallback("Bank.Deposit.FetchInventory", function(inventory)
        for k, v in pairs(inventory) do
            if v["count"] > 0 then
                table.insert(elements, { label = v["label"] .. " x" .. v["count"], itemLabel = v["label"], value = v["name"], amount = v["count"] })
            end
        end

        ESX.UI.Menu.CloseAll()
        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "Bank_Deposit_Inventory",
            {
                title = "Din ryggsäck",
                align = "top-left",
                elements = elements
            },
            function(data, menu)
                menu.close()

                if data.current.amount > 1 then
                    local item = data.current.value
                    local label = data.current.itemLabel

                    ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "Bank_Deposit_Inventory_Amount",
                        {
                            title = "Antal?"
                        },
                        function(data, menu)
                            menu.close()

                            local amount = tonumber(data.value)

                            if amount == nil then
                                ESX.ShowNotification("Ogiltigt antal.")

                                OpenInventory(submitFunc, cancelFunc)
                            else
                                submitFunc(item, label, amount)
                            end
                        end,
                        function(data, menu)
                            OpenInventory(submitFunc, cancelFunc)
                        end)
                else
                    submitFunc(data.current.value, data.current.itemLabel, 1)
                end
            end,
            function(data, menu)
                menu.close()

                cancelFunc()
            end)
    end)
end