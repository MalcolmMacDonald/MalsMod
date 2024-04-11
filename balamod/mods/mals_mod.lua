local j_counting = require("Mods/j_counting")
local s_delete = require("Mods/s_delete")

local mals_mod_config ={
    mod_id = "mals_mod_mal_loc",
    mod_name = "Mals Mod",
    mod_version = "1.0",
    mod_author = "mal_loc",
    mod_description = "Adds a counting joker"
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
        j_counting.onEnable()
        s_delete.onEnable()
    end,
    on_disable = function ()
        j_counting.on_disable()
        s_delete.on_disable()
    end,
    on_key_pressed = s_delete.on_key_pressed,
})