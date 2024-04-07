local mals_mod_config = require "Mods.malsmod"

local ranks = {"NaN",'2','3','4','5','6','7','8','9','10','Jack','Queen','King','Ace'}

local joker_name = "Counting"
local joker_id = "j_counting_malloc"
local joker_description = {
    "Gains {X:mult,C:white} X#1# {} Mult when a {C:attention}#2#{} is scored,",
    "rank increases when activated",
    "{C:inactive}(Currently {X:mult,C:white} X#3# {C:inactive} Mult)"
}


local effect_description_target_file = "card.lua"
local effect_description_target_function = "Card:generate_UIBox_ability_table"
local original_code = "        elseif self.ability.name == 'Perkeo' then loc_vars = {self.ability.extra}"
local ability_text = original_code .. "\n        elseif self.ability.name == 'Counting' then loc_vars = {self.ability.extra.x_mult_delta, localize(self.ability.extra.rank_name,'ranks'), self.ability.x_mult }"

local function jokerEffect(card, context)
    if card.ability.name == joker_name and context.individual and context.cardarea == G.play then 
        local v = context.other_card
        local cardVal = v:get_id()
        sendDebugMessage("Card Rank: " .. cardVal .. " Ability Rank: " .. card.ability.extra.rank_index)
        if cardVal == card.ability.extra.rank_index then
            card.ability.extra.rank_index =  (card.ability.extra.rank_index % 14) + 1
            if card.ability.extra.rank_index == 1 then
                card.ability.extra.rank_index = 2
            end
            card.ability.extra.rank_name = ranks[card.ability.extra.rank_index]
            card.ability.x_mult = card.ability.x_mult + card.ability.extra.x_mult_delta
            G.E_MANAGER:add_event(Event({
                func = function()
                    card:juice_up()
                    return true
                end
            })) 
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

sendDebugMessage(mals_mod_config);
table.insert(mods,
{
    mod_id = mals_mod_config.mod_id,
    name = mals_mod_config.mod_name,
    version = mals_mod_config.mod_version,
    description = mals_mod_config.mod_description,
    author = mals_mod_config.mod_author,
    enabled = true,
    on_enable = function()
        centerHook.addJoker(self, 
            joker_id,  --id
            joker_name,       --name
            jokerEffect,        --effect function
            nil,                --order
            true,               --unlocked
            true,               --discovered
            7,                  --cost
            {x=0, y=0},         --sprite position
            nil,                --internal effect description
            {extra = {  x_mult_delta = 0.1, rank_index = 2, rank_name = "2"}, x_mult = 1},         --config
            joker_description, --description text
            2,                  --rarity
            true,               --blueprint compatibility
            true,               --eternal compatibility
            nil,                --exclusion pool flag
            nil,                --inclusion pool flag
            nil,                --unlock condition
            true,               --collection alert
            "assets",           --sprite path
            "Counting.png",   --sprite name
            {px=71, py=95}      --sprite size
        )
       inject(effect_description_target_file, effect_description_target_function, original_code, ability_text)
    end,
    on_disable = function()
        centerHook.removeJoker(self, joker_id)
    end
})
