-- Some Util functions for Character Playtime Addon

-- Function to format playtime in days, hours, minutes, and seconds
function formatPlaytime(totalSeconds)
    local days = math.floor(totalSeconds / 86400)
    local hours = math.floor((totalSeconds % 86400) / 3600)
    local minutes = math.floor((totalSeconds % 3600) / 60)
    local seconds = totalSeconds % 60
    return string.format("%d Days %02dh %02dm %02ds", days, hours, minutes, seconds)
end

--rwturn the Character Name and Realm Name (to always have the same format)
function GetCharname()
    local charName = UnitName("player")
    local realmName = GetRealmName()
    local fullname = charName.." (" .. realmName .. ")"
    return fullname
end




-- Saving the total playtime and playtime at current level for each character on the account

Character_PlaytimeDB= Character_PlaytimeDB or {}


--careate Frame to listen to events
local eventListenerFrame = CreateFrame("Frame", "CPEventListenerFrame", UIParent)
--event handler function
local function eventHandler(self, event, ...)
    if event == "TIME_PLAYED_MSG" then
        local total_time,level_time = ...
        --print("time palyed msg event fired")
        local charName = UnitName("player")
        local realmName = GetRealmName()
        local charClass = UnitClass("player")
        local fullname = charName.." (" .. realmName .. ")"
        --Character_PlaytimeDB[charName.." (" .. realmName .. ")"] = {name=fullname,class=charClass, time=total_time, time_level=level_time}
        Character_PlaytimeDB[GetCharname()] = {name=fullname,class=charClass, time=total_time, time_level=level_time}
    end
    if event=="PLAYER_LOGIN" then
        --print("login event fired")
        RequestTimePlayed()
    end
    if event=="PLAYER_LOGOUT" then
        --print("logout event fired")
        RequestTimePlayed()
    end
end
--register events in the listener frame
eventListenerFrame:SetScript("OnEvent", eventHandler)
eventListenerFrame:RegisterEvent("TIME_PLAYED_MSG")
eventListenerFrame:RegisterEvent("PLAYER_LOGIN")
eventListenerFrame:RegisterEvent("PLAYER_LOGOUT")




-- Create Minimap Button----------------------------------------------------
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local addon = LibStub("AceAddon-3.0"):NewAddon("MyAddon","AceConsole-3.0")
MyAddonMinimapButton = LibStub("LibDBIcon-1.0", true)

local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject("MyAddon", {
	type = "data source",
	text = "Character Playtime",
	--icon = "Interface\\Icons\\spell_holy_borrowedtime",
    icon = "Interface\\AddOns\\CharacterPlaytime\\Media\\CP_Image.tga",
	OnClick = function(self, btn)
        if btn == "LeftButton" then
		    MyAddon:ToggleMainFrame()
            elseif btn == "RightButton" then
                Settings.OpenToCategory("Character Playtime")
            end
	end,
	OnTooltipShow = function(tooltip)
		if not tooltip or not tooltip.AddLine then
			return
		end
		tooltip:AddLine("\124cA330C900Character Playtime\124r\nv"..GetAddOnMetadata("CharacterPlaytime", "Version").."\n\124cFFF0FF00Left-click\124r: Open Character Playtime\n\124cFFF0FF00Right-click\124r: Open Settings", nil, nil, nil, nil)
	end,
})

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("MyAddonMinimapPOS", {
		profile = {
			minimap = {
				hide = false,
			},
		},
	})

	MyAddonMinimapButton:Register("MyAddon", miniButton, self.db.profile.minimap)
end

MyAddonMinimapButton:Show("MyAddon")

------------------------------------------------------------------------------------------------------

--lookup table for class icons
classicontable ={
    ["Warrior"]="Interface\\Icons\\classicon_warrior",
    ["Paladin"]="Interface\\Icons\\classicon_paladin",
    ["Hunter"]="Interface\\Icons\\classicon_hunter",
    ["Rogue"]="Interface\\Icons\\classicon_rogue",
    ["Priest"]="Interface\\Icons\\classicon_priest",
    ["Death Knight"]="Interface\\Icons\\classicon_deathknight",
    ["Shaman"]="Interface\\Icons\\classicon_shaman",
    ["Mage"]="Interface\\Icons\\classicon_mage",
    ["Warlock"]="Interface\\Icons\\classicon_warlock",
    ["Druid"]="Interface\\Icons\\classicon_druid",
    ["Evoker"]="Interface\\Icons\\classicon_evoker",
    ["Monk"]="Interface\\Icons\\classicon_monk",
    ["Demon Hunter"]="Interface\\Icons\\classicon_demonhunter",
    ["Unknown"]="Interface\\Icons\\INV_Misc_QuestionMark"
}

--lookup table for class color rgb values
classcolortable={
    ["Warrior"]={0.78,0.61,0.43},
    ["Paladin"]={0.96,0.55,0.73},
    ["Hunter"]={0.67,0.83,0.45},
    ["Rogue"]={1.00,0.96,0.41},
    ["Priest"]={1.00,1.00,1.00},
    ["Death Knight"]={0.77,0.12,0.23},
    ["Shaman"]={0.00,0.44,0.87},
    ["Mage"]={0.41,0.80,0.94},
    ["Warlock"]={0.58,0.51,0.79},
    ["Druid"]={1.00,0.49,0.04},
    ["Evoker"]={0.20,0.80,0.80},
    ["Monk"]={0.00,1.00,0.59},
    ["Demon Hunter"]={0.64,0.19,0.79},
    ["Unknown"]={0.5,0.5,0.5}
}

--------------------------------------------------------------------------------------------------------
local AceGUI = LibStub("AceGUI-3.0")

--funtion to create a status bar with class icon and data
function CreateStatusBar(height,maxvalue,value,charname,playtime,class)
  --define default values
  local height=height or 20
  local maxvalue= maxvalue or 100
  local value= value or 33
  local charname=charname or "Unknown"
  local playtime=playtime or "playttime unknown"
  local class =class or "Unknown"
  --create the status bar as a child of a SimpleGroup so it works with AceGui
  local sbGroup = AceGUI:Create("SimpleGroup")
  sbGroup:SetFullWidth(true)
  sbGroup.noAutoHeight = true
  sbGroup:SetHeight(height)
  -- icon on the left (parent to AceGUI content so it's cleaned up)
  local statbarIcon = sbGroup.content:CreateTexture(nil, "OVERLAY")
  statbarIcon:SetSize(20, 20)
  statbarIcon:SetPoint("LEFT", sbGroup.content, "LEFT", 4, 0)
  statbarIcon:SetTexture(classicontable[class])
  local statbar = CreateFrame("StatusBar", nil, sbGroup.content)
  -- shift bar right to make room for icon
  statbar:SetPoint("TOPLEFT", sbGroup.content, "TOPLEFT", 24, 0)
  statbar:SetPoint("BOTTOMRIGHT", sbGroup.content, "BOTTOMRIGHT", 0, 0)
  if (CP_settings and CP_settings["bar_texture"]==1) or nil then
    statbar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    elseif CP_settings["bar_texture"]==2 then
        statbar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
    elseif CP_settings["bar_texture"]==3 then
        statbar:SetStatusBarTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar")
    end
  --statbar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  statbar:SetStatusBarColor(classcolortable[class][1],classcolortable[class][2],classcolortable[class][3]) -- cyan
  statbar:SetMinMaxValues(0, maxvalue)
  statbar:SetValue(value)
  statbar:SetHeight(height)
  -- subtle background so the bar is visible when empty
  statbar.bg = statbar:CreateTexture(nil, "BACKGROUND")
  statbar.bg:SetAllPoints()
  statbar.bg:SetColorTexture(0, 0, 0, 0.5)
  -- left label (anchored to icon)
  local statbarLabel = statbar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  statbarLabel:SetPoint("LEFT", statbarIcon, "RIGHT", 6, 0)
  statbarLabel:SetText(charname)
  -- expose icon for later access if needed (both on frame and widget table to be safe)
  sbGroup.frame.StatusBarIcon = statbarIcon
  sbGroup.StatusBarIcon = statbarIcon
  -- right value text (updates on value change)
  local statbarValue = statbar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  statbarValue:SetPoint("RIGHT", statbar, "RIGHT", -6, 0)
  statbarValue:SetText(playtime)

  -- expose the raw StatusBar for later access if needed
  sbGroup.frame.StatusBar = statbar
  sbGroup.frame.StatusBarLabel = statbarLabel
  sbGroup.frame.StatusBarValue = statbarValue
  sbGroup.StatusBar = statbar
  sbGroup.StatusBarLabel = statbarLabel
  sbGroup.StatusBarValue = statbarValue

  -- Explicit cleanup when AceGUI releases this SimpleGroup to avoid leftover frames
  function sbGroup:OnRelease()
      -- clean statusbar
      local s = self.frame.StatusBar or self.StatusBar
      if s and s.SetScript then
          s:SetScript("OnValueChanged", nil)
          s:Hide()
          s:ClearAllPoints()
          pcall(function() s:SetParent(nil) end)
          if s.bg then
              if s.bg.SetTexture then s.bg:SetTexture(nil) end
              s.bg = nil
          end
      end
      -- clean icon
      local icon = self.frame.StatusBarIcon or self.StatusBarIcon
      if icon then
          icon:Hide()
          icon:ClearAllPoints()
          pcall(function() icon:SetTexture(nil) end)
          pcall(function() icon:SetParent(nil) end)
      end
      -- nil references on both widget and frame
      self.frame.StatusBar = nil
      self.frame.StatusBarIcon = nil
      self.frame.StatusBarLabel = nil
      self.frame.StatusBarValue = nil
      self.StatusBar = nil
      self.StatusBarIcon = nil
      self.StatusBarLabel = nil
      self.StatusBarValue = nil
  end

  return sbGroup
end

-- function to create a space between the bars
function Spacer(height)
  local height = height or 6
  -- use a SimpleGroup with a fixed height so AceGUI won't auto-resize it
  local spacer = AceGUI:Create("SimpleGroup")
  spacer:SetFullWidth(true)
  spacer.noAutoHeight = true
  spacer:SetHeight(height)
  return spacer
end


-----------------------------------------------------------------------------------------------------


--[[ AceGUI-3.0 Example Container Frame with TabGroup
local AceGUI = LibStub("AceGUI-3.0")
-- function that draws the widgets for the first tab
local function DrawGroup1(container)
  local desc = AceGUI:Create("Label")
  desc:SetText("This is Tab 1")
  desc:SetFullWidth(true)
  container:AddChild(desc)
  
  local button = AceGUI:Create("Button")
  button:SetText("Tab 1 Button")
  button:SetWidth(200)
  container:AddChild(button)
end

-- function that draws the widgets for the second tab
local function DrawGroup2(container)
  local desc = AceGUI:Create("Label")
  desc:SetText("This is Tab 2")
  desc:SetFullWidth(true)
  container:AddChild(desc)
  
  local button = AceGUI:Create("Button")
  button:SetText("Tab 2 Button")
  button:SetWidth(200)
  container:AddChild(button)
end

-- Callback function for OnGroupSelected
local function SelectGroup(container, event, group)
   container:ReleaseChildren()
   if group == "tab1" then
      DrawGroup1(container)
   elseif group == "tab2" then
      DrawGroup2(container)
   end
end

-- Create the frame container
local frame = AceGUI:Create("Frame")
frame:SetTitle("Example Frame")
frame:SetStatusText("AceGUI-3.0 Example Container Frame")
frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
-- Fill Layout - the TabGroup widget will fill the whole frame
frame:SetLayout("Fill")

-- Create the TabGroup
local tab =  AceGUI:Create("TabGroup")
tab:SetLayout("Flow")
-- Setup which tabs to show
tab:SetTabs({{text="Tab 1", value="tab1"}, {text="Tab 2", value="tab2"}})
-- Register callback
tab:SetCallback("OnGroupSelected", SelectGroup)
-- Set initial Tab (this will fire the OnGroupSelected callback)
tab:SelectTab("tab2")

-- add to the frame container
frame:AddChild(tab)--]]
