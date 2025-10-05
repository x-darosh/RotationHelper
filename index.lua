local Context = RotationHelper.Context
local Rotation = RotationHelper.Rotation
local Classes = RotationHelper.Classes  or {}

local deathKnightClass = Classes["DeathKnight"]
local unholySpec = deathKnightClass.roles["DamageDealer"]["Unholy"]

local context = Context:new(unholySpec)
local conditions = context:getRotationConditions()
local rotation = Rotation:new(conditions, context.spec.spells)
local currentSpell = rotation:getCurrentSpell()

RotationHelper.currentSpell = currentSpell