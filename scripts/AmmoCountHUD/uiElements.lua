---@diagnostic disable: lowercase-global
local ui = require("openmw.ui")
local util = require("openmw.util")
local storage = require("openmw.storage")
local async = require("openmw.async")
local I = require("openmw.interfaces")
local input = require('openmw.input')
local self = require("openmw.self")

local settingsCache = require("scripts.AmmoCountHUD.utils.settingsCache")
local elements = {}

local anchorPointByDirection = {
    expandTo_right = util.vector2(0, 0),
    expandTo_center = util.vector2(.5, 0),
    expandTo_left = util.vector2(1, 0),
}

local function getCappedPosition(x, y)
    local screenSize = ui.screenSize()
    local textHeight = settingsLooks.fontSize
    return util.vector2(
        math.max(0, math.min(screenSize.x, x)),
        math.max(0, math.min(screenSize.y + textHeight, y))
    )
end

local sectionLooks = storage.playerSection("SettingsAmmoCountHUD_looks")
settingsLooks = settingsCache.new(
    sectionLooks,
    async,
    function()
        elements.ammo.layout.layer = settingsLooks.positionLocked and "HUD" or 'Modal'
        elements.ammo.layout.props.position = getCappedPosition(settingsLooks.posX, settingsLooks.posY)
        elements.ammo.layout.props.textColor = settingsLooks.fontColor
        elements.ammo.layout.props.textSize = settingsLooks.fontSize
        elements.ammo.layout.props.textShadow = settingsLooks.enableTextShadow
        elements.ammo.layout.props.anchor = anchorPointByDirection[settingsLooks.textAlignment]
        elements.ammo:update()
    end
)

elements.ammo = ui.create {
    layer = settingsLooks.positionLocked and "HUD" or 'Modal',
    name = "AmmoCountHUD",
    type = ui.TYPE.Text,
    events = {},
    props = {
        anchor = anchorPointByDirection[settingsLooks.textAlignment],
        position = getCappedPosition(settingsLooks.posX, settingsLooks.posY),
        visible = I.UI.isHudVisible(),
        text = nil,
        textSize = settingsLooks.fontSize,
        textColor = settingsLooks.fontColor,
        textShadow = settingsLooks.enableTextShadow,
    },
    userData = {
        windowStartPosition = getCappedPosition(settingsLooks.posX, settingsLooks.posY)
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
    elem.userData.windowStartPosition = elements.ammo.layout.props.position or util.vector2(0, 0)

    elements.ammo:update()
end

local function mouseMove(data, elem)
    if not (elem.userData and elem.userData.isDragging) then return end
    local screenSize = ui.screenSize()
    -- Calculate new position based on mouse movement
    local deltaX = data.position.x - elem.userData.dragStartPosition.x
    local deltaY = data.position.y - elem.userData.dragStartPosition.y
    local newPosition = getCappedPosition(
        elem.userData.windowStartPosition.x + deltaX,
        elem.userData.windowStartPosition.y + deltaY
    )
    sectionLooks:set("posX", math.floor(newPosition.x))
    sectionLooks:set("posY", math.floor(newPosition.y))
    elements.ammo.layout.props.position = newPosition

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
