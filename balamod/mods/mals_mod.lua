local j_countdown = require("Mods/j_countdown")
local s_exile = require("Mods/s_exile")

local mals_mod_config ={
    mod_id = "mals_mod_mal_loc",
    mod_name = "Mals Mod",
    mod_version = "1.0",
    mod_author = "mal_loc",
    mod_description = "Adds a Countdown joker"
}
table.insert(mods,
{
    mod_id = mals_mod_config.mod_id,
    name = mals_mod_config.mod_name,
    version = mals_mod_config.mod_version,
    description = mals_mod_config.mod_description,
    author = mals_mod_config.mod_author,
    enabled = true,
    on_enable = function ()
        j_countdown.onEnable()
        s_exile.onEnable()
    end,
    on_disable = function ()
        j_countdown.on_disable()
        s_exile.on_disable()
    end,
    on_key_pressed = s_exile.on_key_pressed,
})