--[[	Authors: Hewdraw & Firetoad
		Last edited 25.07.2015		]]
require('lib/util_imba')

function ShallowGravePassive( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifier_passive = keys.modifier_passive
	local modifier_cooldown = keys.modifier_cooldown

	if not caster:HasModifier(modifier_cooldown) then
		ability:ApplyDataDrivenModifier(caster, caster, modifier_passive, {})
	else
		caster:RemoveModifierByName(modifier_passive)
	end
end

function ShallowGraveDamageCheck( keys )
	local ability = keys.ability
	local caster = keys.caster
	local modifier_grave = keys.modifier_grave

	-- If the ability was unlearned, or it's not time to trigger shallow grave, do nothing
	if not ability or caster:GetHealth() > 2 or caster:HasModifier(modifier_grave) or caster.has_aegis then
		return nil
	else
		ability:OnSpellStart()
	end
end

function ShallowGraveDamageTrigger(keys) -- Move passive trigger to spellstart for octarine interaction
	local ability = keys.ability
	local caster = keys.caster
	
	local ability_level = ability:GetLevel() - 1
	local modifier_passive = keys.modifier_passive
	local modifier_cooldown = keys.modifier_cooldown

	local passive_cooldown = ability:GetCooldownTimeRemaining()
	local passive_duration = ability:GetLevelSpecialValueFor("passive_duration", ability_level)

	-- Apply Shallow Grave buff
	ability:ApplyDataDrivenModifier(caster, caster, modifier_grave, {duration = passive_duration})
	ability:ApplyDataDrivenModifier(caster, caster, modifier_cooldown, {duration = passive_cooldown})
	caster:RemoveModifierByName(modifier_passive)
end

function ShallowGraveDamageStorage( keys )
	local caster = keys.caster
	local unit = keys.unit

	local health = unit:GetHealth()
	local damage = keys.DamageTaken

	-- creates unit.grave_damage if it doesn't exist
	if not unit.grave_damage then
		unit.grave_damage = 0
	end

	if health <= 2 then
		unit.grave_damage = unit.grave_damage + damage
	end
end
