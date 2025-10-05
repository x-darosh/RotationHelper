local Class = RotationHelper.Class
if not RotationHelper then
    RotationHelper = {}
end

if not RotationHelper.Classes then
    RotationHelper.Classes = {}
end
local classes = {}
classes["DeathKnight"] = Class:new("DeathKnight")
classes.DeathKnight:addSpec("DamageDealer", RotationHelper.DeathKnightDamageDealerUnholy)

RotationHelper.Classes = classes