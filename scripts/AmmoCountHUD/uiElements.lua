local ui = require("openmw.ui")
local util = require("openmw.util")
local storage = require("openmw.storage")
local async = require("openmw.async")
local I = require("openmw.interfaces")

local C = require("scripts.AmmoCountHUD.utils.consts")

local settingsLooks = storage.playerSection("SettingsAmmoCountHUD_looks")

local elements = {}

elements.ammo = ui.create {
    layer = settingsLooks:get("positionLocked") and "HUD" or 'Modal',
    name = "AmmoCountHUD",
    type = ui.TYPE.Text,
    props = {
        anchor = C.getAnchorPoint[settingsLooks:get("textAlignment")],
        relativePosition = util.vector2(
            settingsLooks:get("posX"),
            settingsLooks:get("posY")
        ),
        visible = settingsLooks:get("enabled") and I.UI.isHudVisible(),
        text = "",
        textSize = settingsLooks:get("fontSize"),
        textColor = settingsLooks:get("fontColor"),
        events = {},
    },
}

-- +--------------------+
-- | Draggable UI logic |
-- +--------------------+

local function mousePress(data, elem)
    print(10000)
    if data.button == 1 then -- Left mouse button
        if not elem.userData then
            elem.userData = {}
        end
        elem.userData.isDragging = true
        elem.userData.dragStartPosition = data.position
        elem.userData.windowStartPosition = elements.ammo.layout.props.position or util.vector2(0, 0)
    end
    elements.ammo:update()
end

local function mouseRelease(data, elem)
    print(10001)
    if elem.userData then
        elem.userData.isDragging = false
    end
    elements.ammo:update()
end

local function mouseMove(data, elem)
    print(10003)
    if not (elem.userData and elem.userData.isDragging) then return end
    -- Calculate new position based on mouse movement
    local deltaX = data.position.x - elem.userData.dragStartPosition.x
    local deltaY = data.position.y - elem.userData.dragStartPosition.y
    local newPosition = util.vector2(
        elem.userData.windowStartPosition.x + deltaX,
        elem.userData.windowStartPosition.y + deltaY
    )
    settingsLooks:set("posX", math.floor(newPosition.x))
    settingsLooks:set("posY", math.floor(newPosition.y))
    --saveData.windowPos = newPosition
    elements.ammo.layout.props.position = newPosition
    elements.ammo:update()
end

elements.ammo.layout.props.events.mousePress = async:callback(mousePress)
elements.ammo.layout.props.events.mouseRelease = async:callback(mouseRelease)
elements.ammo.layout.props.events.mouseMove = async:callback(mouseMove)
elements.ammo:update()

-- +--------------------+
-- | Settings Callbacks |
-- +--------------------+

local callbacks = {
    ["enabled"] = function(settingValue)
        elements.ammo.layout.props.visible = settingValue and I.UI.isHudVisible()
    end,
    ["positionLocked"] = function(settingValue)
        elements.ammo.layout.layer = settingValue and "HUD" or 'Modal'
    end,
    ["posX"] = function(settingValue)
        elements.ammo.layout.props.relativePosition = util.vector2(
            settingValue,
            settingsLooks:get("posY")
        )
    end,
    ["posY"] = function(settingValue)
        elements.ammo.layout.props.relativePosition = util.vector2(
            settingsLooks:get("posX"),
            settingValue
        )
    end,
    ["fontColor"] = function(settingValue)
        elements.ammo.layout.props.textColor = settingValue
    end,
    ["fontSize"] = function(settingValue)
        elements.ammo.layout.props.textSize = settingValue
    end,
    ["textAlignment"] = function(settingValue)
        elements.ammo.layout.props.anchor = C.getAnchorPoint[settingValue]
    end
}

settingsLooks:subscribe(async:callback(
    function(sectionName, settingKey)
        local callback = callbacks[settingKey]
        if callback then
            callback(settingsLooks:get(settingKey))
            elements.ammo:update()
        end
    end)
)

return elements
