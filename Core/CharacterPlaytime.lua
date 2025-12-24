local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata

print("Character Playtime v"..GetAddOnMetadata("CharacterPlaytime", "Version").." successfully loaded!")

MyAddon = MyAddon or {}

--[[
local CPmainFrame = CreateFrame("Frame", "CPmainFrame", UIParent, "BasicFrameTemplate")
CPmainFrame:SetSize(500, 350)
CPmainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

CPmainFrame.TitleBg:SetHeight(30)
CPmainFrame.title = CPmainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
CPmainFrame.title:SetPoint("TOPLEFT", CPmainFrame.TitleBg, "TOPLEFT", 5, -3)
CPmainFrame.title:SetText("Character Playtime")
CPmainFrame:Hide()
--]]

local AceGUI = LibStub("AceGUI-3.0")
local CPmainFrame = AceGUI:Create("Frame")
CPmainFrame:SetTitle("Character Playtime")
CPmainFrame:SetStatusText("Total playtime of all your characters")
CPmainFrame:SetLayout("List")
CPmainFrame:Hide()

-- create a scrolling content area so bars don't overflow the frame
local CPScroll = AceGUI:Create("ScrollFrame")
CPScroll:SetLayout("List")
CPScroll:SetFullWidth(true)
-- add the scroll area as the single child of the main frame
CPmainFrame:AddChild(CPScroll)


-- populate the frame with status bars from the DB
local function UpdateBars()
    if not CPmainFrame then return end

    -- Remove existing children in the scroll area (AceGUI handles resource cleanup)
    CPScroll:ReleaseChildren()

    -- optional temporary header bar / spacer
    CPScroll:AddChild(Spacer(15))

    -- compute a sensible max value so bars scale relative to the largest playtime
    local maxTime = 0
    for _, dat in pairs(Character_PlaytimeDB) do
        if dat and dat.time and dat.time > maxTime then maxTime = dat.time end
    end
    if maxTime == 0 then maxTime = 1 end

    -- add one bar per character, sorted by total playtime (descending)
    local entries = {}
    for cha, dat in pairs(Character_PlaytimeDB) do
        if dat then
            tinsert(entries, { key = cha, name = dat.name, time = dat.time or 0, class = dat.class })
        end
    end
    table.sort(entries, function(a, b)
        if a.time == b.time then
            return (a.name or "") < (b.name or "") -- fallback alphabetical
        end
        return a.time > b.time
    end)

    for i = 1, #entries do
        local e = entries[i]
        
        --CP_settings = CP_settings or {}
        if CP_settings["log_scaling"]==false or nil then
            totalBar = CreateStatusBar(CP_settings["bar_height"] or 20, (maxTime), (e.time), e.name or e.key, formatPlaytime(e.time), e.class or "Unknown")
        end
        
        if CP_settings["log_scaling"]==true then
            totalBar = CreateStatusBar(CP_settings["bar_height"] or 20, math.log10(maxTime), math.log10(e.time), e.name or e.key, formatPlaytime(e.time), e.class or "Unknown")
        end
        
        --local totalBar = CreateStatusBar(20, (maxTime), (e.time), e.name or e.key, formatPlaytime(e.time), e.class or "Unknown")
        -- store the DB key on the widget so we can refresh it later without rebuilding
        totalBar.userdata = totalBar.userdata or {}
        totalBar.userdata.charKey = e.key
        CPScroll:AddChild(totalBar)
        CPScroll:AddChild(Spacer(4))
    end
end

-- refresh and update values every time the frame is shown
CPmainFrame:SetCallback("OnShow", function(widget)
    -- rebuild the list (captures added/removed characters and resorting)
    UpdateBars()

    -- then update the numeric values / text so they always reflect current DB
    local maxTime = 0
    local totaltimeallchar=0
    for _, dat in pairs(Character_PlaytimeDB) do
        if dat and dat.time and dat.time > maxTime then maxTime = dat.time end
        totaltimeallchar=totaltimeallchar+dat.time
    --print("Total time played on all characters: "..formatPlaytime(totaltimeallchar))
    CPmainFrame:SetStatusText("Total playtime of all your characters: "..formatPlaytime(totaltimeallchar))
    end
    if maxTime == 0 then maxTime = 1 end

    if CPScroll and CPScroll.children then
        for _, child in ipairs(CPScroll.children) do
            local key = (child.userdata and child.userdata.charKey) or child.charKey
            if key and Character_PlaytimeDB[key] then
                local dat = Character_PlaytimeDB[key]
                local value = dat.time or 0
                local text = formatPlaytime(value)
                -- set value on the raw StatusBar if accessible
                if child.StatusBar then
                    child.StatusBar:SetMinMaxValues(0, maxTime)
                    child.StatusBar:SetValue(value)
                elseif child.frame and child.frame.StatusBar then
                    child.frame.StatusBar:SetMinMaxValues(0, maxTime)
                    child.frame.StatusBar:SetValue(value)
                end
                -- set the displayed playtime text
                if child.StatusBarValue then
                    child.StatusBarValue:SetText(text)
                elseif child.frame and child.frame.StatusBarValue then
                    child.frame.StatusBarValue:SetText(text)
                end
            end
        end
    end
end)

-- when the event TIME_PLAYED_MSG fires, refresh bars if the frame is visible
local timeUpdateFrame = CreateFrame("Frame")
timeUpdateFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "TIME_PLAYED_MSG" then
        if CPmainFrame and CPmainFrame:IsShown() then
            UpdateBars()
        end
    end
end)
timeUpdateFrame:RegisterEvent("TIME_PLAYED_MSG")

-- initial population
UpdateBars()



-- Create a slash command to open and close the frame and clear the DB
SLASH_CHARPLAY1 = "/characterplaytime"
SLASH_CHARPLAY2 = "/cp"
local function handler(msg, editBox)
    if msg and (msg =="clear") then
        Character_PlaytimeDB = {}
        print("Character Playtime database cleared.")
    end
    if CPmainFrame:IsShown() then
        CPmainFrame:Hide()
    else
        RequestTimePlayed()
        CPmainFrame:Show()
    end
end
SlashCmdList["CHARPLAY"] = handler


--toggle addon using the minimap button
function MyAddon:ToggleMainFrame()
    if not CPmainFrame:IsShown() then
        RequestTimePlayed()
        CPmainFrame:Show()
    else
        CPmainFrame:Hide()
    end
end

