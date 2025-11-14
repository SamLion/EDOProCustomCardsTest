--Campo de Caça Lobisomem
local s,id=GetID()
function s.initial_effect(c)
	--Ativa normalmente
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

	--Efeito ativado na Fase Final
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	
	--Se deixar o campo
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end

function s.wolf_filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1F10)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.wolf_filter,tp,LOCATION_MZONE,0,1,nil)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
	e:SetLabel(op)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()

	--Opção 1: Remover contador e trocar Guerreiro -> Extra Deck
	if op==0 then
		if c:GetCounter(0x1999)==0 then return end
		c:RemoveCounter(tp,0x1,1,REASON_EFFECT)

		local g=Duel.GetMatchingGroup(function(c)
			return c:IsFaceup() and c:IsSetCard(0x1F10) and c:IsRace(RACE_WARRIOR)
		end,tp,LOCATION_MZONE,0,nil)

		local ct=#g
		if ct==0 then return end

		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)

		local extra=Duel.GetMatchingGroup(function(c)
			return c:IsSetCard(0x1F10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
		end,tp,LOCATION_EXTRA,0,nil)

		if #extra>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local candidates = extra:Clone()
            local sg = Group.CreateGroup()
            for i=1,ct do
                if candidates:GetCount()==0 then break end
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                local sel = candidates:Select(tp,1,1,nil)
                local sc = sel:GetFirst()
                if not sc then break end
                sg:AddCard(sc)
                -- remove do pool todos com o mesmo Level para evitar repetir níveis
                local lvl = sc:GetLevel()
                local torem = candidates:Filter(function(c) return c:GetLevel()==lvl end, nil)
                candidates:Sub(torem)
            end
            if sg:GetCount()>0 then
                Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
            end
        end

	else
		--Opção 2: devolver Besta-Guerreira -> trazer Guerreiro banido
		local g=Duel.GetMatchingGroup(function(c)
			return c:IsFaceup() and c:IsSetCard(0x1F10) and c:IsRace(RACE_BEASTWARRIOR)
		end,tp,LOCATION_MZONE,0,nil)

		local ct=#g
		if ct==0 then return end

		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)

		local banished=Duel.GetMatchingGroup(function(c)
			return c:IsFaceup() and c:IsSetCard(0x1F10) and c:IsRace(RACE_WARRIOR)
				and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,tp,LOCATION_REMOVED,0,nil)

		if #banished>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=banished:Select(tp,ct,ct,nil)
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(function(c)
			return c:IsFaceup() and c:IsSetCard(0x1F10) and c:IsRace(RACE_BEASTWARRIOR)
		end,tp,LOCATION_MZONE,0,1,nil)
	end
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(function(c)
		return c:IsFaceup() and c:IsSetCard(0x1F10) and c:IsRace(RACE_BEASTWARRIOR)
	end,tp,LOCATION_MZONE,0,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
