if not RotationHelper then
    RotationHelper = {}
end

if not RotationHelper.Resource then
    RotationHelper.Resource = {}
    RotationHelper.Resource.__index = RotationHelper.Resource
end
function RotationHelper.Resource:new(powerType)
    local obj = setmetatable({}, self)
    obj.health = UnitHealth("player")/UnitHealthMax("player")
    obj.power = UnitPower("player", powerType) or 0
    obj.runes = powerType == 6 and (function()
        local runeCounts = {
            blood = 0,
            frost = 0,
            unholy = 0,
            hasActiveRunes = false
        }

        local deathCount = 0

        for i = 1, 6 do
            local start, duration, runeReady = GetRuneCooldown(i)
            local runeType = GetRuneType(i)
            if runeReady then
                if runeType == 1 then
                    runeCounts.blood = runeCounts.blood + 1
                elseif runeType == 2 then
                    runeCounts.frost = runeCounts.frost + 1
                elseif runeType == 3 then
                    runeCounts.unholy = runeCounts.unholy + 1
                elseif runeType == 4 then
                    deathCount = deathCount + 1
                end
            end
        end

        runeCounts.blood = runeCounts.blood + deathCount
        runeCounts.frost = runeCounts.frost + deathCount
        runeCounts.unholy = runeCounts.unholy + deathCount

        runeCounts.hasActiveRunes = runeCounts.blood > 0 or runeCounts.frost > 0 or runeCounts.unholy > 0

        return runeCounts
    end)() or nil
    obj.comboPoints = powerType == 3 and GetComboPoints("player", "target") or nil
    return obj
end