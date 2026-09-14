local I = require('openmw.interfaces')
local util = require("openmw.util")
local ui = require("openmw.ui")

local presetColors = {
    "d4edfc", -- thirst
    "bfd4bc", -- hunger
    "cfbddb", -- sleep
    "81cded", -- fav color of blue
    "caa560", -- fontColor_color_normal
    "d4b77f", -- goldenMix
    "dfc99f", -- FontColor_color_normal_over
    "eee2c9", -- lightText
    "253170", -- fontColor_color_journal_link
    "3a4daf", -- fontColor_color_journal_link_over
    "707ecf", -- fontColor_color_journal_link_pressed
}
local screenSize = ui.screenSize()

I.Settings.registerPage {
    key = 'AmmoCountHUD',
    l10n = 'AmmoCountHUD',
    name = 'page_name',
    description = 'page_description',
}

I.Settings.registerGroup {
    key = 'SettingsAmmoCountHUD_behavior',
    page = 'AmmoCountHUD',
    l10n = 'AmmoCountHUD',
    name = 'behavior_groupName',
    permanentStorage = true,
    order = 1,
    settings = {
        {
            key = 'cooldown',
            name = 'cooldown_name',
            description = "cooldown_desc",
            renderer = 'number',
            default = .2,
            min = 0,
        },
        {
            key = 'displayMode',
            name = 'displayMode_name',
            renderer = 'select',
            argument = {
                l10n = "AmmoCountHUD",
                items = {
                    "displayMode_e",
                    "displayMode_t",
                    "displayMode_et",
                },
            },
            default = "displayMode_e",
        },
    }
}


I.Settings.registerGroup {
    key = 'SettingsAmmoCountHUD_looks',
    page = 'AmmoCountHUD',
    l10n = 'AmmoCountHUD',
    name = 'looks_groupName',
    permanentStorage = true,
    order = 1,
    settings = {
        {
            key = 'positionLocked',
            name = 'positionLocked_name',
            description = "positionLocked_desc",
            renderer = 'checkbox',
            default = false,
        },
        {
            key = "posX",
            name = "posX_name",
            renderer = "SuperSlider6",
            default = 115,
            argument = {
                min = 0,
                max = screenSize.x,
                default = 115,
                minLabel = "Left",
                maxLabel = "Right",
                unit = "px",
            },
        },
        {
            key = "posY",
            name = "posY_name",
            renderer = "SuperSlider6",
            default = 35,
            argument = {
                min = 0,
                max = screenSize.y,
                default = 35,
                minLabel = "Down",
                maxLabel = "Up",
                unit = "px",
            },
        },
        {
            key = 'fontSize',
            name = 'fontSize_name',
            renderer = 'number',
            default = 16,
            min = 0,
        },
        {
            key = 'fontColor',
            name = 'fontColor_name',
            renderer = "SuperColorPicker2",
            default = util.color.hex("caa560"),
            argument = {
                presetColors = presetColors,
            },
        },
        {
            key = "enableTextShadow",
            name = 'enableTextShadow_name',
            renderer = 'checkbox',
            default = true,
        },
        {
            key = 'expandTo',
            name = 'expandTo_name',
            renderer = 'select',
            argument = {
                l10n = "AmmoCountHUD",
                items = {
                    "expandTo_left",
                    "expandTo_center",
                    "expandTo_right",
                },
            },
            default = "expandTo_left",
        },
    }
}
