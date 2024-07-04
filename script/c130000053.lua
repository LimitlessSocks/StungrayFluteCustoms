--[[
Sergeant Waves
Card Author: Ani
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[When this card declares an attack: It gains 200 ATK.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--If you started the Duel with 60 cards in your Main Deck: You can draw 2 cards.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:HOPT()
	e2:SetFunctions(s.drawcon,nil,s.drawtg,s.drawop)
	c:RegisterEffect(e2)
	--Count cards at the start of the Duel
	aux.GlobalCheck(s,function()
		local ge=Effect.GlobalEffect()
		ge:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_STARTUP)
		ge:SetOperation(s.regop)
		Duel.RegisterEffect(ge,0)
	end)
end
local FLAG_STARTED_WITH_60_CARDS_IN_DECK = id

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		if Duel.GetDeckCount(p)==60 then
			Duel.RegisterFlagEffect(p,FLAG_STARTED_WITH_60_CARDS_IN_DECK,0,0,0)
		end
	end
end

--E1
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,0,200)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToChain() then
		c:UpdateATK(200,true,c)
	end
end

--E2
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.PlayerHasFlagEffect(tp,FLAG_STARTED_WITH_60_CARDS_IN_DECK)
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end