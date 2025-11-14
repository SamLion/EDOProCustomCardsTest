--Lobisomem Líder da Aldeia
local s,id=GetID()
function s.initial_effect(c)
    --Ativar um dos efeitos
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_COUNTER+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.thfilter(c)
    return c:IsCode(11111119) and c:IsAbleToHand() -- ID de "Campo de Caça Lobisomem"
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(0x1F10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
    local op=Duel.SelectOption(tp,
        aux.Stringid(id,2), -- Adicionar Campo de Caça Lobisomem
        aux.Stringid(id,3)) -- Colocar Marcador + Invocar monstro
    e:SetLabel(op)
    if op==0 then
        e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    else
        e:SetCategory(CATEGORY_COUNTER+CATEGORY_SPECIAL_SUMMON)
        Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1999)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
    end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local op=e:GetLabel()
    if op==0 then
        --Buscar "Campo de Caça Lobisomem"
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    else
        --Adicionar contador e invocar monstro
        local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_FZONE,0,nil)
        local tc=g:GetFirst()
        if tc and tc:IsCode(11111119) then -- Verifica o Campo de Caça Lobisomem
            tc:AddCounter(0x1999,1)
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
            if #sg>0 then
                Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
            end
        end
    end
end
