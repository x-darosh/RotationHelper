if not RotationHelper then
    RotationHelper = {}
end

if not RotationHelper.Utils then
    RotationHelper.Utils = {}
end

local Aura = RotationHelper.Aura
local SpellState = RotationHelper.SpellState


function RotationHelper.Utils.getPlayerBuffsState(buffs)
    local buffIndex = {}
    if buffs and type(buffs) == "table" then
        for _, buff in pairs(buffs) do
            if buff.name and buff.alias then
                buffIndex[buff.name] = buff.alias
            end
        end
    end

    local playerBuffsState = {}
    local i = 1

    while true do
        local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable,
        shouldConsolidate, spellId = UnitBuff("player", i)
        if not name then
            break
        end

        local buffObj = Aura:new(buffIndex[name], name, unitCaster, expirationTime)

        local alias = buffIndex[name]
        if alias then
            playerBuffsState[alias] = buffObj
        end

        i = i + 1
    end

    return playerBuffsState
end

function RotationHelper.Utils.getTargetDebuffsState(debuffs)
    local debuffIndex = {}
    if debuffs and type(debuffs) == "table" then
        for _, debuff in pairs(debuffs) do
            if debuff.name and debuff.alias then
                debuffIndex[debuff.name] = debuff.alias
            end
        end
    end

    local targetDebuffsState = {
        debuffs = {},
        playerDebuffs = {}
    }
    local i = 1

    while true do
        local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable,
        shouldConsolidate, spellId = UnitDebuff("target", i)
        if not name then
            break
        end

        local debuffObj = Aura:new(debuffIndex[name], name, unitCaster, expirationTime)

        local alias = debuffIndex[name]
        if alias then
            targetDebuffsState.debuffs[alias] = debuffObj
            if debuffObj.isSelf then
                targetDebuffsState.playerDebuffs[alias] = debuffObj
            end
        end

        i = i + 1
    end

    return targetDebuffsState
end

function RotationHelper.Utils.getSpellsState(spells)
    local spellsState = {}

    if spells then
        for _, spell in pairs(spells) do
            local usable, nomana = IsUsableSpell(spell.name)
            spellsState[spell.alias] = SpellState:new(nomana, usable)
        end
    end

    return spellsState
end

function RotationHelper.Utils.isTargetCastInterruptible()
    local spell, _, _, _, _, _, _, _, interrupt = UnitCastingInfo("target")
    if spell and not interrupt then
        return true
    end

    spell, _, _, _, _, _, _, _, interrupt = UnitChannelInfo("target")
    if spell and not interrupt then
        return true
    end

    return false
end

function RotationHelper.Utils.IsTargetBoss()
    if UnitIsBoss("target") then
        return true
    end

    local classification = UnitClassification("target")
    if classification == "worldboss" then
        return true
    end

    local level = UnitLevel("target")
    if level == -1 then
        return true
    end

    return false
end

-- Нужно импортировать библиотеку Threat-1.0

function RotationHelper.Utils.shouldUseThreatSpell(threshold)
    local playerThreat = ThreatLib:GetThreat("player", "target")
    if not playerThreat or playerThreat == 0 then
        return false
    end

    local threatStatus = UnitThreatSituation("player", "target")
    if threatStatus ~= 2 then
        return true
    end

    local nextPlayer, nextThreat = ThreatLib:GetNextThreat("player", "target")
    if not nextPlayer or not nextThreat then
        return false
    end

    if nextThreat <= playerThreat * (1 + threshold / 100) then
        return true
    end

    return false
end

function RotationHelper.Utils.isSingleEnemy(radius)
    local enemyCount = 0

    for i = 1, 40 do
        local unit = "nameplate" .. i
        if UnitExists(unit) and UnitCanAttack("player", unit) then
            local distance = UnitDistance(unit) or 0
            if distance <= radius then
                enemyCount = enemyCount + 1
                if enemyCount > 1 then
                    return false
                end
            end
        end
    end

    return enemyCount == 1
end

function RotationHelper.Utils.compareSpellsPriority(spell1, spell2)
    return spell1.priority < spell2.priority
end
