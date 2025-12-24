

CP_settings = CP_settings or {}

local function OnSettingChanged(_, setting, value)
	local variable = setting:GetVariable()
	CP_settings[variable] = value
end

local category = Settings.RegisterVerticalLayoutCategory("Character Playtime")



do
    local variable = "log_scaling"
    local name = "Logarithmic Scaling"
    local tooltip = "Logarithmic scaling for playtime bars"
    local defaultValue = false

    local function getValue()
        return CP_settings[variable] ~= nil and CP_settings[variable] or defaultValue
    end
    local function setValue(_, value)
        CP_settings[variable] = value
    end

    local setting = Settings.RegisterProxySetting(category, variable, "boolean", name, defaultValue, getValue, setValue)
    Settings.CreateCheckbox(category, setting, tooltip)
    Settings.SetOnValueChangedCallback(variable, OnSettingChanged)
end

do
    local variable = "bar_height"
    local name = "Bar Height"
    local tooltip = "Height of each individual Playtime Bar (default=20)"
    local defaultValue = 20
    local minValue = 1
    local maxValue = 50
    local step = 1

    local function getValue()
        local v = CP_settings[variable]
        if v == nil then v = defaultValue end
        return v
    end
    local function setValue(_, value)
        CP_settings[variable] = value
    end

    local setting = Settings.RegisterProxySetting(category, variable, "number", name, defaultValue, getValue, setValue)
    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
    Settings.CreateSlider(category, setting, options, tooltip)
    Settings.SetOnValueChangedCallback(variable, OnSettingChanged)
end



do
    local variable = "bar_texture"
    local defaultValue = 1
    local name = "Bar Texture"
    local tooltip = "Change the Texture of the Playtime Bars"

    local function GetOptions()
        local container = Settings.CreateControlTextContainer()
        container:Add(1, "Classic/Blizzard")
        container:Add(2, "Flat")
        container:Add(3, "Textured")
        return container:GetData()
    end

    local function getValue()
        local v = CP_settings[variable]
        if v == nil then v = defaultValue end
        return v
    end
    local function setValue(_, value)
        CP_settings[variable] = value
    end
    local setting = Settings.RegisterProxySetting(category, variable, "number", name, defaultValue, getValue, setValue)
    Settings.CreateDropdown(category, setting, GetOptions, tooltip)
    Settings.SetOnValueChangedCallback(variable, OnSettingChanged)
end

Settings.RegisterAddOnCategory(category,"Character Playtime")
category.ID = "Character Playtime"