---@diagnostic disable: lowercase-global
local I = require("openmw.interfaces")
local types = require("openmw.types")
local self = require("openmw.self")
local storage = require("openmw.storage")
local async = require("openmw.async")

local E = require("scripts.AmmoCountHUD.uiElements")
local settingsCache = require("scripts.AmmoCountHUD.utils.settingsCache")

local settingsBehavior = settingsCache.new(
    storage.playerSection("SettingsAmmoCountHUD_behavior"),
    async,
    function()
        onUpdate(math.huge)
    end
)
local inv = self.type.inventory(self)
local weaponTypeToAmmoType = {
    [types.Weapon.TYPE.MarksmanBow]      = types.Weapon.TYPE.Arrow,
    [types.Weapon.TYPE.MarksmanCrossbow] = types.Weapon.TYPE.Bolt,
    [types.Weapon.TYPE.MarksmanThrown]   = types.Weapon.TYPE.MarksmanThrown,
}
local updateTime = 0

local function getEquippedAmmoCount(weapon, ammoType)
    if ammoType == types.Weapon.TYPE.MarksmanThrown then
        return weapon.count
    end

    local ammo = self.type.getEquipment(self, self.type.EQUIPMENT_SLOT.Ammunition)
    if not ammo then return 0 end

    local ammoRecord = ammo.type.records[ammo.recordId]
    return ammoRecord.type == ammoType
        and ammo.count
        or 0
end

local function getTotalAmmoCount(weapon, ammoType)
    local allAmmo = inv:getAll(types.Weapon)
    local ammoCounter = 0
    for _, item in ipairs(allAmmo) do
        if item.type.records[item.recordId].type == ammoType then
            ammoCounter = ammoCounter + item.count
        end
    end
    return ammoCounter
end

local ammoCountGetters = {
    displayMode_e = getEquippedAmmoCount,
    displayMode_t = getTotalAmmoCount,
    displayMode_et = function(weapon, ammoType)
        local equipped = getEquippedAmmoCount(weapon, ammoType)
        local total = getTotalAmmoCount(weapon, ammoType)
        return ("%d/%d"):format(equipped, total)
    end
}

local function getAmmoCount()
    local weapon = self.type.getEquipment(self,
        self.type.EQUIPMENT_SLOT.CarriedRight)

    -- no weapon equipped
    if not weapon then
        return ""
    end

    local weaponType = weapon.type.records[weapon.recordId].type
    local ammoType = weaponTypeToAmmoType[weaponType]

    -- equipped weapon is not marksman
    if not ammoType then
        return ""
    end

    local ammoCountGetter = ammoCountGetters[settingsBehavior.displayMode]
    return tostring(ammoCountGetter(weapon, ammoType))
end

function onUpdate(dt)
    E.ammo.layout.props.visible = I.UI.isHudVisible()

    updateTime = updateTime + dt
    local checkEvery = settingsBehavior.cooldown

    if updateTime < checkEvery then
        E.ammo:update()
        return
    end

    updateTime = checkEvery == 0
        and 0
        or updateTime % checkEvery

    E.ammo.layout.props.text = getAmmoCount()
    E.ammo:update()
end

onUpdate(math.huge)

return {
    engineHandlers = {
        onUpdate = onUpdate,
    },
}
