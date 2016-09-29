--------------------------------------------------------------------------------------------------------
--
--		Hero: undying
--		Perk: gains strength when units die nearby, +1 for non-heroes, +4 for heroes
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_undying_perk", "abilities/hero_perks/npc_dota_hero_undying_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_undying_perk_aura", "abilities/hero_perks/npc_dota_hero_undying_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_undying_perk == nil then npc_dota_hero_undying_perk = class({}) end

function npc_dota_hero_undying_perk:GetIntrinsicModifierName()
	return "modifier_npc_dota_hero_undying_perk"
end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_undying_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_undying_perk == nil then modifier_npc_dota_hero_undying_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_undying_perk:IsPassive()
	return true
end

function modifier_npc_dota_hero_undying_perk:OnCreated()
	self.radius = 900
	self:GetAbility().creepStr = 1
	self:GetAbility().heroStr = 4
	self.expireTime = 30
	self:GetParent().strTable = {}
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_undying_perk:OnRefresh()
	self:GetParent().strTable = {}
end

function modifier_npc_dota_hero_undying_perk:OnIntervalThink()
	if #self:GetParent().strTable > 0 then
		for i = #self:GetParent().strTable, 1, -1 do
			if self:GetParent().strTable[i] + self.expireTime < GameRules:GetGameTime() then
				table.remove(self:GetParent().strTable, i)
				
			end
		end
		self:SetStackCount(#self:GetParent().strTable)
		if #self:GetParent().strTable == 0 then
			self:SetDuration(-1,true)
		end
		self:GetParent():CalculateStatBonus()
	else
		self:SetDuration(-1,true)
	end
end

--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_undying_perk:IsHidden()
	return false
end

function modifier_npc_dota_hero_undying_perk:IsAura()
	return true
end

function modifier_npc_dota_hero_undying_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
  }
  return funcs
end

function modifier_npc_dota_hero_undying_perk:DestroyOnExpire()
	return false
end

function modifier_npc_dota_hero_undying_perk:GetModifierAura()
	return "modifier_npc_dota_hero_undying_perk_aura"
end

function modifier_npc_dota_hero_undying_perk:GetAuraRadius()
	return self.radius
end

function modifier_npc_dota_hero_undying_perk:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_npc_dota_hero_undying_perk:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_npc_dota_hero_undying_perk:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_npc_dota_hero_undying_perk:GetModifierBonusStats_Strength()
	return self:GetStackCount()
end

--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------
--		Aura Modifier: modifier_npc_dota_hero_undying_perk_aura		
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_undying_perk_aura == nil then modifier_npc_dota_hero_undying_perk_aura = class({}) end

function modifier_npc_dota_hero_undying_perk_aura:IsHidden()
	return true
end

function modifier_npc_dota_hero_undying_perk_aura:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_DEATH,
  }
  return funcs
end

function modifier_npc_dota_hero_undying_perk_aura:OnDeath(params)
	if IsServer() and params.unit:HasModifier("modifier_npc_dota_hero_undying_perk_aura") and params.unit == self:GetParent() then
		local trigger = self:GetAbility().creepStr 
		if params.unit:IsRealHero() then
			trigger = self:GetAbility().heroStr
		end
		for i = 1, trigger do
			local modifier = self:GetCaster():FindModifierByName("modifier_npc_dota_hero_undying_perk")
			modifier:SetDuration(modifier.expireTime, true)
			table.insert(self:GetCaster().strTable, GameRules:GetGameTime())
		end
	end
end
