local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata

print("Character Playtime v"..GetAddOnMetadata("CharacterPlaytime", "Version").." successfully loaded!")

MyAddon = MyAddon or {}


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

-- toggle button to hide/show the bars (scroll area)
-- standalone draggable button (not parented to CPmainFrame)
local toggleBtnFrame = CreateFrame("Button", "CPToggleButtonFrame", CPmainFrame.frame, "UIPanelButtonTemplate")
toggleBtnFrame:SetSize(100, 24)
toggleBtnFrame:SetPoint("TOPRIGHT", CPmainFrame.frame, "TOPLEFT", 0, -10)
toggleBtnFrame:SetText("Hide bars")
-- apply dark grey styling: background, highlight and pressed states
do
    pcall(function()
        local nt = toggleBtnFrame.GetNormalTexture and toggleBtnFrame:GetNormalTexture()
        if nt and nt.SetTexture then nt:SetTexture(nil) end
        local bt = toggleBtnFrame:CreateTexture(nil, "BACKGROUND")
        bt:SetAllPoints(toggleBtnFrame)
        bt:SetColorTexture(0.12, 0.12, 0.12, 1)

        local hl = toggleBtnFrame:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints(toggleBtnFrame)
        hl:SetColorTexture(1,1,1,0.06)

        toggleBtnFrame:SetScript("OnMouseDown", function(self) bt:SetColorTexture(0.08,0.08,0.08,1) end)
        toggleBtnFrame:SetScript("OnMouseUp", function(self) bt:SetColorTexture(0.12,0.12,0.12,1) end)

        local fs = toggleBtnFrame:GetFontString()
        if fs and fs.SetTextColor then fs:SetTextColor(1,1,1,1) end
        if fs and fs.SetFont then fs:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE") end
    end)
end
toggleBtnFrame:SetScript("OnClick", function(self)

    if CPScroll and CPScroll.frame then
        if CPScroll.frame:IsShown() then
            CPScroll.frame:Hide()
            self:SetText("Show bars")
        else
            CPScroll.frame:Show()
            UpdateBars(CPmainFrame, CPScroll, Character_PlaytimeDB, CP_settings)
            self:SetText("Hide bars")
        end
    end
end)

-- add the scroll area as the single child of the main frame
CPmainFrame:AddChild(CPScroll)


-- `UpdateBars` moved to `Core/CP_Utils.lua` and is now parameterized

-- refresh and update values every time the frame is shown
CPmainFrame:SetCallback("OnShow", function(widget)
    -- rebuild the list (captures added/removed characters and resorting)
    UpdateBars(CPmainFrame, CPScroll, Character_PlaytimeDB, CP_settings)
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
            UpdateBars(CPmainFrame, CPScroll, Character_PlaytimeDB, CP_settings)
        end
    end
end)
timeUpdateFrame:RegisterEvent("TIME_PLAYED_MSG")

-- initial population
UpdateBars(CPmainFrame, CPScroll, Character_PlaytimeDB, CP_settings)



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
