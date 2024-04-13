local s_exile = {}
local spectral_name = "Exile"
local spectral_id = "s_exile_mal_loc"

local pool_injection_target_file = "functions/common_events.lua"
local pool_injection_target_function = "get_current_pool"
--local pool_injection_target = "        return _pool, _pool_key..G.GAME.round_resets.ante"
--local pool_injection_replace = "    sendDebugMessage(_pool)\n" .. pool_injection_target


local available_cards_target_file = "game.lua"
local available_cards_target_function = "Game:init_game_object"
local available_cards_target = "        banned_keys = {},"
local available_cards_replace = available_cards_target .. "\n current_playing_cards = G.P_CARDS,"


local get_available_cards_target_file = "functions/common_events.lua"
local get_available_cards_target_function = "create_playing_card"
local get_available_cards_target = "    card_init.front = card_init.front or pseudorandom_element(G.P_CARDS, pseudoseed('front'))"
local get_available_cards_replace = "    card_init.front = card_init.front or pseudorandom_element(G.GAME.current_playing_cards, pseudoseed('front'))"


--[[
At the moment, Showman doesnt undo the banned card.
Verify that destroyed card triggers jokers that rely on destroyed cards
   Canio: working
   Glass Joker: not working (matches behaviour in base game)
Jokers: working
Consumeables: working
Playing cards: working



Vouchers: not in scope
Boosters: not in scope
]]

local function appendTable(a, b)
    for i,v in ipairs(b) do
       a[#a+1] = v
    end
    return a
end

local function getAreaHighlightedCards(area)
    local result = {}
    if area == nil then return result end
    if area.cards == nil then return result end
    for _, card in ipairs(area.cards) do
        if card.highlighted then
            table.insert(result, card)
        end
    end
    return result
end


local function getAllHighlightedCards(this_card)
    local result = {}
    result = appendTable(result, getAreaHighlightedCards(G.jokers))
    result = appendTable(result, getAreaHighlightedCards(G.hand))
    result = appendTable(result, getAreaHighlightedCards(G.consumeables))
    result = appendTable(result, getAreaHighlightedCards(G.shop_jokers))
    --result = appendTable(result, getAreaHighlightedCards(G.shop_vouchers))
    --result = appendTable(result, getAreaHighlightedCards(G.shop_booster))
    result = appendTable(result, getAreaHighlightedCards(G.pack_cards))
    
    if this_card then
        for i, card in ipairs(result) do
            if card == this_card then
                table.remove(result, i)
                break
            end
        end
    end

    return result
end


--[[
    this function will be run in this loop:
    for _, condition in ipairs(centerHook.canUseConsumeable) do
        if condition(self) then
            return condition(self)
        end
    end
]]
local function consumeableCondition(card)
  if card.ability.name == spectral_name then
  return #getAllHighlightedCards(card) == 1
  else return false
  end
end

--[[
    this function will be run in this loop:
    for _, effect in ipairs(centerHook.consumeableEffects) do
        effect(self)
    end
]]


local function exileCard(card)
    local card_key = card.config.card_key

    if card_key ~= nil then
        sendDebugMessage("Exiling card: " .. card_key)
        G.GAME.current_playing_cards[card_key] = nil
        for i = 1, #G.jokers.cards do
            G.jokers.cards[i]:calculate_joker({remove_playing_cards = true, removed = {card}})
        end
    else 
        if G.GAME.banned_keys == nil then
            G.GAME.banned_keys = {}
        end
        G.GAME.banned_keys[card.config.center.key] = true
    end
end 

--look for Showman
local function consumeableEffect(card)
    if card.ability.name == spectral_name then

        local highlighted_card = getAllHighlightedCards(card)[1]

        sendDebugMessage(highlighted_card.config.center)


        --sendDebugMessage(G.GAME.banned_keys)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function() 
                play_sound('timpani')
                exileCard(highlighted_card)
                if highlighted_card.abiilty and highlighted_card.abiilty.name == 'Glass Card' then
                    highlighted_card:shatter()
                else
                    highlighted_card:start_dissolve(nil,false)
                end
                return true 
            end 
            })
        )
    end
end



s_exile.onEnable = function()
    local spectral, text = centerHook.addSpectral(self,
    spectral_id,
    spectral_name,
    consumeableEffect,
    consumeableCondition,
    nil,
    true,
    4,
    {x=0,y=0},
    nil,
    {"Remove {C:attention}1{} selected card",
    "from the game"},
    true,
    "assets",
    "Exile.png"
)
--sendDebugMessage(pool_injection_replace)
--inject(pool_injection_target_file, pool_injection_target_function,pool_injection_target, pool_injection_replace)
inject(available_cards_target_file, available_cards_target_function, available_cards_target, available_cards_replace)
inject(get_available_cards_target_file, get_available_cards_target_function, get_available_cards_target, get_available_cards_replace)
end
s_exile.on_disable = function()
    centerHook.removeSpectral(self, spectral_id)
end




s_exile.on_key_pressed = function(key)
  if(key == 'v') then
        local c_set = "Spectral" -- "Spectral", "Planet", etc
        local c1 = create_card(c_set, G.consumeables, nil, 1, false, false, spectral_id, nil)
        c1.area = G.consumeables
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                c1.area:remove_card(c1)
                c1:add_to_deck()
                G.consumeables:emplace(c1)
            
                G.CONTROLLER:save_cardarea_focus('consumeables')
                G.CONTROLLER:recall_cardarea_focus('consumeables')
                return true
            end
        }))
  end
  if (key == 'u') then
    sendDebugMessage(G.GAME.current_playing_cards)
    end
end

return s_exile;


