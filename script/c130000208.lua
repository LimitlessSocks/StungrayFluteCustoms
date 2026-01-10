--[[
The Shrieking Tower
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
Duel.LoadScript("glitchymods_synchro.lua")
function s.initial_effect(c)
	--Destroy this card during your 2nd Standby Phase after activation.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
	--Non-Machine monsters lose 300 ATK/DEF. 
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.debufftg)
	e2:SetValue(-300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--The turn player can target 1 monster they control; they apply 1 of these effects to it, but they cannot choose that effect of "The Shrieking Tower" again while this card is face-up on the field.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,2)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_BOTH_SIDE)
	e4:SetRange(LOCATION_FZONE)
	e4:HOPT()
	e4:SetTarget(s.efftg)
	e4:SetOperation(s.effop)
	c:RegisterEffect(e4)
end
s.listed_names={id}

--E1
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	c:SetTurnCounter(0)
	xgl.DelayedOperation(c,PHASE_STANDBY,id+100,e,tp,s.desop,s.descon,RESET_PHASE|PHASE_STANDBY|RESET_SELF_TURN,2,nil,aux.Stringid(id,1))
end
function s.descon(g,e,tp,eg,ep,ev,re,r,rp,tct)
	return Duel.GetTurnPlayer()==tp
end
function s.desop(g,e,tp,eg,ep,ev,re,r,rp,tct)
	local c=g:GetFirst()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		Duel.Destroy(c,REASON_RULE)
	end
end

--E2
function s.debufftg(e,c)
	return c:GetRace()~=RACE_MACHINE
end

--E4
function s.filter(c,val)
	if val>=0xf then return false end
	if val&0x7==0 then return true end
	return c:IsFaceup() and c:GetRace()~=RACE_MACHINE
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local val=c:GetFlagEffectLabel(id+tp)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,val)
	end
	if chk==0 then
		return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,0,1,nil,val)
	end
	Duel.Select(HINTMSG_TARGET,true,tp,nil,tp,LOCATION_MZONE,0,1,1,nil,val)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() then return end
	local c=e:GetHandler()
	local val=c:GetFlagEffectLabel(id+tp) or 0
	local b1=val&0x1==0
	local b2=val&0x2==0
	local b3=val&0x4==0
	local b4=val&0x8==0 and tc:IsFaceup() and tc:GetRace()~=RACE_MACHINE
	if not b1 and not b2 and not b3 and not b4 then return end
	local opt=xgl.Option(tp,id,3,b1,b2,b3,b4)
	if c:IsFaceup() and c:IsRelateToChain() then
		if not c:HasFlagEffect(id+tp) then
			c:RegisterFlagEffect(id+tp,RESET_EVENT|RESETS_STANDARD,0,1,1<<opt)
		else
			c:SetFlagEffectLabel(id+tp,c:GetFlagEffectLabel(tp+id)|(1<<opt))
		end
	end
	if opt==0 then
		local fid=e:GetFieldID()
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(id,3)
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_BATTLE_DESTROYING)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.drawcon)
		e1:SetOperation(s.drawop)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		tc:RegisterFlagEffect(id,RESET_EVENT|RESET_TOFIELD|RESET_TEMP_REMOVE|RESET_TURN_SET|RESET_MSCHANGE|RESET_PHASE|PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,3))
	elseif opt==1 then
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(id,4)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_CAN_BE_TUNER_GLITCHY)
		e2:SetValue(s.tunerval)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EFFECT_XYZ_LEVEL)
		e3:SetValue(s.xyzlv)
		e3:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e3)
	elseif opt==2 then
		local e4=Effect.CreateEffect(c)
		e4:SetDescription(id,5)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e4:SetValue(s.efindes)
		e4:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e4)
	elseif opt==3 then
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_CHANGE_RACE)
		e5:SetValue(RACE_MACHINE)
		e5:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e5)
	end
end

--E4.1
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc or not tc:HasFlagEffectLabel(id,e:GetLabel()) then
		e:Reset()
		return false
	end
	local bc=tc:GetBattleTarget()
	return eg:IsContains(tc) and bc and bc:GetPreviousRaceOnField()~=RACE_MACHINE
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Draw(tp,1,REASON_EFFECT)
end
--E4.2
function s.tunerval(e,c,sync,tp)
	return sync:IsRace(RACE_MACHINE)
end
function s.xyzlv(e,c,rc)
	local lv=e:GetHandler():GetLevel()
	if rc:IsRace(RACE_MACHINE) then
		return lv-1,lv,lv+1
	else
		return lv
	end
end
--E4.4
function s.efindes(e,re)
	if not re:IsActiveType(TYPE_MONSTER) then return false end
	if re:IsActivated() then
		local race=Duel.GetChainInfo(Duel.GetCurrentChain(),CHAININFO_TRIGGERING_RACE)
		return race~=RACE_MACHINE
	else
		local rc=re:GetHandler()
		return rc and rc:GetRace()~=RACE_MACHINE
	end
end