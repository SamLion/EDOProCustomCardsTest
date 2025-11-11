-- code: 112345686
-- DARK STAND The World
local s,id=GetID()
function s.initial_effect(c)
    --Special Summon
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1)
	e1:SetCondition(s.sscon)
	e1:SetTarget(s.sstg)
	e1:SetOperation(s.ssop)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
s.listed_series={0x0f98}
function s.filter(c)
	return c:IsFacedown() or not c:IsCode(112345682)
end
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
	return  not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.eqfilter(c)
	return c:IsFaceup() and c:IsCode(112345682) -- ID do "DARK JOJO DIO"
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		if Duel.Equip(tp,c,tc,true) then
			-- Define que só esse monstro pode ser equipado
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(function(e,c) return c==tc end)
			c:RegisterEffect(e1)

			-- 🔹 Efeito contínuo 1: o oponente não pode mudar posição de batalha
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e2:SetRange(LOCATION_SZONE)
			e2:SetTargetRange(0,LOCATION_MZONE)
			e2:SetCondition(function(e) return e:GetHandler():IsFaceup() end)
			c:RegisterEffect(e2)

			-- 🔹 Efeito contínuo 2: monstros em posição de defesa do oponente não podem ativar efeitos
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_FIELD)
			e3:SetCode(EFFECT_CANNOT_TRIGGER)
			e3:SetRange(LOCATION_SZONE)
			e3:SetTargetRange(0,LOCATION_MZONE)
			e3:SetCondition(function(e) return e:GetHandler():IsFaceup() end)
			e3:SetTarget(function(e,c) return c:IsDefensePos() end)
			c:RegisterEffect(e3)

		end
	else
		-- Se falhar, envia ao cemitério
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end