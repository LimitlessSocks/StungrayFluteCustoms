--[[
Altergeist Circomposa
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")

function s.initial_effect(c)
	--If all monsters you control are "Altergeist" monsters, or were Special Summoned by the effect of "Altergeist" monsters (min. 1), you can Normal Summon this card without Tributing.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	c:RegisterEffect(e1)
	--You can target any number of "Altergeist" monsters in your GY with different names; increase or decrease this card's Level by the number of targets still in the GY.
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(id,1)
    e2:SetCategory(CATEGORY_LVCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:HOPT()
    e2:SetFunctions(
		nil,
		nil,
		s.lvtg,
		s.lvop
	)
    c:RegisterEffect(e2)
	--If this card is sent to the GY: You can add 1 "Altergeist" Trap from your banishment to your hand, but you cannot activate cards or effects with the same name until the end of the next turn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:HOPT()
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	--Register Special Summons performed by Altergeist monster effects
	aux.GlobalCheck(s,function()
		local ge=Effect.GlobalEffect()
		ge:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge:SetOperation(s.regop)
		Duel.RegisterEffect(ge,0)
	end)
end
s.listed_series={SET_ALTERGEIST}

--GE
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if not re or not re:IsMonsterEffect() or not re:HasReasonArchetype(SET_ALTERGEIST) then return end
	for tc in eg:Iter() do
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
	end
end

--E1
function s.cfilter(c)
	return c:IsFacedown() or (not c:IsSetCard(SET_ALTERGEIST) and not c:HasFlagEffect(id))
end
function s.ntcon(e,c,minc,zone)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc==0 and c:GetLevel()>4 and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 and not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

--E2
function s.lvtgfilter(c,e)
	return c:IsMonster() and c:IsSetCard(SET_ALTERGEIST) and c:IsCanBeEffectTarget(e)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	local g=Duel.Group(s.lvtgfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then
		return c:HasLevel() and xgl.SelectUnselectGroup(0,g,e,tp,1,#g,xgl.dncheck,0)
	end
	local g=xgl.SelectUnselectGroup(0,g,e,tp,1,#g,xgl.dncheck,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,c,1,0,0)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() and c:HasLevel() then
		local ct=Duel.GetTargetCards():GetCount()
		if ct>0 then
			local op=xgl.Option(id,tp,nil,{c:GetLevel()>ct,STRING_LEVEL_REDUCE},{true,STRING_LEVEL_INCREASE})
			xgl.UpdateLevel(c,ct * (op==0 and -1 or 1),true,c)
		end
	end
end

--E3
function s.thfilter(c)
	return c:IsFaceup() and c:IsTrap() and c:IsSetCard(SET_ALTERGEIST) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	if Duel.SearchAndCheck(tc) then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(id,3)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetLabel(tc:GetCode())
		e1:SetReset(RESET_PHASE|PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end