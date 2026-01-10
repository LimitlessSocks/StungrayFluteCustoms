--[[
Altergeist Reformatting
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--Discard 1 card, and if you do, Special Summon 1 Level 1 "Altergeist" monster from your Deck in Attack Position.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_HANDES|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:HOPT()
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--You can banish this card from your GY, then Tribute 1 "Altergeist" monster you control, or send 1 "Altergeist" Trap from your field to the GY; 1 "Altergeist" monster you control gains 800 ATK until the end of the turn.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetRelevantBattleTimings()
	e2:HOPT()
	e2:SetCondition(aux.StatChangeDamageStepCondition)
	e2:SetCost(s.atkcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ALTERGEIST}

--E1
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ALTERGEIST) and c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		end
	end
end

--E2
function s.costfilter(c,tp,alt)
	if not c:IsSetCard(SET_ALTERGEIST) then return false end
	if alt then
		if not (c:IsFaceup() and c:IsTrap() and c:IsAbleToGraveAsCost()) then
			return false
		end
	end
	return Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,c)
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_ALTERGEIST) and c:HasAttack()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 and not Cost.SelfBanish(e,tp,eg,ep,ev,re,r,rp,chk) then return false end
	local b1=Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,nil,nil,tp,false)
	local b2=Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil,tp,true)
	if chk==0 then return b1 or b2 end
	Cost.SelfBanish(e,tp,eg,ep,ev,re,r,rp,chk)
	local opt=xgl.Option(tp,id,2,b1,b2,OPTIONS_SKIP_REDUNDANT)
	if opt==0 then
		local g=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,nil,tp,false)
		Duel.Release(g,REASON_COST)
	elseif opt==1 then
		local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp,true)
		Duel.SendtoGrave(g,REASON_COST)
	end
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() or Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.Group(s.atkfilter,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,tp,800)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if Duel.Highlight(g) then
		g:GetFirst():UpdateATK(800,RESET_PHASE|PHASE_END,e:GetHandler())
	end
end