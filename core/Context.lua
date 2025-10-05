-- в радиусе все с нужным дебаффом игрока - параметр
-- цель в радиусе поражения
if not RotationHelper then
    RotationHelper = {}
end

if not RotationHelper.Context then
    RotationHelper.Context = {}
    RotationHelper.Context.__index = RotationHelper.Context
end

local Resource = RotationHelper.Resource
local Utils = RotationHelper.Utils

function RotationHelper.Context:new(spec)
    local obj = setmetatable({}, self)
    -- local threshold = classInfo.specs[role] == "tank" and classInfo.specs[role][spec].threshold or nil
    local targetDebuffs = Utils.getTargetDebuffsState(spec.targetDebuffs)
    obj.spec = {
        spells = spec.spells,
        buffs = spec.buffs,
        targetDebuffs = spec.targetDebuffs,
        rotation = spec.rotation
    }
    obj.states = {
        player = {
            buffs = Utils.getPlayerBuffsState(spec.buffs),
            targetDebuffs = targetDebuffs.playerDebuffs,
            spells = Utils.getSpellsState(spec.spells),
            --shouldUseThreatSpell = classInfo.specs[role] == "tank" and Utils.shouldUseThreatSpell(threshold) or nil,
            --areEnemiesHaveDebuff = Utils.areEnemiesHaveDebuff(radius)
        },
        target = {
            debuffs = targetDebuffs.debuffs,
            isCastInterruptible = Utils.isTargetCastInterruptible(),
            isBoss = Utils.IsTargetBoss(),
            --isSingleEnemy = Utils.isSingleEnemy(radius)
        }
    }

    obj.resources = Resource:new(spec.powerType)

    return obj
end
function RotationHelper.Context:playerHasBuffs(buffAliases)
    if not buffAliases or #buffAliases == 0 then
        return true
    end

    for _, alias in ipairs(buffAliases) do
        if not self.states.player.buffs[alias] then
            return false
        end
    end

    return true
end

function RotationHelper.Context:targetHasDebuffs(debuffAliases, isSelf)
    if not debuffAliases or #debuffAliases == 0 then
        return true
    end

    for _, alias in ipairs(debuffAliases) do
        if isSelf then
            if not self.states.player.targetDebuffs[alias] then
                return false
            end
        else
            if not self.states.target.debuffs[alias] then
                return false
            end
        end
    end

    return true
end

function RotationHelper.Context:spellsAreUsable(spellAliases)
    if not spellAliases or #spellAliases == 0 then
        return true
    end

    for _, alias in ipairs(spellAliases) do
        local spellState = self.states.player.spells[alias]
        if not spellState or not spellState.usable then
            return false
        end
    end

    return true
end

function RotationHelper.Context:shouldRefreshBuffs(buffAliases)
    for _, alias in ipairs(buffAliases) do
        local hasBuff = self.states.player.buffs[alias]
        local spellState = self.states.player.spells[alias]
        if not hasBuff and spellState and spellState.usable then
            return true
        end
    end

    return false
end

function RotationHelper.Context:shouldRefreshDebuffs(debuffAliases, isSelf, time)
    if not debuffAliases or #debuffAliases == 0 then
        return false
    end

    local debuffList = isSelf and self.states.player.targetDebuffs or self.states.target.debuffs

    for _, alias in ipairs(debuffAliases) do
        local debuff = debuffList[alias]
        if debuff and debuff.expiration and debuff.expiration < time then
            return true
        end
    end

    return false
end

function RotationHelper.Context:getRotationConditions()
    return self.spec.rotation(self)
end
