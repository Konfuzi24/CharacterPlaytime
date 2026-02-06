-- testfile


print("Unix time now:"..time())
local today=time()
local dateTbl = {
	year = 2025,
	month = 12,
	day = 24,
}
print("Unix time now:"..time(dateTbl))
test=date("*t",today)
--print("test :"..date("*t",today))
print(time({year=test.year, month=test.month, day=test.day}))

-----------------------------------------------------------------------

--[[
local AceGUI = LibStub("AceGUI-3.0")
local testFrame = AceGUI:Create("TabGroup")
testFrame:SetTitle("Character Playtime")
testFrame:SetWidth(420)
testFrame:SetHeight(320)
testFrame:SetPoint("CENTER")
testFrame:SetTabs({{value="Tab1", text="Total Playtime"}, {value="Tab2", text="Sessions"}})

-- Build tab content on selection. Release previous children so only the
-- active tab's content is present (prevents both tabs showing).

testFrame:SetCallback("OnGroupSelected", function(widget, event, group)
	widget:ReleaseChildren()
	if group == "Tab1" then
		local sg = AceGUI:Create("SimpleGroup")
		sg:SetLayout("List")
		sg:SetFullWidth(true)

		-- Example header
		local header = AceGUI:Create("Heading")
		header:SetText("Characters and Total Playtime")
		sg:AddChild(header)

		-- Sample data (replace with real data in your addon)
		local sample = {
			{name = "CharOne", time = "12d 4h"},
			{name = "CharTwo", time = "3d 6h"},
			{name = "Alt123", time = "1d 2h"},
		}

		for _, v in ipairs(sample) do
			local row = AceGUI:Create("InlineGroup")
			row:SetLayout("Flow")
			row:SetFullWidth(true)

			local nameLabel = AceGUI:Create("Label")
			nameLabel:SetText(v.name)
			nameLabel:SetWidth(220)
			row:AddChild(nameLabel)

			local timeLabel = AceGUI:Create("Label")
			timeLabel:SetText(v.time)
			timeLabel:SetWidth(120)
			row:AddChild(timeLabel)

			sg:AddChild(row)
		end

		local refresh = AceGUI:Create("Button")
		refresh:SetText("Refresh")
		refresh:SetWidth(80)
		refresh:SetCallback("OnClick", function() print("Refresh clicked") end)
		sg:AddChild(refresh)

		widget:AddChild(sg)
	elseif group == "Tab2" then
		local sg2 = AceGUI:Create("SimpleGroup")
		sg2:SetLayout("Fill")
		sg2:SetFullWidth(true)

		local scroll = AceGUI:Create("ScrollFrame")
		scroll:SetLayout("List")
		scroll:SetFullWidth(true)
		scroll:SetFullHeight(true)

		-- Sample session entries
		local sessions = {
			"2026-02-05 14:02 - 2h 12m",
			"2026-02-04 19:20 - 1h 05m",
			"2026-01-30 21:10 - 3h 44m",
		}
		for _, s in ipairs(sessions) do
			local lbl = AceGUI:Create("Label")
			lbl:SetText(s)
			lbl:SetFullWidth(true)
			scroll:AddChild(lbl)
		end

		sg2:AddChild(scroll)
		widget:AddChild(sg2)
	end
end)

testFrame:SelectTab("Tab1")
testFrame:Show()
]]