if not RotationHelper then
    RotationHelper = {}
end

if not RotationHelper.Spec then
    RotationHelper.Spec = {}
    RotationHelper.Spec.__index = RotationHelper.Spec
end
function RotationHelper.Spec:new(name, buffs, debuffsOnTarget, rotationConditionFunction, powerType, spells)
    local obj = setmetatable({}, self)
    obj.name = name
    obj.buffs = buffs
    obj.debuffsOnTarget = debuffsOnTarget
    obj.rotationConditionFunction = rotationConditionFunction
    obj.powerType = powerType
    obj.spells = spells
    return obj
end