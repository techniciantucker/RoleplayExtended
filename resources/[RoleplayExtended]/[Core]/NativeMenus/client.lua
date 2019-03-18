local RPX = nil

Citizen.CreateThread(function()
    Citizen.Wait(1)

    exports["Library"]:AddHook(GetCurrentResourceName(), function(library)
        RPX = library
    end)
end)

local CurrentMenu = nil
local DefaultOptions = {
    ["menu"] = {
        ["x"] = 0.03,
        ["y"] = 0.1,
        ["selectedIndex"] = 1,
        ["title"] = "Insert title",
        ["category"] = "Category",
        ["color"] = {89, 152, 255},
        ["elements"] = {},
        ["max"] = 8
    },
    ["element"] = {
        ["label"] = "Option",
        ["option"] = "none",
        ["description"] = "none",
        ["descriptions"] = {},
        ["locked"] = false
    }
}

function OpenMenu(settings, submit, close, update, menu)
    if CurrentMenu == nil then
        for setting, value in pairs(DefaultOptions["menu"]) do
            if settings[setting] == nil then
                settings[setting] = value
            end
        end

        if #settings["elements"] == 0 then
            table.insert(settings["elements"], {["label"] = "Tomt. :("})
        end

        for elementIndex = 1, #settings["elements"], 1 do
            local element = settings["elements"][elementIndex]

            for setting, value in pairs(DefaultOptions["element"]) do
                if element[setting] == nil then
                    if type(value) == "table" then
                        element[setting] = RPX.Table.Copy(value)
                    else
                        element[setting] = value
                    end
                end
            end

            if element["description"] ~= "none" then
                local description = element["description"]
                local texts = {}
                local currentText = ""

                for charIndex = 1, string.len(description) do
                    local char = string.sub(description, charIndex, charIndex)
        
                    currentText = currentText .. char
        
                    if GetTextWidth(currentText, 0, 0.4) >= 0.2 then
                        table.insert(texts, currentText)
        
                        currentText = ""
                    end
                end
        
                table.insert(texts, currentText)
        
                local textY = 0.03
        
                for textIndex = 1, #texts, 1 do
                    local text = texts[textIndex]

                    table.insert(element["descriptions"], {["text"] = text, ["y"] = textY})

                    textY = textY + 0.02
                end
            end
        end

        local LastMenuInput = 0
        local threadId = GetGameTimer()

        CurrentMenu = {
            ["settings"] = settings,
            ["submitResponse"] = submit, 
            ["closeResponse"] = close, 
            ["updateResponse"] = update, 
            ["thread"] = threadId, 
            ["close"] = function()
                CloseMenu()
            end, 
            ["update"] = function(elements)
                for elementIndex = 1, #elements, 1 do
                    local element = elements[elementIndex]
        
                    for setting, value in pairs(DefaultOptions["element"]) do
                        if(element[setting] == nil) then
                            element[setting] = value
                        end
                    end
                end

                CurrentMenu["settings"]["elements"] = elements
            end
        }

        if menu ~= nil then
            menu(CurrentMenu)
        end
        
        local ScaleformMovie = RequestScaleformMovie("MP_MENU_GLARE")

        Citizen.CreateThread(function()
            while CurrentMenu ~= nil and CurrentMenu["thread"] == threadId do
                Citizen.Wait(0)
    
                if IsControlPressed(0, RPX.Keys["TOP"]) and (GetGameTimer() - LastMenuInput) > 150 then
                    local selected = CurrentMenu["settings"]["selectedIndex"]
    
                    if selected > 1 then
                        selected = selected - 1
    
                        CurrentMenu["settings"]["selectedIndex"] = selected
    
                        if CurrentMenu["updateResponse"] ~= nil then
                            CurrentMenu["updateResponse"](CurrentMenu["settings"]["elements"][selected], CurrentMenu)
                        end
                    end
     
                    LastMenuInput = GetGameTimer()
                end
    
                if IsControlPressed(0, RPX.Keys["DOWN"]) and (GetGameTimer() - LastMenuInput) > 150 then
                    local selected = CurrentMenu["settings"]["selectedIndex"]
    
                    if selected < #CurrentMenu["settings"]["elements"] then
                        selected = selected + 1
    
                        CurrentMenu["settings"]["selectedIndex"] = selected
    
                        if CurrentMenu["updateResponse"] ~= nil then
                            CurrentMenu["updateResponse"](CurrentMenu["settings"]["elements"][selected], CurrentMenu)
                        end
                    end
    
                    LastMenuInput = GetGameTimer()
                end
    
                if IsControlJustPressed(0, RPX.Keys["ENTER"]) then
                    local selected = CurrentMenu["settings"]["selectedIndex"]
    
                    if CurrentMenu["submitResponse"] ~= nil and not CurrentMenu["settings"]["elements"][selected]["locked"] then
                        CurrentMenu["submitResponse"](CurrentMenu["settings"]["elements"][selected], CurrentMenu)
                    end
                end
    
                if IsControlJustPressed(0, RPX.Keys["ESC"]) or IsControlJustPressed(0, RPX.Keys["BACKSPACE"]) then
                    local selected = CurrentMenu["settings"]["selectedIndex"]
    
                    if CurrentMenu["closeResponse"] ~= nil then
                        CurrentMenu["closeResponse"](CurrentMenu["settings"]["elements"][selected], CurrentMenu)
                    end
                end
    
                if CurrentMenu ~= nil then
                    RenderMenu(CurrentMenu["settings"])
                    DrawScaleformMovie(ScaleformMovie, 0.4545, 0.545, 1.0, 1.0, CurrentMenu["settings"]["color"][1], CurrentMenu["settings"]["color"][2], CurrentMenu["settings"]["color"][3], 255, 0)
                end
            end
        end)
    else
        print("[NativeMenus] There's already a menu open.")
    end
end

function RenderMenu(settings)
    local width = 0.2
    local height = 0.04
    local info = settings["selectedIndex"] .. " / " .. #settings["elements"]
    local x = settings["x"]
    local y = settings["y"] + 0.115

    DrawObject(settings["x"], settings["y"] - 0.006, 0.2, 0.091, settings["color"][1], settings["color"][2], settings["color"][3], 255)
    DrawTextWithFont(settings["title"], settings["x"] + 0.1, settings["y"] + 0.02, 1.0, 0, 0, 0, 1, true)
    DrawObject(settings["x"], settings["y"] + 0.085, 0.2, 0.03, 0, 0, 0, 255)
    DrawTextWithFont(settings["category"], settings["x"] + 0.0025, settings["y"] + 0.086, 0.4, settings["color"][1], settings["color"][2], settings["color"][3], 4, false)
    DrawTextWithFont(info, (settings["x"] + 0.195) - GetTextWidth(info, 4, 0.4), settings["y"] + 0.088, 0.32, settings["color"][1], settings["color"][2], settings["color"][3], 0, false)

    for index = 1, #settings["elements"], 1 do
        local i = 0

        while index >= (i + (settings["max"] + 1)) do
            i = i + (settings["max"] + 1)
        end

        if settings["selectedIndex"] >= i and settings["selectedIndex"] < (i + (settings["max"] + 1)) then
            local element = settings["elements"][index]
            local colors = {0, 0, 0, 150, 255, 255, 255}

            if settings["selectedIndex"] == index then
                if element["locked"] then
                    colors = {30, 30, 30, 150, 0, 0, 0}
                else
                    colors = {255, 255, 255, 255, 0, 0, 0}
                end
            end

            DrawObject(x, y, 0.2, 0.035, colors[1], colors[2], colors[3], colors[4])

            if element["locked"] then
                DrawTextWithFont(element["label"], x + 0.0025, y + 0.0025, 0.35, 200, 200, 200, 0, false)

                if element["option"] ~= "none" then
                    DrawTextWithFont("1", (x + 0.2) - (GetTextWidth("1", 3, 0.35) + GetTextWidth(element["option"], 0, 0.35) + GetTextWidth(">", 3, 0.35)), y - 0.00075, 0.35, 200, 200, 200, 3, false)
                    DrawTextWithFont(element["option"], (x + 0.2) - (GetTextWidth(element["option"], 0, 0.35) + GetTextWidth(">", 3, 0.35)), y + 0.0025, 0.35, 200, 200, 200, 0, false)
                    DrawTextWithFont("2", (x + 0.2) - GetTextWidth("2", 3, 0.35), y - 0.00075, 0.35, 200, 200, 200, 3, false)
                end
            else
                DrawTextWithFont(element["label"], x + 0.0025, y + 0.0025, 0.35, colors[5], colors[6], colors[7], 0, false)

                if element["option"] ~= "none" then
                    DrawTextWithFont("1", (x + 0.2) - (GetTextWidth("1", 3, 0.35) + GetTextWidth(element["option"], 0, 0.35) + GetTextWidth(">", 3, 0.35)), y - 0.00075, 0.35, colors[5], colors[6], colors[7], 3, false)
                    DrawTextWithFont(element["option"], (x + 0.2) - (GetTextWidth(element["option"], 0, 0.35) + GetTextWidth(">", 3, 0.35)), y + 0.0025, 0.35, colors[5], colors[6], colors[7], 0, false)
                    DrawTextWithFont("2", (x + 0.2) - GetTextWidth("2", 3, 0.35), y - 0.00075, 0.35, colors[5], colors[6], colors[7], 3, false)
                end
            end

            y = y + 0.035
        end
    end

    DrawObject(x, y, 0.2, 0.035, 0, 0, 0, 175)
    DrawTextWithFont("3", x + 0.1, y - 0.005, 0.35, 255, 255, 255, 3, true)
    DrawTextWithFont("4", x + 0.1, y + 0.005, 0.35, 255, 255, 255, 3, true)

    local selectedElement = settings["elements"][settings["selectedIndex"]]

    if #selectedElement["descriptions"] > 0 then
        local descriptions = selectedElement["descriptions"]

        DrawObject(x, y + 0.04, 0.2, (0.02 * #descriptions) + 0.0175, 0, 0, 0, 200)

        for textIndex = 1, #descriptions, 1 do
            local text = descriptions[textIndex]

            DrawTextWithFont(text["text"], x + 0.005, (text["y"] + 0.0175) + y, 0.35, 255, 255, 255, 0, false)
        end
    end
end

function CloseMenu()
    CurrentMenu = nil
end

function DrawObject(x, y, width, height, red, green, blue, alpha)
	DrawRect(x + (width / 2), y + (height / 2), width, height, red, green, blue, alpha)
end

function DrawTextWithFont(text, x, y, scale, red, green, blue, font, centered)
	SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(red, green, blue, 255)
    SetTextEntry("STRING")
    SetTextCentre(centered)

    AddTextComponentString(text)
    DrawText(x, y)
end

function GetTextWidth(text, font, scale)
    SetTextEntryForWidth("STRING")
    AddTextComponentSubstringPlayerName(text)
    SetTextFont(font)
    SetTextScale(scale, scale)

    return EndTextCommandGetWidth(true)
end