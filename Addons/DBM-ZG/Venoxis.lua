local mod	= DBM:NewMod("Venoxis", "DBM-ZG", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetCreatureID(14507)
mod:SetEncounterID(784)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 23860",
	"SPELL_CAST_SUCCESS 23861",
	"SPELL_AURA_APPLIED 23895 23860 23865",
	"SPELL_AURA_REMOVED 23895 23860",
	"UNIT_HEALTH boss1"
)

local warnSerpent		= mod:NewTargetNoFilterAnnounce(23865, 2)
local warnCloud			= mod:NewSpellAnnounce(23861)
local warnRenew			= mod:NewTargetNoFilterAnnounce(23895, 3)
local warnFire			= mod:NewTargetNoFilterAnnounce(23860, 2, nil, "RemoveMagic|Healer")
local prewarnPhase2		= mod:NewPrePhaseAnnounce(2, 2)

local specWarnHolyFire	= mod:NewSpecialWarningInterrupt(23860, "HasInterrupt", nil, nil, 1, 2)
local specWarnRenew		= mod:NewSpecialWarningDispel(23895, "MagicDispeller", nil, nil, 1, 2)

local timerCloud		= mod:NewBuffActiveTimer(10, 23861, nil, nil, nil, 3)
local timerRenew		= mod:NewTargetTimer(15, 23895, nil, "MagicDispeller", nil, 5, nil, DBM_CORE_MAGIC_ICON)
local timerFireCast		= mod:NewCastTimer(3.5, 23860, nil, "HasInterrupt", nil, 4, nil, DBM_CORE_INTERRUPT_ICON)
local timerFire			= mod:NewTargetTimer(8, 23860, nil, "RemoveMagic|Healer", nil, 5, nil, DBM_CORE_MAGIC_ICON)

mod:AddBoolOption("RangeFrame", true)

mod.vb.prewarn_Phase2 = false

function mod:OnCombatStart(delay)
	self.vb.prewarn_Phase2 = false
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(10)
	end
end

function mod:OnCombatEnd()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

do
	local PoisonCloud = DBM:GetSpellInfo(23861)
	function mod:SPELL_CAST_SUCCESS(args)
		--if args:IsSpellID(23861) then
		if args.spellName == PoisonCloud then
			warnCloud:Show()
			timerCloud:Start()
		end
	end
end

do
	local Renew, HolyFire, ParasiticSerpent = DBM:GetSpellInfo(23895), DBM:GetSpellInfo(23860), DBM:GetSpellInfo(23865)
	function mod:SPELL_CAST_START(args)
		--if args:IsSpellID(23860) then
		if args.spellName == HolyFire and args:IsSrcTypeHostile() then
			timerFireCast:Start()
			if self:CheckInterruptFilter(args.sourceGUID, false, true) then
				specWarnHolyFire:Show(args.sourceName)
				specWarnHolyFire:Play("kickcast")
			end
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		--if args:IsSpellID(23895) then
		if args.spellName == Renew and args:IsDestTypeHostile() then
			if self.Options.SpecWarn23895dispel then
				specWarnRenew:Show(args.destName)
				specWarnRenew:Play("dispelboss")
			else
				warnRenew:Show(args.destName)
			end
			timerRenew:Start(args.destName)
		--elseif args:IsSpellID(23860) then
		elseif args.spellName == HolyFire and args:IsDestTypePlayer() then
			warnFire:Show(args.destName)
			timerFire:Start(args.destName)
		--elseif args:IsSpellID(23865) then
		elseif args.spellName == ParasiticSerpent then
			warnSerpent:Show(args.destName)
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		--if args:IsSpellID(23895) then
		if args.spellName == Renew and args:IsDestTypeHostile() then
			timerRenew:Stop(args.destName)
		--elseif args:IsSpellID(23860) then
		elseif args.spellName == HolyFire and args:IsDestTypePlayer() then
			timerFire:Stop(args.destName)
		end
	end
end

function mod:UNIT_HEALTH(uId)
	if not self.vb.prewarn_Phase2 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.53 then
		self.vb.prewarn_Phase2 = true
		prewarnPhase2:Show()
	end
end
