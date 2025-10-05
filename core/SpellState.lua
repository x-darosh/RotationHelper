if not RotationHelper then
    RotationHelper = {}
end

if not RotationHelper.SpellState then
    RotationHelper.SpellState = {}
    RotationHelper.SpellState.__index = RotationHelper.SpellState
end
function RotationHelper.SpellState:new(nomana, usable)
    local obj = setmetatable({}, self)
    obj.nomana = nomana
    obj.usable = usable
    return obj
end