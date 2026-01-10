--[[
Final Showdown
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--Special Summon 1 "Masaki the Legendary Swordsman" and 1 "Hero of the East" from your Deck (1 to each field) in Attack Position. They must attack each other, if able.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--You can banish this card from your GY, then target 1 "Masaki the Legendary Swordsman" or 1 "Hero of the East" on the field; Special Summon 1 "Masaki the Legendary Swordsman" or 1 "Hero of the East" from your GY to its controller's opponent.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT()
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_MASAKI_THE_LEGENDARY_SWORDSMAN,CARD_HERO_OF_THE_EAST}

--E1
function s.firstsummon(c,e,tp,sg)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and sg:IsExists(s.secondsummon,1,c,e,tp)
end
function s.secondsummon(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK,1-tp)
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsCode,nil,CARD_MASAKI_THE_LEGENDARY_SWORDSMAN)==1
		and sg:FilterCount(Card.IsCode,nil,CARD_HERO_OF_THE_EAST)==1
		and sg:IsExists(s.firstsummon,1,nil,e,tp,sg)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK,0,nil,CARD_MASAKI_THE_LEGENDARY_SWORDSMAN)
	local g2=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK,0,nil,CARD_HERO_OF_THE_EAST)
	local g=g1+g2
	if chk==0 then return #g1>0 and #g2>0
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local g1=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK,0,nil,CARD_MASAKI_THE_LEGENDARY_SWORDSMAN)
	local g2=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK,0,nil,CARD_HERO_OF_THE_EAST)
	if #g1==0 or #g2==0 then return end
	local g=g1+g2
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_SPSUMMON)
	if #sg~=2 then return end
	Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id,3))
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local sc1=sg:FilterSelect(tp,s.firstsummon,1,1,nil,e,tp,sg):GetFirst()
	local sc2=sg:RemoveCard(sc1):GetFirst()
	Duel.SpecialSummonStep(sc1,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	Duel.SpecialSummonStep(sc2,0,tp,1-tp,false,false,POS_FACEUP_ATTACK)
	if Duel.SpecialSummonComplete()==2 then
		sc1:SetCardTarget(sc2)
		local c=e:GetHandler()
		local fid=e:GetFieldID()
		sc1:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,1))
		sc2:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,1))
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_MUST_ATTACK)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetTarget(function(_,card) return card==sc2 and card:HasFlagEffectLabel(id,fid) end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		sc1:RegisterEffect(e1,true)
		local e1b=e1:Clone()
		e1b:SetTarget(function(_,card) return card==sc1 and card:HasFlagEffectLabel(id,fid) end)
		sc2:RegisterEffect(e1b,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
		e2:SetValue(function(eff,card) return card==eff:GetHandler() end)
		sc1:RegisterEffect(e2,true)
		local e2b=e2:Clone()
		e2b:SetTarget(function(_,card) return card==sc1 and card:HasFlagEffectLabel(id,fid) end)
		sc2:RegisterEffect(e2b,true)
	end
end

--E2
function s.tgfilter(c,e,tp)
	local p=c:GetControler()
	return c:IsFaceup() and c:IsCode(CARD_MASAKI_THE_LEGENDARY_SWORDSMAN,CARD_HERO_OF_THE_EAST)
		and Duel.GetLocationCount(1-p,LOCATION_MZONE,tp)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,p,e,tp)
end
function s.spfilter(c,p,e,tp)
	return c:IsCode(CARD_MASAKI_THE_LEGENDARY_SWORDSMAN,CARD_HERO_OF_THE_EAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-p)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.tgfilter(chkc,e,tp) end
	if chk==0 then
		return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,e,tp)
	end
	Duel.Select(HINTMSG_TARGET,true,tp,s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local p=tc:GetControler()
		if Duel.GetLocationCount(1-p,LOCATION_MZONE,tp)>0 then
			local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,p,e,tp)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,1-p,false,false,POS_FACEUP)
			end
		end
	end
end