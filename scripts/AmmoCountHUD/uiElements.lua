local ui = require("openmw.ui")
local util = require("openmw.util")
local storage = require("openmw.storage")

local settings = storage.playerSection("SettingsAmmoCountHUD_settings")

local elements = {}

elements.ammo = ui.create {
   layer = 'HUD',
   type = ui.TYPE.Text,
   props = {
      anchor = util.vector2(1, 0),
      relativePosition = util.vector2(.06, .967),
      text = "nil",
      textSize = settings:get("fontSize"),
      textColor = util.color.hex("caa560"),
   },
}

return elements
