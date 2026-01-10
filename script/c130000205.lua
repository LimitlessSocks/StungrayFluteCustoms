--[[
Altergeist Dryadrive
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")

function s.initial_effect(c)
	--If an "Altergeist" Trap Card is activated (except during the Damage Step): You can Special Summon this card from your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetSpecialSummonSelfFunctions()
	c:RegisterEffect(e1)
	--If this card is sent from the field to the GY: You can target 1 "Altergeist" monster in your GY, except "Altergeist Dryadrive"; Special Summon it, but negate its effects.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetCondition(s.spcon2)
	e2:SetSpecialSummonFunctions(Duel.SpecialSummonNegate,TGCHECK_IT,s.spfilter,LOCATION_GRAVE,0,1,1,nil)
	c:RegisterEffect(e2)
	--Register Altergeist Trap activation
	aux.GlobalCheck(s,function()
		local ge=Effect.GlobalEffect()
		ge:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_CHAINING)
		ge:SetOperation(s.regop)
		Duel.RegisterEffect(ge,0)
	end)
end
s.listed_names={id}
s.listed_series={SET_ALTERGEIST}

--GE
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsTrapEffect()) then return end
	local setcodes=Duel.GetChainInfo(Duel.GetCurrentChain(),CHAININFO_TRIGGERING_SETCODES)
	for _,set in ipairs(setcodes) do
		if (SET_ALTERGEIST&0xfff)==(set&0xfff) and (SET_ALTERGEIST&set)==SET_ALTERGEIST then
			Duel.RaiseEvent(re:GetHandler(),EVENT_CUSTOM+id,re,r,rp,ep,ev)
			return
		end
	end
end

--E2
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.spfilter(c)
	return c:IsSetCard(SET_ALTERGEIST) and not c:IsCode(id)
end