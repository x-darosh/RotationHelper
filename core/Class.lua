if not RotationHelper then
    RotationHelper = {}
end

if not RotationHelper.Class then
    RotationHelper.Class = {}
    RotationHelper.Class.__index = RotationHelper.Class
end

function RotationHelper.Class:new(name)
    local obj = setmetatable({}, self)
    obj.name = name
    obj.roles = {}
    return obj
end

function RotationHelper.Class:addSpec(role, spec)
    if not self.roles[role] then
        self.roles[role] = {}
    end
    self.roles[role][spec.name] = spec
end