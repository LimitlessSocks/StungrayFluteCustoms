--[[
Altergeist Quiele
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2+ "Altergeist" monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_ALTERGEIST),2)
	--When your opponent activates a card or effect (Quick Effect): You can pay 2000 LP, then target 1 "Altergeist" Normal Trap in your GY; this effect becomes that card's effect when it is activated.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetCondition(s.copycon)
	e1:SetCost(s.copycost(Cost.PayLP(2000)))
	e1:SetTarget(s.copytg)
	e1:SetOperation(s.copyop)
	c:RegisterEffect(e1)
	--If this Link Summoned card is sent to the GY: You can place it in your Spell & Trap Zone as a Continuous Trap with the following effect.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCustomCategory(CATEGORY_PLACE_IN_STZONE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetCondition(s.plcon)
	e2:SetTarget(s.pltg)
	e2:SetOperation(s.plop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ALTERGEIST}

--E1
function s.copycon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
function s.copyfilter(c,e)
	return c:IsNormalTrap() and c:IsSetCard(SET_ALTERGEIST) and c:HasCopyableActivationEffect() and c:CheckActivateEffect(false,true,false)~=nil and c:IsCanBeEffectTarget(e)
end
function s.copycost(lpcost)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					if not lpcost(e,tp,eg,ep,ev,re,r,rp,chk) then return false end
					local g=Duel.GetMatchingGroup(s.copyfilter,tp,LOCATION_GRAVE,0,nil,e)
					if #g>0 then
						Duel.GetFlagEffectWithSpecificLabel(tp,id,Duel.GetCurrentChain()+1,true)
						local fe=Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1,Duel.GetCurrentChain()+1)
						fe:SetLabelObject(g)
						return true
					end
					return false
				end
				lpcost(e,tp,eg,ep,ev,re,r,rp,chk)
			end
end

function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local _,_,te,ceg,cep,cev,cre,cr,crp=table.unpack(e:GetLabelObject())
		return te and te:GetTarget() and te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and te:GetTarget()(e,tp,ceg,cep,cev,cre,cr,crp,chk,chkc)
	end
	if chk==0 then
		if e:IsCostChecked() then return true end
		local g=Duel.GetMatchingGroup(s.copyfilter,tp,LOCATION_GRAVE,0,nil,e)
		if #g>0 then
			Duel.GetFlagEffectWithSpecificLabel(tp,id,Duel.GetCurrentChain()+1,true)
			local fe=Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1,Duel.GetCurrentChain()+1)
			fe:SetLabelObject(g)
			return true
		end
		return false
	end
	local fe=Duel.GetFlagEffectWithSpecificLabel(tp,id,Duel.GetCurrentChain())
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=fe:GetLabelObject():Select(tp,1,1,nil):GetFirst()
	Duel.SetTargetCard(sc)
	local te,ceg,cep,cev,cre,cr,crp=sc:CheckActivateEffect(true,true,true)
	local tg=te:GetTarget()
	if tg then
		e:SetProperty(te:GetProperty())
		e:SetLabel(te:GetLabel())
		e:SetLabelObject(te:GetLabelObject())
		tg(e,tp,ceg,cep,cev,cre,cr,crp,1)
		Duel.ClearOperationInfo(0)
	end
	e:SetLabel(0)
	e:SetLabelObject(nil)
	fe:SetLabelObject({te:GetLabelObject(),te,ceg,cep,cev,cre,cr,crp,{te:GetLabel()}})
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local fe=Duel.GetFlagEffectWithSpecificLabel(tp,id,Duel.GetCurrentChain())
	if not fe then return end
	local obj,te,ceg,cep,cev,cre,cr,crp,labtab=table.unpack(fe:GetLabelObject())
	if not te then return end
	local op=te:GetOperation()
	if op then
		e:SetLabel(table.unpack(labtab))
		e:SetLabelObject(obj)
		op(e,tp,ceg,cep,cev,cre,cr,crp)
	end
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	fe:Reset()
end

--E2
function s.plcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLinkSummoned() and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBePlacedInBackrow(TYPE_TRAP|TYPE_CONTINUOUS,tp,e,REASON_EFFECT,tp,true) end
	if c:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_PLACE_IN_STZONE,c,1,tp,0,TYPE_TRAP|TYPE_CONTINUOUS)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	--Once per turn, during the Standby Phase: Gain 100 LP for each "Altergeist" card with a different name in your GY.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,3)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e1:SetRange(LOCATION_SZONE)
	e1:OPT()
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	--If your opponent draws a card(s) by a card effect (except during the Damage Step): You can send this card to the GY; draw 1 card.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,4)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DRAW)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.drawcon)
	e2:SetCost(s.drawcost)
	e2:SetDrawFunctions(tp,1)
	Duel.PlaceAsContinuousCard(c,tp,tp,c,TYPE_TRAP,aux.Stringid(id,2),e1,e2)
end

--Recover LP
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	local ct=Duel.Group(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,SET_ALTERGEIST):GetClassCount(Card.GetCode)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*100)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.Group(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,SET_ALTERGEIST):GetClassCount(Card.GetCode)
	if ct>0 then
		Duel.Recover(p,ct*100,REASON_EFFECT)
	end
end

--Draw
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and r&REASON_EFFECT==REASON_EFFECT
end
function s.drawcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED) end
	Duel.SendtoGrave(c,REASON_COST)
end