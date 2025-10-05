if not RotationHelper then
    RotationHelper = {}
end

if not RotationHelper.Aura then
    RotationHelper.Aura = {}
    RotationHelper.Aura.__index = RotationHelper.Aura
end

RotationHelper.Aura.__index = RotationHelper.Aura
function RotationHelper.Aura:new(alias, name, unitCaster, expirationTime)
    local obj = setmetatable({}, self)
    obj.alias = alias
    obj.expiration = (expirationTime and expirationTime ~= 0) and (expirationTime - GetTime()) or nil
    obj.isSelf = unitCaster == "player"
    obj.name = name
    return obj
end