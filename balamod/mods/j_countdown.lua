local j_countdown = {}
local ranks = {"NaN",'2','3','4','5','6','7','8','9','10','Jack','Queen','King','Ace'}
local joker_name = "Countdown"
local joker_id = "j_countdown_malloc"
local joker_description = {
    "Gains {X:mult,C:white} X#1# {} Mult when a {C:attention}#2#{} is scored,",
    "rank decreases when activated",
    "{C:inactive}(Currently {X:mult,C:white} X#3# {C:inactive} Mult)"
}
local effect_description_target_file = "card.lua"
local effect_description_target_function = "Card:generate_UIBox_ability_table"
local original_code = "        elseif self.ability.name == 'Perkeo' then loc_vars = {self.ability.extra}"
local ability_text = original_code .. "\n        elseif self.ability.name == 'Countdown' then loc_vars = {self.ability.extra.x_mult_delta, localize(self.ability.extra.rank_name,'ranks'), self.ability.x_mult }"


local function changeRankIndex(card,direction) 
    card.ability.extra.rank_index = card.ability.extra.rank_index + direction
    local has_looped = false
    if card.ability.extra.rank_index == 1 then
        card.ability.extra.rank_index = 14
        has_looped = true
    end
    card.ability.extra.rank_name = ranks[card.ability.extra.rank_index]
    card.ability.x_mult = card.ability.x_mult + card.ability.extra.x_mult_delta
    return has_looped
end

local function jokerEffect(card, context)
    if card.ability.name == joker_name and context.individual and context.cardarea == G.play then 
        local v = context.other_card
        local cardVal = v:get_id()
        if cardVal == card.ability.extra.rank_index then
            changeRankIndex(card, -1)
            local has_looped = card.ability.extra.rank_index == 13
            if has_looped then 
                G.E_MANAGER:add_event(Event({
                    blocking=false,
                    func = function()
                        play_sound('gong', 0.8, 0.7)
                        card:juice_up(0.7)
                        return true
                    end
                }))
            end

            return {
                extra = {focus = card, message = localize('k_upgrade_ex')},
                card = card,
                colour = G.C.MULT
            }
        else 
        return {
            card = card
        }
        end 
    end
end

j_countdown.onEnable = function()
        centerHook.addJoker(self, 
            joker_id,  --id
            joker_name,         --name
            jokerEffect,        --effect function
            nil,                --order
            true,               --unlocked
            true,               --discovered
            7,                  --cost
            {x=0, y=0},         --sprite position
            nil,                --internal effect description
            {extra = {  x_mult_delta = 0.1, rank_index = 14, rank_name = "Ace"}, x_mult = 1},         --config
            joker_description, --description text
            2,                  --rarity
            true,               --blueprint compatibility
            true,               --eternal compatibility
            nil,                --exclusion pool flag
            nil,                --inclusion pool flag
            nil,                --unlock condition
            true,               --collection alert
            "assets",           --sprite path
            "Countdown.png",   --sprite name
            {px=71, py=95}      --sprite size
        )
       inject(effect_description_target_file, effect_description_target_function, original_code, ability_text)
end
j_countdown.on_disable = function()
        centerHook.removeJoker(self, joker_id)
end

j_countdown.on_key_pressed = function(key_name)
    --[[if (key_name == "down" or key_name == "up") then
        if (G.jokers == nil) then return end
        if (G.jokers.highlighted == nil) then return end
        local direction = 1
        if (key_name == "down") then
            direction = -1
        end
        sendDebugMessage("Joker Count: " .. #G.jokers.highlighted)
        if (#G.jokers.highlighted ~= 1) then return end
        local joker = G.jokers.highlighted[1]
        if (joker.ability.name ~= joker_name) then return end
        sendDebugMessage("Joker Rank: " .. joker.ability.extra.rank_index)
        joker.ability.extra.rank_index = (joker.ability.extra.rank_index ) % 14 + direction
        if joker.ability.extra.rank_index == 0 then
            joker.ability.extra.rank_index = 14
        end
        joker.ability.extra.rank_name = ranks[joker.ability.extra.rank_index]
        joker.ability.x_mult = joker.ability.x_mult + joker.ability.extra.x_mult_delta
   end]]
end

return j_countdown