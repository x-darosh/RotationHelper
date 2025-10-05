if not RotationHelper then
    RotationHelper = {}
end

if not RotationHelper.Spell then
    RotationHelper.Spell = {}
    RotationHelper.Spell.__index = RotationHelper.Spell
end

function RotationHelper.Spell:new(alias, name, priority, icon, id)
    local obj = setmetatable({}, self)
    obj.alias = alias
    obj.name = name
    obj.priority = priority
    obj.icon = icon
    obj.id = id
    return obj
end