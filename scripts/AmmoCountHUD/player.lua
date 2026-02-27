local I = require("openmw.interfaces")
local types = require("openmw.types")
local self = require("openmw.self")
local storage = require("openmw.storage")

local E = require("scripts.AmmoCountHUD.uiElements")

local settings = storage.playerSection("SettingsAmmoCountHUD_settings")
local updateTime = 0

local function updateHUD()
    local equipment = types.Actor.getEquipment(self)
    local weapon = equipment[types.Actor.EQUIPMENT_SLOT.CarriedRight]
    local weaponType = weapon.type.record(weapon).type

    local isMarksman = weaponType == types.Weapon.TYPE.MarksmanBow
        or weaponType == types.Weapon.TYPE.MarksmanCrossbow
        or weaponType == types.Weapon.TYPE.MarksmanThrown
    if not weapon or not isMarksman then return end

    local ammo = weaponType == types.Weapon.TYPE.MarksmanThrown
        and weapon
        or equipment[types.Actor.EQUIPMENT_SLOT.Ammunition]
    E.ammo.layout.props.text = tostring(ammo.count)
end

local function onFrame(dt)
    E.ammo.layout.props.visible = I.UI.isHudVisible()
    E.ammo:update()

    updateTime = updateTime + dt
    local checkEvery = settings:get('cooldown')

    if updateTime < checkEvery then return end

    if checkEvery == 0 then
        updateTime = 0
    else
        while updateTime > checkEvery do
            updateTime = updateTime - checkEvery
        end
    end

    updateHUD()
end

return {
    engineHandlers = {
        onFrame = onFrame,
    }
}
