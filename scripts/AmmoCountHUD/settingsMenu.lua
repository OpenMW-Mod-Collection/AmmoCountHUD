local I = require('openmw.interfaces')

I.Settings.registerPage {
    key = 'AmmoCountHUD',
    l10n = 'AmmoCountHUD',
    name = 'page_name',
    description = 'page_description',
}

I.Settings.registerGroup {
    key = 'SettingsAmmoCountHUD_settings',
    page = 'AmmoCountHUD',
    l10n = 'AmmoCountHUD',
    name = 'settings_groupName',
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
            key = 'hudMode',
            name = 'hudMode_name',
            description = "hudMode_desc",
            renderer = 'select',
            argument = {
                l10n = "AmmoCountHUD",
                items = {
                    "Equipped",
                    "Total",
                },
            },
            default = true,
        },
        {
            key = 'fontSize',
            name = 'fontSize_name',
            renderer = 'number',
            default = 16,
            min = 0,
        },
    }
}
