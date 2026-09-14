---@diagnostic disable: lowercase-global
local ui = require("openmw.ui")
local util = require("openmw.util")
local storage = require("openmw.storage")
local async = require("openmw.async")
local I = require("openmw.interfaces")
local input = require('openmw.input')

local settingsCache = require("scripts.AmmoCountHUD.utils.settingsCache")
local elements = {}

local textAlignHByDirection = {
    expandTo_right = ui.ALIGNMENT.End,
    expandTo_center = ui.ALIGNMENT.Center,
    expandTo_left = ui.ALIGNMENT.Start,
}

local function toScreenPosition(x, y)
    local screenSize = ui.screenSize()
    return util.vector2(x, screenSize.y - y)
end

local sectionLooks = storage.playerSection("SettingsAmmoCountHUD_looks")
settingsLooks = settingsCache.new(
    sectionLooks,
    async,
    function()
        elements.ammo.layout.layer = settingsLooks.positionLocked and "HUD" or 'Modal'
        elements.ammo.layout.props.position = toScreenPosition(settingsLooks.posX, settingsLooks.posY)
        elements.ammo.layout.props.textColor = settingsLooks.fontColor
        elements.ammo.layout.props.textSize = settingsLooks.fontSize
        elements.ammo.layout.props.textShadow = settingsLooks.enableTextShadow
        elements.ammo.layout.props.textAlignH = textAlignHByDirection[settingsLooks.expandTo]
        elements.ammo:update()
    end
)

elements.ammo = ui.create {
    layer = settingsLooks.positionLocked and "HUD" or 'Modal',
    name = "AmmoCountHUD",
    type = ui.TYPE.Text,
    events = {},
    props = {
        anchor = util.vector2(1, 0),
        position = toScreenPosition(settingsLooks.posX, settingsLooks.posY),
        visible = I.UI.isHudVisible(),
        text = nil,
        textSize = settingsLooks.fontSize,
        textColor = settingsLooks.fontColor,
        textShadow = settingsLooks.enableTextShadow,
        textAlignH = textAlignHByDirection[settingsLooks.expandTo],
    },
    userData = {
        windowStartPosition = toScreenPosition(settingsLooks.posX, settingsLooks.posY)
    }
}

-- +--------------------+
-- | Draggable UI logic |
-- +--------------------+

local function mousePress(data, elem)
    if data.button ~= 1 then return end -- Left mouse button
    if not elem.userData then
        elem.userData = {}
    end
    elem.userData.isDragging = true
    elem.userData.dragStartPosition = data.position
    elem.userData.windowStartPosition = util.vector2(settingsLooks.posX, settingsLooks.posY)

    elements.ammo:update()
end

local function mouseMove(data, elem)
    if not (elem.userData and elem.userData.isDragging) then return end
    -- Calculate new logical position based on mouse movement.
    local logicalX = elem.userData.windowStartPosition.x + data.position.x - elem.userData.dragStartPosition.x
    local logicalY = elem.userData.windowStartPosition.y + data.position.y - elem.userData.dragStartPosition.y
    sectionLooks:set("posX", math.floor(logicalX))
    sectionLooks:set("posY", math.floor(logicalY))
    elements.ammo.layout.props.position = toScreenPosition(logicalX, logicalY)

    elements.ammo:update()
end

local function mouseRelease(data, elem)
    if elem.userData then
        elem.userData.isDragging = false
    end
    elements.ammo:update()
end

elements.ammo.layout.events.mousePress = async:callback(mousePress)
elements.ammo.layout.events.mouseMove = async:callback(mouseMove)
elements.ammo.layout.events.mouseRelease = async:callback(mouseRelease)

-- +---------------------+
-- | Scrollable UI Logic |
-- +---------------------+

local function scaleFontSize(vertical)
    sectionLooks:set("fontSize", math.max(5, settingsLooks.fontSize + vertical))
end

if input.triggers["MenuMouseWheelUp"] then
    input.registerTriggerHandler("MenuMouseWheelUp", async:callback(function()
        if not elements.ammo.layout.userData.isDragging then return end
        if settingsLooks.positionLocked then return end
        scaleFontSize(1)
    end))
end
if input.triggers["MenuMouseWheelDown"] then
    input.registerTriggerHandler("MenuMouseWheelDown", async:callback(function()
        if not elements.ammo.layout.userData.isDragging then return end
        if settingsLooks.positionLocked then return end
        scaleFontSize(-1)
    end))
end

elements.ammo:update()
return elements
