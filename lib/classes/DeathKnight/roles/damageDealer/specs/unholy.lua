local Spell = RotationHelper.Spell
local Aura = RotationHelper.Aura
local Spec = RotationHelper.Spec

local spells = {
    bloodPresense = Spell:new("bloodPresense", "Власть крови", 0,
        "Interface\\Icons\\Spell_Deathknight_BloodPresence"),
    pestilence = Spell:new("pestilence", "Мор", 1,
        "Interface\\Icons\\Spell_Shadow_PlagueCloud.blp"),
    bloodTap = Spell:new("bloodTap", "Кровоотвод", 2,
        "Interface\\Icons\\Spell_DeathKnight_BloodTap.blp"),
    summonGargoyle = Spell:new("summonGargoyle", "Призыв Горгульи", 3,
        "Interface\\Icons\\Ability_Hunter_Pet_Bat.blp"),
    bloodFury = Spell:new("bloodFury", "Кровавое неистовство", 4,
        "Interface\\Icons\\Racial_Orc_BerserkerStrength.blp"),
    scourgeStrike = Spell:new("scourgeStrike", "Удар плети", 5,
        "Interface\\Icons\\Spell_DeathKnight_ScourgeStrike.blp", 1),
    deathCoil = Spell:new("deathCoil", "Лик смерти", 6,
        "Interface\\Icons\\Spell_Shadow_DeathCoil.blp"),
    plagueStrike = Spell:new("plagueStrike", "Удар чумы", 7,
        "Interface\\Icons\\Spell_DeathKnight_EmpowerRuneBlade.blp"),
    icyTouch = Spell:new("icyTouch", "Ледяное прикосновение", 8,
        "Interface\\Icons\\Spell_DeathKnight_IceTouch.blp"),
    bloodStrike = Spell:new("bloodStrike", "Кровавый удар", 9,
        "Interface\\Icons\\Spell_Deathknight_DeathStrike.blp"),
    hornOfWinter = Spell:new("hornOfWinter", "Зимний горн", 10,
        "Interface\\Icons\\INV_Misc_Horn_02.blp"),
    boneShield = Spell:new("boneShield", "Костяной щит", 11,
        "Interface\\Icons\\INV_Chest_Leather_13.blp"),
    empowerRuneWeapon = Spell:new("empowerRuneWeapon",
        "Усиление рунического оружия", 12, "Interface\\Icons\\INV_Sword_62.blp")
}

local buffs = {
    desolation = Aura:new("desolation", "Отчаяние"),
    piercingTwiling = Aura:new("piercingTwiling", "Пронзающая тьма"),
    unholyPresense = Aura:new("unholyPresense", "Власть нечестивости"),
    bloodFury = Aura:new("bloodFury", "Кровавое неистовство"),
    hornOfWinter = Aura:new("hornOfWinter", "Зимний горн"),
    boneShield = Aura:new("boneShield", "Костяной щит")

}
local debuffsOnTarget = {
    frostFever = Aura:new("frostFever", "Озноб"),
    bloodPlague = Aura:new("bloodPlague", "Кровавая чума")
}
local rotationConditionFunction = function(context)
    local shouldRefreshBuffs = not context.shouldRefreshBuffs({ "boneShield", "hornOfWinter" })
    local targetHasDiseases = context.targetHasDebuffs({ "frostFever", "bloodPlague" }, true)
    local playerHasDesolation = context.playerHasBuffs({ "desolation" })
    local obj = {
        summonGargoyle = context.spellsAreUsable({ "summonGargoyle" }) and
            context.playerHasBuffs({ "desolation", "piercingTwiling", "bloodFury" }) and targetHasDiseases and
            shouldRefreshBuffs,

        bloodFury = context.spellsAreUsable({ "bloodFury", "summonGargoyle" }) and
            context.playerHasBuffs({ "desolation", "piercingTwiling" }) and targetHasDiseases and shouldRefreshBuffs,

        boneShield = context.spellsAreUsable({ "boneShield" }) and not context.playerHasBuffs({ "boneShield" }),

        pestilence = context.spellsAreUsable({ "pestilence" }) and
            context.shouldRefreshDebuffs({ "frostFever", "bloodPlague" }, true, 2),

        icyTouch = context.spellsAreUsable({ "icyTouch" }) and shouldRefreshBuffs and
            not context.targetHasDebuffs({ "frostFever" }, true),

        plagueStrike = context.spellsAreUsable({ "plagueStrike" }) and shouldRefreshBuffs and
            not context.targetHasDebuffs({ "bloodPlague" }, true),

        scourgeStrike = context.spellsAreUsable({ "scourgeStrike" }) and playerHasDesolation and targetHasDiseases and
            shouldRefreshBuffs,

        deathCoil = context.spellsAreUsable({ "deathCoil" }) and shouldRefreshBuffs and playerHasDesolation and
            targetHasDiseases and
            ((not context.states.player.spells.summonGargoyle.usable and not context.states.player.spells.summonGargoyle.nomana) or
                (context.spellsAreUsable({ "summonGargoyle" }) and context.resources.power >= 100)),

        bloodStrike = context.spellsAreUsable({ "bloodStrike" }) and
            (not context.shouldRefreshDebuffs({ "frostFever", "bloodPlague" }, true, 2) and
                context.shouldRefreshDebuffs({ "frostFever", "bloodPlague" }, true, 6) and
                (context.resources.runes.blood == 2 or
                    (context.resources.runes.blood == 1 and context.spellsAreUsable({ "bloodTap" }))) or
                not context.shouldRefreshDebuffs({ "frostFever", "bloodPlague" }, true, 6)) and shouldRefreshBuffs and
            targetHasDiseases,

        bloodTap = context.spellsAreUsable({ "bloodTap" }) and
            ((context.resources.runes.blood == 0 and context.resources.runes.hasActiveRunes and
                    context.shouldRefreshDebuffs({ "frostFever", "bloodPlague" }, true, 2)) or
                (not context.shouldRefreshDebuffs({ "frostFever", "bloodPlague" }, true, 4) and
                    context.resources.runes.unholy == 0 and context.resources.runes.frost == 1) or
                (context.playerHasBuffs({ "unholyPresense" }) and
                    (not context.states.player.spells.summonGargoyle.usable and not context.states.player.spells.summonGargoyle.nomana) and
                    not context.spellsAreUsable({ "bloodSPresense" }))),

        empowerRuneWeapon = context.spellsAreUsable({ "empowerRuneWeapon" }) and
            not context.resources.runes.hasActiveRunes,

        hornOfWinter = context.spellsAreUsable({ "hornOfWinter" }) and
            (not context.playerHasBuffs({ "hornOfWinter" }) or
                (not context.resources.runes.hasActiveRunes and context.resources.power < 40)),
        bloodPresense = context.playerHasBuffs({ "unholyPresense" }) and
            (not context.states.player.spells.summonGargoyle.usable and not context.states.player.spells.summonGargoyle.nomana) and
            context.spellsAreUsable({ "bloodSPresense" })
    }
    return obj
end

local powerType = 6


local spec = Spec:new("Unholy", buffs, debuffsOnTarget, rotationConditionFunction, powerType, spells)
RotationHelper.DeathKnightDamageDealerUnholy = spec
