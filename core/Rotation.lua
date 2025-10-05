if not RotationHelper then
    RotationHelper = {}
end

if not RotationHelper.Rotation then
    RotationHelper.Rotation = {}
    RotationHelper.Rotation.__index = RotationHelper.Rotation
end
function RotationHelper.Rotation:new(conditions, spells)
    local obj = setmetatable({}, self)
    obj.conditions = conditions
    obj.spells = spells
    return obj
end

function RotationHelper.Rotation:getCurrentSpell()
    local currentSpells = {}
    for key, condition in pairs(self.conditions) do
        if condition then
            local spell = self.spells[key]
            if spell then
                table.insert(currentSpells, spell)
            end
        end
    end
    if #currentSpells > 0 then
        table.sort(currentSpells, Utils.compareSpellsPriority)
    end
    return currentSpells[1] or nil
end
